# Production Hardening Runbook

This runbook applies the repository changes in the `production-hardening` branch without disrupting the current working production job.

## 1. Apply Snowflake infrastructure changes

Run `setup/01_snowflake_hardening.sql` using the roles indicated in the script.

This creates:

- `DEV_WH` for development workloads
- `DBT_PROD_WH` for production workloads
- `DEV.DBT_DEV_STAGING`
- `DEV.DBT_DEV_INTERMEDIATE`
- `DEV.DBT_DEV_MARTS`
- `PROD.ANALYTICS_STAGING`
- `PROD.ANALYTICS_INTERMEDIATE`
- `PROD.ANALYTICS_MARTS`
- `ANALYTICS_READER_ROLE` with read-only access to production marts

## 2. Add persistent RAW ingestion metadata

Run `setup/02_raw_ingestion_metadata.sql` against the existing RAW Olist tables.

The script adds `_LOADED_AT` and backfills existing rows. The validation query at the end should return `0` null ingestion timestamps for every table.

For future loads, `_LOADED_AT` must be populated at ingestion time. This field is now the incremental watermark used downstream rather than `order_purchase_timestamp`.

## 3. Update dbt Cloud connections

Development connection/profile:

- Database: `DEV`
- Warehouse: `DEV_WH`
- Base schema: `DBT_DEV`
- Role: `DEV_ROLE`

Production connection/profile:

- Database: `PROD`
- Warehouse: `DBT_PROD_WH`
- Base schema: `ANALYTICS`
- Role: `DBT_ROLE`
- User: `DBT_USER`
- Authentication: existing RSA key-pair authentication

With dbt's default custom-schema naming, the project configuration creates target-derived schemas such as `DBT_DEV_STAGING` and `ANALYTICS_MARTS`.

## 4. Validate the branch in DEV before merge

Switch dbt Studio to `production-hardening`, pull the latest changes, and run:

```bash
dbt build
```

Then validate in Snowflake:

```sql
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS unique_orders
FROM DEV.DBT_DEV_MARTS.FCT_ORDERS;

SELECT COUNT(*) AS total_rows
FROM DEV.DBT_DEV_MARTS.FCT_ORDER_ITEMS;

SELECT order_id, order_item_id, COUNT(*) AS row_count
FROM DEV.DBT_DEV_MARTS.FCT_ORDER_ITEMS
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
```

Expected baseline for the current Olist snapshot:

- `FCT_ORDERS`: 99,441 rows and 99,441 distinct order IDs
- `FCT_ORDER_ITEMS`: 112,650 rows
- duplicate `(order_id, order_item_id)` combinations: 0 rows

## 5. Pull-request CI

The repository now contains `.github/workflows/dbt-project-ci.yml`.

Every pull request targeting `main` will automatically:

1. install the Snowflake dbt adapter,
2. parse the project from a clean environment, and
3. validate that dbt can construct the project graph.

This gives the repository a real GitHub status check without exposing Snowflake credentials.

For warehouse-backed Slim CI, configure a dbt Cloud CI environment after this branch passes DEV validation. Use a non-production target and select modified resources plus downstream dependencies. Do not point CI at `PROD`.

## 6. Production deployment

After DEV passes and the pull request is merged:

1. keep the production environment on `main`,
2. confirm its warehouse is `DBT_PROD_WH`,
3. run `Olist Production Build` manually once,
4. validate `PROD.ANALYTICS_MARTS.FCT_ORDERS` and `FCT_ORDER_ITEMS`, and
5. allow the existing 12-hour schedule to resume.

The previous objects in `PROD.ANALYTICS` should remain in place until the new layered schemas have been validated. Remove the old objects only in a separate cleanup change.

## 7. Source freshness

Freshness metadata is defined against `_LOADED_AT` in `_sources.yml`.

Do not enable `dbt source freshness` as a blocking production step until RAW ingestion itself is scheduled. The current Olist dataset is static, so a freshness check will correctly become stale when no new source batch arrives.

Once ingestion is automated, place `dbt source freshness` before `dbt build` in the production job.

## 8. Operational alerts

After the production migration is complete, configure dbt Cloud notifications for:

- production job failures,
- test failures,
- source freshness failures once freshness is enabled.

The repository-side tests already distinguish hard failures from warning-level anomalies such as timestamp inconsistencies and payment reconciliation differences.
