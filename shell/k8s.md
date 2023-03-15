```
sudo yum update -y

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

<!-- 通过运行以下指令确认 br_netfilter 和 overlay 模块被加载： -->
sudo sysctl --system
<!-- 通过运行以下指令确认 net.bridge.bridge-nf-call-iptables、net.bridge.bridge-nf-call-ip6tables 和 net.ipv4.ip_forward 系统变量在你的 sysctl 配置中被设置为 1： -->
lsmod | grep br_netfilter
lsmod | grep overlay
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

<!-- 关闭swap分区 -->
swapoff -a
vi /etc/fstab

<!-- 下面应该不调整也没关系 -->
echo 0 > /proc/sys/vm/swappiness # 临时生效

vim /etc/sysctl.conf # 永久生效
#修改 vm.swappiness 的修改为 0
vm.swappiness=0
sysctl -p # 使配置生效

echo n1 > /etc/hostname
```

```
<!-- 安装containerd -->
<!-- https://github.com/containerd/containerd/blob/main/docs/getting-started.md -->
wget https://github.com/containerd/containerd/releases/download/v1.6.16/containerd-1.6.16-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-1.6.16-linux-amd64.tar.gz
mkdir -p /usr/local/lib/systemd/system/
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -O /usr/lib/systemd/system/containerd.service
systemctl daemon-reload
systemctl enable --now containerd

wget https://github.com/opencontainers/runc/releases/download/v1.1.4/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc


wget https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-amd64-v1.2.0.tgz
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.2.0.tgz

mkdir  /etc/containerd/
containerd config default > /etc/containerd/config.toml

<!-- 配置 systemd cgroup 驱动 -->
<!-- 结合 runc 使用 systemd cgroup 驱动，在 /etc/containerd/config.toml 中设置： -->

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  ...
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true


[plugins."io.containerd.grpc.v1.cri"]
  sandbox_image = "registry.k8s.io/pause:3.2"

sudo systemctl restart containerd

rm -f containerd-1.6.16-linux-amd64.tar.gz runc.amd64 cni-plugins-linux-amd64-v1.2.0.tgz
```

```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
setenforce 0
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet

```


```
cat <<EOF >  kubeadm-config.yaml
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta3
kubernetesVersion: v1.26.1
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd
EOF

# 查看安装所需镜像
kubeadm config images list

# 从为阿里云镜像拉取
ctr -n k8s.io images pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.26.1
ctr -n k8s.io images pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.26.1
ctr -n k8s.io images pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.26.1
ctr -n k8s.io images pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.26.1
ctr -n k8s.io images pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.9
ctr -n k8s.io images pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.5.6-0
ctr -n k8s.io images pull registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:v1.9.3

# 改镜像名

ctr -n k8s.io images tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.26.1 registry.k8s.io/kube-apiserver:v1.26.1
ctr -n k8s.io images tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.26.1 registry.k8s.io/kube-controller-manager:v1.26.1
ctr -n k8s.io images tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.26.1 registry.k8s.io/kube-scheduler:v1.26.1
ctr -n k8s.io images tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.26.1 registry.k8s.io/kube-proxy:v1.26.1
ctr -n k8s.io images tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.9 registry.k8s.io/pause:3.9
ctr -n k8s.io images tag registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.5.6-0 registry.k8s.io/etcd:3.5.6-0
ctr -n k8s.io images tag registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:v1.9.3 registry.k8s.io/coredns/coredns:v1.9.3

# 删除阿里云镜像
ctr -n k8s.io images rm registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.26.1
ctr -n k8s.io images rm registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.26.1
ctr -n k8s.io images rm registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.26.1
ctr -n k8s.io images rm registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.26.1
ctr -n k8s.io images rm registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.9
ctr -n k8s.io images rm registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.5.6-0
ctr -n k8s.io images rm registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:v1.9.3

```

```
<!-- worker机器 -->
ctr -n k8s.io images pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.26.1
ctr -n k8s.io images pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.9
ctr -n k8s.io images pull registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:v1.9.3

ctr -n k8s.io images tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.26.1 registry.k8s.io/kube-proxy:v1.26.1
ctr -n k8s.io images tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.9 registry.k8s.io/pause:3.9
ctr -n k8s.io images tag registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:v1.9.3 registry.k8s.io/coredns/coredns:v1.9.3

ctr -n k8s.io images rm registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.26.1
ctr -n k8s.io images rm registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.9
ctr -n k8s.io images rm registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:v1.9.3

```



```
<!-- 端口转发 -->
firewall-cmd --permanent --add-port=6443/tcp && sudo firewall-cmd --permanent --add-port=10250/tcp && sudo firewall-cmd --reload

kubeadm init --pod-network-cidr=10.244.0.0/16 --config kubeadm-config.yaml 

<!-- init不带cidr参数还需要在这里额外修改配置 -->
vi /etc/kubernetes/manifests/kube-controller-manager.yaml
--allocate-node-cidrs=true
--cluster-cidr=10.244.0.0/16

<!-- 安装网络插件 -->
<!-- 下载下来改ip，和init时一致 -->
wget https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl apply -f kube-flannel.yml


 # 在 bash 中设置当前 shell 的自动补全，要先安装 bash-completion 包。
yum install -y bash-completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc

alias k=kubectl
complete -o default -F __start_kubectl k

```
### 污点
```
<!-- 你可以使用命令 kubectl taint 给节点增加一个污点。比如， -->
kubectl taint nodes node1 key1=value1:NoSchedule

<!-- 给节点 node1 增加一个污点，它的键名是 key1，键值是 value1，效果是 NoSchedule。 这表示只有拥有和这个污点相匹配的容忍度的 Pod 才能够被分配到 node1 这个节点。 -->

<!-- 若要移除上述命令所添加的污点，你可以执行： -->
kubectl taint nodes node1 key1=value1:NoSchedule-
```


###  别名
```
<!-- 设置或显示 context / namespace 的短别名 -->
<!-- （仅适用于 bash 和 bash 兼容的 shell，在使用 kn 设置命名空间之前要先设置 current-context） -->
alias kx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
alias kn='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'
```

curl http://localhost:8001/api/v1/namespaces/[namespace-name]/services/[service-name]/proxy


 kubectl port-forward TYPE/NAME [options] [LOCAL_PORT:]REMOTE_PORT [...[LOCAL_PORT_N:]REMOTE_PORT_N]