# ClickHouse Data Extraction for Backfill

## Problem Pattern
- Category: Data Extraction
- Symptoms: Need to extract specific data from ClickHouse for backfill operations
- Common Request: Extract data from detection_store or event_result tables 

## Standard Extraction Process

### 1. Initial Assessment
- Identify the specific tenant and environment (cluster, namespace)
- Determine the SQL query to extract the required data
- Identify the target location for the extracted data

### 2. Common Commands

#### 2.1 Connect to Cluster and Pod
```bash
# List ClickHouse pods in the namespace
${CLUSTER_ALIAS} get pods -n ${NAMESPACE} | grep clickhouse

# Connect to the ClickHouse pod
${CLUSTER_ALIAS} exec -it ${POD_NAME} -n ${NAMESPACE} -c clickhouse -- bash
```

#### 2.2 Extract Data
```bash
# Inside the ClickHouse pod
# Create temporary directory
mkdir -p /tmp/${TENANT}_extract
cd /tmp/${TENANT}_extract

# Execute SQL query and save to CSV with headers
clickhouse-client --query="${SQL_QUERY}" --format=CSVWithNames > ${OUTPUT_FILENAME}

# Verify the extraction
ls -la ${OUTPUT_FILENAME}
wc -l ${OUTPUT_FILENAME}
head -5 ${OUTPUT_FILENAME}
```

#### 2.3 Copy to Local Machine
```bash
# Exit from pod
exit

# Copy the file from pod to local machine
${CLUSTER_ALIAS} cp ${POD_NAME}:/tmp/${TENANT}_extract/${OUTPUT_FILENAME} ./${OUTPUT_FILENAME} -n ${NAMESPACE} -c clickhouse
```

#### 2.4 Upload to Target Server
```bash
# Upload to target server
scp ${OUTPUT_FILENAME} root@172.30.72.53:${TARGET_PATH}

# Verify the upload
ssh root@172.30.72.53 "ls -la ${TARGET_PATH}"
ssh root@172.30.72.53 "wc -l ${TARGET_PATH}"
```

#### 2.5 Cleanup
```bash
# Clean up the temporary files in the pod
${CLUSTER_ALIAS} exec -it ${POD_NAME} -n ${NAMESPACE} -c clickhouse -- rm -rf /tmp/${TENANT}_extract

# Optional: Remove local copy
rm ${OUTPUT_FILENAME}
```

## Example Cases

### Example 1: Nymbus Detection Store Data Extraction (US East Preprod)
```bash
# List pods
keastpreprod get pods -n clickhouse | grep clickhouse

# Connect to pod
keastpreprod exec -it chi-dv-datavisor-0-0-0 -n clickhouse -c clickhouse -- bash

# Create directory and extract data
mkdir -p /tmp/nymbus_extract
cd /tmp/nymbus_extract
clickhouse-client --query="select requestBody from nymbus.detection_store where toStartOfHour(toDateTime(timeInserted/1000)) ='2025-05-05T22:00:00' and requestBody like '%cust1011-prod-parquet-core-bank.data.transaction.item%'" --format=CSVWithNames > dataset_7936.csv

# Exit pod and copy file
exit
keastpreprod cp chi-dv-datavisor-0-0-0:/tmp/nymbus_extract/dataset_7936.csv ./dataset_7936.csv -n clickhouse -c clickhouse

# Upload to target
scp dataset_7936.csv root@172.30.72.53:/mnt/data/nymbus_503746/

# Verify upload
ssh root@172.30.72.53 "ls -la /mnt/data/nymbus_503746/dataset_7936.csv"

# Cleanup
keastpreprod exec -it chi-dv-datavisor-0-0-0 -n clickhouse -c clickhouse -- rm -rf /tmp/nymbus_extract
rm dataset_7936.csv
```

### Example 2: Nymbus Event Result Data Extraction (US East Prod-B)
```bash
# List pods
keastprodb get pods -n preprod | grep clickhouse

# Connect to pod
keastprodb exec -it chi-dv-datavisor-0-0-0 -n preprod -c clickhouse -- bash

# Create directory and extract data
mkdir -p /tmp/nymbus_extract
cd /tmp/nymbus_extract
clickhouse-client --query="select EXTERNAL_EVENT_STRING from nymbus.event_result where timeInserted > 1746675801546 and ___topic='cust1011-prod-parquet-core-bank.data.transaction.item'" --format=CSVWithNames > 2025_backfill_ds.csv

# Exit pod and copy file
exit
keastprodb cp chi-dv-datavisor-0-0-0:/tmp/nymbus_extract/2025_backfill_ds.csv ./2025_backfill_ds.csv -n preprod -c clickhouse

# Upload to target
scp 2025_backfill_ds.csv root@172.30.72.53:/mnt/data/nymbus_503746/

# Verify upload
ssh root@172.30.72.53 "ls -la /mnt/data/nymbus_503746/2025_backfill_ds.csv"

# Cleanup
keastprodb exec -it chi-dv-datavisor-0-0-0 -n preprod -c clickhouse -- rm -rf /tmp/nymbus_extract
rm 2025_backfill_ds.csv
```

## Best Practices
1. Always use the appropriate cluster alias based on the environment
2. Verify data extraction by checking row counts
3. Always clean up temporary files after the operation
4. Use CSVWithNames format to include headers in the output
5. Document the SQL query and extraction details for future reference 