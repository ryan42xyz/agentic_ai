# marqeta (fit for general)

## Alert Manager

network traffic too much
```
node=10.15.150.18:19100 device=ens5 network output  > 300Mbps ##### Value=315.9
node=10.15.158.165:19100 device=ens5 network output  > 300Mbps ##### Value=538
Click https://eng.datavisor.com/#/alert to check all alerts status.
Click https://eng.datavisor.com/#/alert to check all alerts status.
```

These two nodes are YB node. Should be OK.
Marqeta traffic keeps at ~1k QPS. Their traffic is high. YB node load looks good. (edited) 

1. check network traffic / QPS？
   1. 一直如此？如果是，也不用太担心
2. sla 表现怎么样？
   1. 如果 100%，也ok

3. check yb (backend database)
   1. cpu / mem / disk

![](./pic/marqeta-qps1.png)
![](./pic/marqeta-yb-cpu-mem.png)
![](./pic/marqeta-yb-cpu-mem-2.png)
![](./pic/marqeta-sla.png)