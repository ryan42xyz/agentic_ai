# client:
```
refer picture
```
# grafana dashboard 
可以替换参数和timewindow
https://grafana-mgt.dv-api.com/d/X2qhqpjSk/multi-cluster-traffic-distribution?orgId=1&var-cluster=aws-uswest2-prod&var-client=All&var-interface=All&from=1768041967000&to=1768046797640

https://grafana-mgt.dv-api.com/d/b_XlLjRMz/pod-resources?orgId=1&from=now-2h&to=now&var-PromDs=prometheus-pods&var-cluster=aws-uswest2-prod-a&var-namespace=prod&var-pod=fp-deployment-957745bf6-wdrqx&var-containers=fp

https://grafana-mgt.dv-api.com/d/p1KqfRAMk/sla-batch-and-realtime?orgId=1&var-PromDs=vms-victoria-metrics-single-server&var-client=sofi&var-sandbox_client=airasia&var-pipeline=&var-Batch_Pipeline=prod.awsus&from=now-6h&to=now

https://grafana-mgt.dv-api.com/d/1IGjQaiMk/yugabytedb?orgId=1&var-PromDs=vms-victoria-metrics-single-server&var-cluster=aws-uswest2-prod-a&var-dbcluster=prod-external-new-1&var-node=All&var-nodeInstance=172.31.35.20:7000&var-serverNode=All&var-serverNodeInstance=172.31.35.20:9000

https://grafana-mgt.dv-api.com/d/0lpCu9kHk/apisix-logging?orgId=1&from=now-3h&to=now&var-cluster=aws-uswest2-prod&var-client=sofi&var-search=

https://grafana-mgt.dv-api.com/d/HFAlVh2Nz/debug-logs-for-ingress-nginx-controller?orgId=1&var-cluster=aws-uswest2-prod-a&var-client=sofi&var-interface=All&var-status_code=200&var-request_time_operator=%3E&var-request_time_prerequisite=0&var-upstream_response_time_operator=%3E&var-upstream_response_time_prerequisite=0.005

# logging 
https://grafana-mgt.dv-api.com/d/9aBY8rWMz/logging?orgId=1

# vm alert
https://vm-mgt-a.dv-api.com/vmalert/api/v1/rules
https://vm-mgt-a.dv-api.com/vmalert/api/v1/alerts

# aws cli

永远允许：get, describe, logs, top, diff, lint, test, fmt

默认拒绝：delete, patch, apply, scale, rollout restart

允许但必须人工接管：任何对 prod 有写入的动作（哪怕看似安全）

hooks：不要自己执行命令，生成命令，供我使用

# k8s 
cluster:
```
❯ cat *.config | grep "cluster: "
    cluster: aws-apsoutheast1-prod-b
    cluster: aws-cacentral1-preprod-a
    cluster: aws-cacentral1-preprod-a
    cluster: k8s-aws-uswest2-sandbox-a
    cluster: aws-uswest2-sandbox-b
    cluster: k8s-aws-us-dev-a
    cluster: aws-uswest2-dev-b
    cluster: aws-useast1-dev-c
    cluster: aws-useast1-mgt-a
    cluster: k8s-aws-useast1-prod-a
    cluster: k8s-aws-useast1-prod-b
    cluster: aws-euwest1-prod-a
    cluster: aws-useast1-pcipreprod-a
    cluster: aws-apsoutheast1-prod-a
    cluster: aws-apsoutheast1-prod-b
    cluster: k8s-aws-uswest2-sandbox-a
    cluster: k8s-aws-uswest2-mgt-a
    cluster: aws-uswest2-preprod-a
    cluster: aws-uswest2-prod-a
    cluster: aws-uswest2-prod-b
```
multiple cluster, can use:

永远允许：get, describe, logs, top, diff, lint, test, fmt

默认拒绝：delete, patch, apply, scale, rollout restart

允许但必须人工接管：任何对 prod 有写入的动作（哪怕看似安全）

hooks：不要自己执行命令，生成命令，供我使用
```

############# k8s cluster aliases #############
# Kubernetes cluster aliases
# Africa clusters
alias kafsouthproda="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/af_prod_a.config"
alias kafsouthprodb="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/af_prod_b.config"
alias kafsouthpreprod="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/af_preprod_a.config"

# US West clusters
alias kwestdeva="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/dev_a.config"
alias kwestdevb="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/dev_b.config"
alias kwestproda="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/us_prod_a.config"
alias kwestprodb="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/us_prod_b.config"
alias kwestmgt="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/us_mgt.config"
alias kwestpreprod="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/us_preprod_a.config"
alias kwestdemoa="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/us_demo_a.config"
alias kwestdemob="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/demo_b.config"
# US East clusters
alias keastdevc="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/dev_c.config"
alias keastproda="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/east_prod_a.config"
alias keastprodb="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/east_prod_b.config"
alias keastmgt="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/east_mgt.config"
alias keastpreprod="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/east_preprod_a.config"

# EU clusters
alias keuwestproda="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/eu_prod_a.config"
alias keuwestprodb="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/eu_prod_b.config"
alias keuwest2prodb="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/eu_west2_prod_b.config"

# PCI clusters
alias keastpcia="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/pci_a.config"
alias keastpcib="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/pci_b.config"
alias keastpcipreprod="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/pci_preprod_a.config"

# Singapore clusters
alias ksga="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/sg_prod_a.config"
alias ksgb="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/sg_prod_b.config"
alias kasiasedcube="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/sg_dcube.config"

# GCP clusters
alias kgcpwestpoca="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/poc_a.config"
alias kgcpwestpocb="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/poc_b.config"
alias kgcpwestproda="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/gcp_us_prod_a.config"
alias kgcpwesttrial="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/gcp_us_trial_a.config"

# CA
alias kcaproda="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/ca_prod_a.config"
alias kcaprodb="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/ca_prod_b.config"
alias kcapreprod="kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/ca_preprod_a.config"

```