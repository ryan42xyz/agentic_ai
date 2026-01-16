# aws 操作issue

## asg 实例弹不起来
asg 弹instance
```sh
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name aws-cacentral1-preprod-a-r7i.4xlarge \
  --launch-template "LaunchTemplateId=lt-0aeba6990b4a90c27,Version=8" \
  --region ca-central-1
```
临时解决
- 先让app 能够正常调度
    - 回滚
    - 用其他的 asg （如果之前正常执行过）

分析是哪个阶段的问题
1. instance 是否已经正常启动？
    - aws 的问题
        - asg
        - lt
2. instance 是否能够正常加入到集群？
    - user data (instance 启动时的一些命令)
        - 加到控制面，master lb / kubelet 部分的问题
    - 手动进入到 instance 中，
        检查 kubelet 是否正常启动，
        手动执行加入集群的命令

已知问题：
- user data base64 的问题
    - base64 是否打勾了?

典型的 user data
```sh
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
hostnamectl set-hostname $(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/hostname)

cp -f /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys

echo KUBELET_EXTRA_ARGS=\"--node-labels=nlb=true --cloud-provider=external\" >> /etc/default/kubelet
systemctl daemon-reload
kubeadm reset -f
kubeadm join aws-cacentral1-preprod-a-master-a9d76f50d18d2845.elb.ca-central-1.amazonaws.com:6443 --token d2dih1.irup9p0ka3m5gqyj --discovery-token-ca-cert-hash sha256:64fdb5dc175265a879b5700d0da6d93a2942b87d54a0386dbf26f20709f2996a

```