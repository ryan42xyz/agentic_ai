# List individual database sizes
MYSQL_ROOT_PASSWORD=password
k exec -n prod fp-mysql-0 -it -- bash
mysql -u root -ppassword -e "SELECT table_schema AS 'Database', ROUND(SUM(data_length + index_length)/1024/1024, 2) AS 'Size (MB)' FROM information_schema.tables GROUP BY table_schema;"

```bash
# FP MySQL backup
k exec -n prod fp-mysql-0 -- mysqldump -u root -ppassword --all-databases > oncall_history/RELEASE_PROD_DEMO_-1/backups/mysql/prod_fp_mysql_${BACKUP_TIME}.sql
```


kubectl patch deployment mysql-deployment -p '{"spec": {"template": {"spec": {"containers": [{"name": "mysql", "resources": {"limits": {"cpu": "4", "memory": "16Gi"}, "requests": {"cpu": "4", "memory": "16Gi"}}}}]}}}}'

kubectl patch sts fp-mysql -p '{"spec": {"template": {"spec": {"containers": [{"name": "mysql", "resources": {"limits": {"cpu": "4", "memory": "16Gi"}, "requests": {"cpu": "4", "memory": "16Gi"}}}}]}}}}'


kuberctl exec -n prod fp-mysql-0 -- mysqldump -u root -pprod --all-databases > oncall_history/RELEASE_PROD_DEMO_-1/backups/mysql/prod_fp_mysql_1.sql

---

aws 
from aws ec2 - reboot ! (don't stop && start)
