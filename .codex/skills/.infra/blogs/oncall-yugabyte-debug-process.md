# yugabyte
https://chatgpt.com/c/694bd80e-c608-8327-a601-19a66282ae09

现在都泡在外面
node ip + 9000 port -- tserver ui

ss -lntp | grep yb-tserver
你通常会看到类似：

9000 → tserver Web UI

9100 → RPC

12000 → YCQL

5433 → YSQL

2️⃣ 本机 curl（不依赖浏览器）
bash
Copy code
curl http://127.0.0.1:9000


http://172.30.109.188:9000/utilz