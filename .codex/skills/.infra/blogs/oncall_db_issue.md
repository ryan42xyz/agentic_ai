# yugabyte

ui:
```
http://172.27.35.54:31877/tablets
```

## yb-tserver 连不上，overload

调整 memory_limit_hard_bytes 
https://chatgpt.com/c/6923e0ca-f3c8-832d-bcf3-0240df4f1914
```sh
kubectl exec -it yb-tserver-0 -n qa-security -- bash

kubectl logs yb-tserver-0 -n qa-security --tail=100 -f 

kubectl get pod -n qa-security | grep yb

kubectl get pod yb-tserver-0 -n qa-security -o yaml | grep -i memory

kubectl edit sts yb-tserver -n qa-security
```



# clickhouse

# mysql 

# kafka

## 部署不上，反复重启

似乎是加载了半天 （但是还没加载完）
---> 探针时间太短 ---> 探针时间设置长一点
https://chatgpt.com/c/690c3577-97d0-8324-9fd8-b4228e498a31