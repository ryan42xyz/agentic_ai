

## get request/limit from prometheus
```
sum(
  kube_pod_container_resource_requests{
    kubernetes_cluster="aws-cacentral1-preprod-a",
    namespace!="kube-system",
    container!="",
    container!="POD",
    resource="cpu",
    unit="core"
  }
)

```