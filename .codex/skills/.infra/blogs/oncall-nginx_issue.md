# Nginx 调试与管理流程命令清单

## 概述

本文档提供了标准化的 nginx 调试与管理流程命令清单，适用于基于 systemd 的 Linux 系统（如 Ubuntu / Debian / CentOS 7+）。

内容分为：
- **状态查看**：检查 nginx 运行状态和端口监听
- **日志查看**：查看错误日志和系统日志
- **服务控制**：启动、停止、重启、重载配置
- **调试流程**：排查问题的系统化方法

---

## 一、查看 Nginx 状态

### 1️⃣ 当前运行状态

```bash
systemctl status nginx
```

**用途**: 查看 nginx 是否在运行、PID、最近几行日志。

**状态含义**:
- `active (running)` → 正常运行
- `inactive (dead)` → 未运行
- `failed` → 启动失败

**输出示例**:
```
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2025-11-24 10:30:45 UTC; 2h 15min ago
       Docs: man:nginx(8)
    Process: 1234 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 1235 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
   Main PID: 1236 (nginx)
      Tasks: 9 (limit: 4915)
     Memory: 15.2M
     CGroup: /system.slice/nginx.service
             ├─1236 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
             ├─1237 nginx: worker process
             └─1238 nginx: worker process
```

---

### 2️⃣ 查看是否监听端口

```bash
sudo ss -tulnp | grep nginx
```

**或使用 netstat**:
```bash
sudo netstat -tulnp | grep nginx
```

**用途**: 确认 nginx 是否在监听 80 或 443 端口。

**输出示例**:
```
tcp   LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=1236,fd=6))
tcp   LISTEN 0      511          0.0.0.0:443       0.0.0.0:*    users:(("nginx",pid=1236,fd=7))
tcp   LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=1236,fd=8))
tcp   LISTEN 0      511             [::]:443          [::]:*    users:(("nginx",pid=1236,fd=9))
```

**关键字段说明**:
- `0.0.0.0:80` → 监听所有 IPv4 接口的 80 端口
- `[::]:80` → 监听所有 IPv6 接口的 80 端口
- `pid=1236` → nginx master 进程 PID

---

### 3️⃣ 查看进程

```bash
ps -ef | grep nginx
```

**预期输出**: 应看到 master + 多个 worker 进程。

**输出示例**:
```
root      1236     1  0 10:30 ?        00:00:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data  1237  1236  0 10:30 ?        00:00:05 nginx: worker process
www-data  1238  1236  0 10:30 ?        00:00:05 nginx: worker process
www-data  1239  1236  0 10:30 ?        00:00:05 nginx: worker process
www-data  1240  1236  0 10:30 ?        00:00:05 nginx: worker process
```

**进程说明**:
- **master process** (root 用户): 主进程，负责管理 worker 进程
- **worker process** (www-data 用户): 工作进程，实际处理请求
- worker 数量通常等于 CPU 核心数

---

## 二、查看日志

### 1️⃣ 查看 Nginx 自身错误日志

```bash
tail -n 50 /var/log/nginx/error.log
```

**或持续观察**:
```bash
tail -f /var/log/nginx/error.log
```

**重点关注的错误信息**:
- `bind() failed` → 端口被占用
- `invalid directive` → 配置错误
- `permission denied` → 权限问题
- `upstream timed out` → 后端服务超时
- `could not build server_names_hash` → server_names_hash_bucket_size 太小

**常见错误示例**:
```
2025/11/24 10:30:45 [emerg] 1234#1234: bind() to 0.0.0.0:80 failed (98: Address already in use)
2025/11/24 10:30:45 [emerg] 1234#1234: still could not bind()
```

---

### 2️⃣ 查看 Systemd 相关日志

```bash
journalctl -xeu nginx
```

**或实时滚动**:
```bash
journalctl -fu nginx
```

**用途**: 这些日志更系统级，会包含启动/停止的行为、PID 退出原因。

**输出示例**:
```
Nov 24 10:30:45 server systemd[1]: Starting A high performance web server and a reverse proxy server...
Nov 24 10:30:45 server nginx[1234]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Nov 24 10:30:45 server systemd[1]: Started A high performance web server and a reverse proxy server.
```

**常用 journalctl 选项**:
- `-xe` → 显示最近的日志并解释错误
- `-f` → 实时跟踪日志
- `-u nginx` → 只显示 nginx 单元的日志
- `-n 100` → 显示最近 100 行
- `--since "10 minutes ago"` → 显示最近 10 分钟的日志

---

### 3️⃣ 查看访问日志

```bash
tail -f /var/log/nginx/access.log
```

**输出格式示例**:
```
192.168.1.100 - - [24/Nov/2025:10:30:45 +0000] "GET /api/v1/health HTTP/1.1" 200 15 "-" "curl/7.68.0"
192.168.1.101 - - [24/Nov/2025:10:30:46 +0000] "POST /api/v1/login HTTP/1.1" 401 56 "-" "Mozilla/5.0"
```

**日志字段说明**:
- `192.168.1.100` → 客户端 IP
- `GET /api/v1/health` → HTTP 方法和路径
- `200` → HTTP 状态码
- `15` → 响应大小（字节）

---

## 三、控制 Nginx 服务

### 1️⃣ 启动

```bash
sudo systemctl start nginx
```

---

### 2️⃣ 停止

```bash
sudo systemctl stop nginx
```

**优雅停止（等待请求处理完成）**:
```bash
sudo nginx -s quit
```

**立即停止（中断当前连接）**:
```bash
sudo nginx -s stop
```

---

### 3️⃣ 重启

```bash
sudo systemctl restart nginx
```

**说明**: 会完全停止并重新启动 nginx，会有短暂的服务中断。

---

### 4️⃣ 重载配置（无中断）

```bash
sudo nginx -t && sudo systemctl reload nginx
```

**说明**: 
- `nginx -t` → 先测试配置文件语法
- `&&` → 只有测试成功才执行重载
- `reload` → 平滑重载，不中断服务

**推荐做法**: 修改配置后始终先测试再重载，避免因配置错误导致服务中断。

**单独的命令**:
```bash
# 1. 测试配置
sudo nginx -t

# 2. 如果测试成功，重载配置
sudo systemctl reload nginx
```

---

### 5️⃣ 解除 "start-limit-hit" 锁定

当 nginx 在短时间内多次启动失败时，systemd 会进入保护状态：

```
Failed to start nginx.service: Start request repeated too quickly.
```

**解决方法**:
```bash
# 重置失败状态
sudo systemctl reset-failed nginx

# 再重新启动
sudo systemctl start nginx
```

---

### 6️⃣ 设置开机自启

```bash
# 启用开机自启
sudo systemctl enable nginx

# 禁用开机自启
sudo systemctl disable nginx

# 查看是否已启用
systemctl is-enabled nginx
```

---

## 四、常用 Debug 流程（排查思路）

### 1️⃣ 配置语法检查

```bash
sudo nginx -t
```

**成功输出**:
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

**失败输出示例**:
```
nginx: [emerg] invalid directive "server_nam" in /etc/nginx/conf.d/default.conf:5
nginx: configuration file /etc/nginx/nginx.conf test failed
```

---

### 2️⃣ 展示完整配置展开（含 include）

```bash
sudo nginx -T | less
```

**用途**: 
- 查看所有 include 的配置文件合并后的完整配置
- 可用于快速搜索 `listen`/`server_name`/`pid` 等关键字

**搜索示例**:
```bash
# 搜索所有 listen 指令
sudo nginx -T | grep listen

# 搜索特定 server_name
sudo nginx -T | grep "server_name api.example.com"
```

---

### 3️⃣ 检查配置文件路径

```bash
grep include /etc/nginx/nginx.conf
```

**确认子配置目录存在有效文件**:
```bash
ls /etc/nginx/conf.d/
ls /etc/nginx/sites-enabled/
```

**常见配置结构**:
```
/etc/nginx/
├── nginx.conf              # 主配置文件
├── conf.d/                 # 自定义配置目录
│   ├── default.conf
│   └── api.conf
├── sites-available/        # 可用站点配置
│   ├── default
│   └── myapp.conf
└── sites-enabled/          # 启用的站点配置（软链接）
    ├── default -> ../sites-available/default
    └── myapp.conf -> ../sites-available/myapp.conf
```

---

### 4️⃣ 检查 daemon 模式

```bash
grep daemon /etc/nginx/nginx.conf
```

**说明**: 
- systemd 环境下，**不需要** `daemon off;` 配置
- 如果有 `daemon off;`，应该删除或注释掉

**正确配置**:
```nginx
# 使用 systemd 管理时，不需要这一行
# daemon off;
```

---

### 5️⃣ 检查 PID 路径匹配

```bash
# 检查 nginx.conf 中的 PID 路径
grep pid /etc/nginx/nginx.conf

# 检查 systemd 服务文件中的 PID 路径
grep PIDFile /lib/systemd/system/nginx.service
```

**说明**: 两者应一致（通常是 `/var/run/nginx.pid` 或 `/run/nginx.pid`）。

**示例**:
```nginx
# /etc/nginx/nginx.conf
pid /var/run/nginx.pid;
```

```ini
# /lib/systemd/system/nginx.service
[Service]
PIDFile=/var/run/nginx.pid
```

---

### 6️⃣ 检查端口占用

```bash
sudo ss -tulnp | grep ':80\|:443'
```

**或**:
```bash
sudo lsof -i :80
sudo lsof -i :443
```

**如果端口被占用**:
- 选项 1: 停止占用端口的进程
- 选项 2: 修改 nginx 配置使用其他端口
- 选项 3: 修改占用方的端口配置

**查找占用端口的进程**:
```bash
sudo lsof -i :80
```

**输出示例**:
```
COMMAND   PID     USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
apache2  1234     root    4u  IPv6  12345      0t0  TCP *:http (LISTEN)
```

**解决方法**:
```bash
# 停止 Apache
sudo systemctl stop apache2
sudo systemctl disable apache2

# 然后启动 nginx
sudo systemctl start nginx
```

---

### 7️⃣ 检查文件权限

```bash
# 检查配置文件权限
ls -l /etc/nginx/nginx.conf
ls -l /etc/nginx/conf.d/

# 检查日志目录权限
ls -ld /var/log/nginx/

# 检查网站根目录权限
ls -ld /var/www/html/
```

**常见权限问题**:
- nginx 配置文件应该是 root:root，权限 644
- 日志目录应该是 www-data:adm，权限 755
- 网站文件应该是 www-data:www-data 或 root:root，可读

**修复权限示例**:
```bash
# 修复配置文件权限
sudo chown root:root /etc/nginx/nginx.conf
sudo chmod 644 /etc/nginx/nginx.conf

# 修复日志目录权限
sudo chown -R www-data:adm /var/log/nginx/
sudo chmod 755 /var/log/nginx/

# 修复网站目录权限
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
```

---

### 8️⃣ 检查 SELinux（CentOS/RHEL）

```bash
# 查看 SELinux 状态
getenforce

# 查看 SELinux 拒绝日志
sudo ausearch -m avc -ts recent | grep nginx

# 临时禁用 SELinux（仅用于测试）
sudo setenforce 0

# 永久禁用 SELinux（不推荐，应该正确配置）
# 编辑 /etc/selinux/config，设置 SELINUX=permissive
```

---

## 五、最小恢复方案

在无法立即定位问题时，可用最简配置测试：

```bash
# 创建最简测试配置
echo 'server { listen 80 default_server; return 200 "ok\n"; }' | sudo tee /etc/nginx/conf.d/test.conf

# 测试并重启
sudo nginx -t && sudo systemctl restart nginx

# 测试访问
curl http://localhost
```

**说明**: 如果能成功运行，说明原有配置文件有问题。

**恢复步骤**:
1. 备份当前配置
2. 逐步恢复原有配置文件
3. 每次恢复后测试：`nginx -t`
4. 找到导致问题的配置文件

---

## 六、常见问题排查

### 问题 1: nginx 无法启动

**排查步骤**:
1. 检查配置语法：`sudo nginx -t`
2. 查看错误日志：`tail -f /var/log/nginx/error.log`
3. 查看系统日志：`journalctl -xeu nginx`
4. 检查端口占用：`sudo ss -tulnp | grep :80`
5. 检查文件权限
6. 重置失败状态：`sudo systemctl reset-failed nginx`

---

### 问题 2: 配置修改后不生效

**排查步骤**:
1. 确认配置语法正确：`sudo nginx -t`
2. 使用 reload 而非 restart：`sudo systemctl reload nginx`
3. 检查是否有多个配置文件覆盖：`sudo nginx -T | grep <directive>`
4. 清除浏览器缓存
5. 检查是否有反向代理缓存

---

### 问题 3: 502 Bad Gateway

**常见原因**:
- 后端服务未启动
- 后端服务监听地址错误
- 防火墙阻止连接
- upstream 超时设置太短

**排查命令**:
```bash
# 检查后端服务是否运行
systemctl status <backend-service>

# 检查后端服务监听端口
ss -tulnp | grep <backend-port>

# 测试连接后端服务
curl http://localhost:<backend-port>

# 查看 nginx upstream 错误
tail -f /var/log/nginx/error.log | grep upstream
```

---

### 问题 4: 504 Gateway Timeout

**常见原因**:
- 后端处理时间过长
- upstream 超时设置太短
- 网络延迟

**解决方法**:
```nginx
# 在 nginx 配置中增加超时时间
location /api {
    proxy_pass http://backend;
    proxy_read_timeout 300s;
    proxy_connect_timeout 300s;
    proxy_send_timeout 300s;
}
```

---

### 问题 5: SSL 证书问题

**排查命令**:
```bash
# 检查证书文件是否存在
ls -l /etc/nginx/ssl/

# 检查证书有效期
openssl x509 -in /etc/nginx/ssl/cert.pem -noout -dates

# 检查证书和私钥是否匹配
openssl x509 -noout -modulus -in /etc/nginx/ssl/cert.pem | openssl md5
openssl rsa -noout -modulus -in /etc/nginx/ssl/key.pem | openssl md5

# 测试 SSL 配置
openssl s_client -connect localhost:443 -servername example.com
```

---

## 七、调试时的关注点顺序

按照以下顺序进行排查，可以快速定位大部分问题：

1. ✅ **语法验证**: `nginx -t`
2. ✅ **错误日志**: `tail -f /var/log/nginx/error.log`
3. ✅ **监听端口**: `ss -tulnp | grep nginx`
4. ✅ **PID 文件与 systemd 匹配**
5. ✅ **配置逻辑正确**（至少一个 server 块在监听）
6. ✅ **daemon 模式正确**（systemd 环境不需要 daemon off）
7. ✅ **重置失败状态后重启**: `systemctl reset-failed nginx`
8. ✅ **文件权限**: 检查配置文件、日志目录、网站目录权限
9. ✅ **SELinux/AppArmor**: 检查安全模块是否阻止 nginx

---

## 八、有用的配置片段

### 1. 基础配置模板

```nginx
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    sendfile on;
    tcp_nopush on;
    keepalive_timeout 65;
    
    include /etc/nginx/conf.d/*.conf;
}
```

---

### 2. 反向代理配置

```nginx
upstream backend {
    server 127.0.0.1:8080;
    server 127.0.0.1:8081 backup;
}

server {
    listen 80;
    server_name api.example.com;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 超时设置
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

---

### 3. SSL/TLS 配置

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;
    
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    
    # 现代化 SSL 配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
    ssl_prefer_server_ciphers off;
    
    # HSTS
    add_header Strict-Transport-Security "max-age=63072000" always;
    
    location / {
        root /var/www/html;
        index index.html;
    }
}

# HTTP 重定向到 HTTPS
server {
    listen 80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
}
```

---

## 九、性能优化建议

### 1. Worker 进程优化

```nginx
# 自动设置为 CPU 核心数
worker_processes auto;

# 绑定 worker 到 CPU 核心
worker_cpu_affinity auto;

# 增加每个 worker 的连接数
events {
    worker_connections 4096;
}
```

---

### 2. 缓冲区优化

```nginx
http {
    # 增加缓冲区大小
    client_body_buffer_size 128k;
    client_max_body_size 10m;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 4k;
    output_buffers 1 32k;
    postpone_output 1460;
}
```

---

### 3. 缓存配置

```nginx
http {
    # 代理缓存
    proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=1g inactive=60m;
    
    server {
        location / {
            proxy_pass http://backend;
            proxy_cache my_cache;
            proxy_cache_valid 200 60m;
            proxy_cache_valid 404 1m;
            add_header X-Cache-Status $upstream_cache_status;
        }
    }
}
```

---

## 十、相关文档

- [Luigi 进程调试助手使用指南](oncall-luigi-debug-helper.md)
- [系统架构：请求路由流程分析](architecture-request-routing-flow.md)
- [Kubernetes 网络指南](aws-k8s-networking-guide.md)
- [Ingress 设置指南](operation-k8s-ingress-setup-guide.md)
- [负载均衡器配置](operation-load-balancer-port-configuration.md)

---

## 更新日志

- **2025-11-24**: 初始版本，包含完整的 nginx 调试与管理流程
- 添加常见问题排查和解决方法
- 添加配置模板和性能优化建议

---

## 联系和支持

如有问题或建议：
1. 查看 nginx 官方文档: https://nginx.org/en/docs/
2. 查看错误日志: `/var/log/nginx/error.log`
3. 联系 Oncall 团队















