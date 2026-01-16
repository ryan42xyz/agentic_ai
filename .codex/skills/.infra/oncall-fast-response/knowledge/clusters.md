# Kubernetes Clusters & Aliases

This file lists known clusters and kubectl aliases.

Rules:
- Reference only
- Never infer cluster scope unless mentioned in alert
- Use aliases to access clusters, but generate commands only (do not execute)

## Known Clusters

- aws-apsoutheast1-prod-a
- aws-apsoutheast1-prod-b
- aws-cacentral1-preprod-a
- k8s-aws-uswest2-sandbox-a
- aws-uswest2-sandbox-b
- k8s-aws-us-dev-a
- aws-uswest2-dev-b
- aws-useast1-dev-c
- aws-useast1-mgt-a
- k8s-aws-useast1-prod-a
- k8s-aws-useast1-prod-b
- aws-euwest1-prod-a
- aws-useast1-pcipreprod-a
- k8s-aws-uswest2-sandbox-a
- k8s-aws-uswest2-mgt-a
- aws-uswest2-preprod-a
- aws-uswest2-prod-a
- aws-uswest2-prod-b

## Kubectl Aliases

### Africa Clusters
- `kafsouthproda` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/af_prod_a.config
- `kafsouthprodb` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/af_prod_b.config
- `kafsouthpreprod` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/af_preprod_a.config

### US West Clusters
- `kwestdeva` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/dev_a.config
- `kwestdevb` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/dev_b.config
- `kwestproda` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/us_prod_a.config
- `kwestprodb` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/us_prod_b.config
- `kwestmgt` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/us_mgt.config
- `kwestpreprod` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/us_preprod_a.config
- `kwestdemoa` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/us_demo_a.config
- `kwestdemob` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/demo_b.config

### US East Clusters
- `keastdevc` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/dev_c.config
- `keastproda` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/east_prod_a.config
- `keastprodb` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/east_prod_b.config
- `keastmgt` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/east_mgt.config
- `keastpreprod` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/east_preprod_a.config

### EU Clusters
- `keuwestproda` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/eu_prod_a.config
- `keuwestprodb` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/eu_prod_b.config
- `keuwest2prodb` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/eu_west2_prod_b.config

### PCI Clusters
- `keastpcia` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/pci_a.config
- `keastpcib` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/pci_b.config
- `keastpcipreprod` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/pci_preprod_a.config

### Singapore Clusters
- `ksga` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/sg_prod_a.config
- `ksgb` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/sg_prod_b.config
- `kasiasedcube` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/sg_dcube.config

### GCP Clusters
- `kgcpwestpoca` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/poc_a.config
- `kgcpwestpocb` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/poc_b.config
- `kgcpwestproda` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/gcp_us_prod_a.config
- `kgcpwesttrial` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/gcp_us_trial_a.config

### CA Clusters
- `kcaproda` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/ca_prod_a.config
- `kcaprodb` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/ca_prod_b.config
- `kcapreprod` - kubectl --kubeconfig=/Users/rshao/work/code_repos/infra_oncall_mgt/config/kubeconfig/ca_preprod_a.config

## Usage

- Use aliases to generate kubectl commands, but never execute automatically
- Extract cluster name from alert text to select appropriate alias
- Never infer cluster scope unless explicitly mentioned in alert
