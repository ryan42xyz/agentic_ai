https://mail.google.com/mail/u/0/#inbox/FMfcgzQZTzSKzLksFPTggMkqRfqFTTTh

The following is the goal of the probation period after our discussion. I will assist you to complete the goal throughout the process. If you have any questions, please contact me directly.


1. Learning infra existing monitoring architecture (Prometheus/alertmanager/Victoria/Loki) and being able to add and modify monitoring configuration.

2. Read the dcluster code to understand the logic of how dcluster creates and destroys a flink/spark cluster. I hope you can optimize and transform dcluster through learning.

3. Read the dApp code. Understand the whole project structure.

3.1 Read code to sort out the logic of switch traffic and autoSwitch traffic.

3.2 Sort out the functional logic of application release by reading code.

4. Learn the existing jenkins configuration method and architecture, then read the pipeline and be able to modify the main job logic of the Jenkins pipeline

5. Learn how k8s is deployed in our environment. Then learn the core component principles of k8s, and then learn how k8s interacts with aws. Which components are interacting with aws. How is it integrated.

6. Familiarize yourself with which applications are included in the datavisor platform and the call relationships between these applications.

7. Be able to participate in oncall and handle 80% types of oncall tickets

---

1. architecture 
   1. 架构 / 数据流转
      1. fp
      2. metadata
      3. sdg 一套
2. onboarding
```md
1. Learning infra existing monitoring architecture (Prometheus/alertmanager/Victoria/Loki) and being able to add and modify monitoring configuration.
    - 如何加app，开放 /metrics，让现有 vm 抓到
2. Read the dcluster code to understand the logic of how dcluster creates and destroys a flink/spark cluster. I hope you can optimize and transform dcluster through learning.
    - terminate job
    - dashboard
        - https://eng-mgt-a.dv-api.com/oncall/logs/production-job?area=aws-uswest2-prod_a_prod
    - commands:
        - `curl -X POST http://dcluster-useast1-prod-b-prod.dv-api.com /cluster/job/terminate/570232`
3. Read the dApp code. Understand the whole project structure.
    - switch traffic 
        - switch 了哪些东西？
    3.1 Read code to sort out the logic of switch traffic and autoSwitch traffic.

    3.2 Sort out the functional logic of application release by reading code.

4. Learn the existing jenkins configuration method and architecture, then read the pipeline and be able to modify the main job logic of the Jenkins pipeline
    - jenkins 改了很多东西
5. Learn how k8s is deployed in our environment. Then learn the core component principles of k8s, and then learn how k8s interacts with aws. Which components are interacting with aws. How is it integrated.
    - [] charts / dapp / deploy (release?) 这一套是怎么交互工作的？
6. Familiarize yourself with which applications are included in the datavisor platform and the call relationships between these applications.
    - fp
    - metadata
    - sdg 一套
7. Be able to participate in oncall and handle 80% types of oncall tickets
    - yb 的问题
    - clickhouse 的问题
```

3. kafka 里面哪些topic 怎么看？
   1. 典型的 velocity https://grafana-mgt.dv-api.com/d/cluster_kafkfa_exporter/kafka-exporter-for-all?orgId=1&var-PromDs=vms-victoria-metrics-single-server&var-job=kubernetes-pods&var-cluster=aws-apsoutheast1-prod-b&var-namespace=prod&var-pod=kafka3-exporter-5868d985bd-jwrm2&var-topic=All&var-consumergroup=velocity.prod_b&from=1750142464193&to=1750144381702
