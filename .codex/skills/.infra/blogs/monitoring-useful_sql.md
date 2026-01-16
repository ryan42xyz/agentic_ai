```
group by (client, kubernetes_cluster) (
  {__name__=~"controller:Health_UpTime|record:loki_kubernetes_monitoring_request_1m_qps_ingress_nginx|prod_job_finish_time"}
)

count by (client) (prod_job_finish_time)

topk(1, prod_job_finish_time)
```
```
[
  {
    "metric": {
      "client": "acorns"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "affirm"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "affirmca"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "airasia"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "appsflyer"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "argo"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "aspiration"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "bdc"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "beemcu"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "binance"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "blibli"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "bookingcom"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "brighthorizons"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "brighthorizonstest"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "clientless"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "cuoc"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "dcubeluigi"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "eqbank"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "flutterwave"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "galileo"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "ifcuprod"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "issuingbankdemo"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "mercari"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "moonpay"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "musicallyua"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "mybambu"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "nasa"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "navan"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "neo"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "offerup"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "okcoin"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "okg"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "okx"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "onefinance"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "pefcu"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "plooto"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "q6"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "q6integrationtest"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "rippling"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "snapprod"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "sofi"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "sphere"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "standardbank"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "standardbank2"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "syncbank"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "tabapay"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "taskrabbit"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "transfergo"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "umlenterprise"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "uopx"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "uopxtest"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "walmart"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "walmarttest"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "westernunion"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "westernunionib"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "wex"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  },
  {
    "metric": {
      "client": "wexsandbox"
    },
    "value": [
      1765418929.039,
      "1"
    ],
    "group": 1
  }
]
```
