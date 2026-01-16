# ClickHouse Data Extraction Guide for Backfill

## Overview
This guide covers the process of extracting data from ClickHouse for backfill operations across different environments.

## Common Parameters
- Target Server: `root@172.30.72.53`
- Common Upload Path: `/mnt/data/`
- ClickHouse Pod Pattern: `chi-dv-datavisor-0-0-0`

## Environment Aliases
- US East Prod-A: `keastproda`
- US East Prod-B: `keastprodb`
- US East Preprod: `keastpreprod`

## Standard Process

### 1. Pod Connection Commands
```bash
# List ClickHouse pods in namespace
${CLUSTER_ALIAS} get pods -n preprod | grep clickhouse

# Connect to ClickHouse pod
${CLUSTER_ALIAS} exec -it chi-dv-datavisor-0-0-0 -n preprod -c clickhouse -- bash
```

### 2. Data Extraction Commands
```bash
# Inside the pod
mkdir -p /tmp/nymbus_extract
cd /tmp/nymbus_extract

# Run query and save to CSV (example with detection_store)
clickhouse-client --query="YOUR_QUERY_HERE" --format=CSVWithNames > output_file.csv

# Verify extraction
ls -la output_file.csv
wc -l output_file.csv
head -5 output_file.csv
```

### 3. File Transfer Commands
```bash
# Copy from pod to local
${CLUSTER_ALIAS} cp chi-dv-datavisor-0-0-0:/tmp/nymbus_extract/output_file.csv ./output_file.csv -n preprod -c clickhouse

# Upload to target server
scp output_file.csv root@172.30.72.53:/mnt/data/target_directory/

# Verify upload
ssh root@172.30.72.53 "ls -la /mnt/data/target_directory/output_file.csv"
ssh root@172.30.72.53 "wc -l /mnt/data/target_directory/output_file.csv"
```

### 4. Cleanup Commands
```bash
# Remove temp files from pod
${CLUSTER_ALIAS} exec -it chi-dv-datavisor-0-0-0 -n preprod -c clickhouse -- rm -rf /tmp/nymbus_extract

# Remove local copy if needed
rm output_file.csv
```

## Example Cases

### Case 1: Detection Store Query
```sql
-- Query template
select requestBody 
from nymbus.detection_store 
where toStartOfHour(toDateTime(timeInserted/1000)) ='2025-05-05T22:00:00' 
and requestBody like '%cust1011-prod-parquet-core-bank.data.transaction.item%';

-- Complete command sequence
# Connect and extract
keastpreprod exec -it chi-dv-datavisor-0-0-0 -n preprod -c clickhouse -- bash
mkdir -p /tmp/nymbus_extract
cd /tmp/nymbus_extract
clickhouse-client --query="select requestBody from nymbus.detection_store where toStartOfHour(toDateTime(timeInserted/1000)) ='2025-05-05T22:00:00' and requestBody like '%cust1011-prod-parquet-core-bank.data.transaction.item%'" --format=CSVWithNames > dataset_7936.csv

# Copy and upload
keastpreprod cp chi-dv-datavisor-0-0-0:/tmp/nymbus_extract/dataset_7936.csv ./dataset_7936.csv -n preprod -c clickhouse
scp dataset_7936.csv root@172.30.72.53:/mnt/data/nymbus_503746/
```

### Case 2: Event Result Query
```sql
-- Query template
select EXTERNAL_EVENT_STRING 
from nymbus.event_result 
where timeInserted > 1746675801546 
and ___topic='cust1011-prod-parquet-core-bank.data.transaction.item';

-- Complete command sequence
# Connect and extract
keastprodb exec -it chi-dv-datavisor-0-0-0 -n preprod -c clickhouse -- bash
mkdir -p /tmp/nymbus_extract
cd /tmp/nymbus_extract
clickhouse-client --query="select EXTERNAL_EVENT_STRING from nymbus.event_result where timeInserted > 1746675801546 and ___topic='cust1011-prod-parquet-core-bank.data.transaction.item'" --format=CSVWithNames > 2025_backfill_ds.csv

# Copy and upload
keastprodb cp chi-dv-datavisor-0-0-0:/tmp/nymbus_extract/2025_backfill_ds.csv ./2025_backfill_ds.csv -n preprod -c clickhouse
scp 2025_backfill_ds.csv root@172.30.72.53:/mnt/data/nymbus_503746/
```

## Best Practices
1. Always verify file existence and row count after each step
2. Use appropriate cluster alias based on environment
3. Clean up temporary files after successful transfer
4. Include headers in CSV files using `--format=CSVWithNames`
5. Double-check target directory permissions before upload

## Troubleshooting
1. If pod connection fails:
   - Verify namespace and pod name
   - Check cluster connectivity
   - Confirm access permissions

2. If data extraction fails:
   - Verify query syntax
   - Check disk space in pod
   - Confirm database permissions

3. If file transfer fails:
   - Check network connectivity
   - Verify target directory exists
   - Confirm SSH key setup
   - Check disk space on target server 