
## 磁盘操作

fdisk /dev/vdb  
mkfs -t ext4 /dev/sdb1   
https://blog.csdn.net/wh445306/article/details/100932430

## 安装docker
# step 1: 安装必要的一些系统工具
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
# Step 2: 添加软件源信息
sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# Step 3: 更新并安装Docker-CE
sudo yum makecache fast
sudo yum -y install docker-ce
# Step 4: 开启Docker服务
sudo systemctl enable docker

ln -s /data/var-lib-docker/ /var/lib/docker

curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

```
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://2v383cca.mirror.aliyuncs.com"]
}
EOF
```
sudo systemctl daemon-reload  
sudo systemctl restart docker  



## ssl
curl https://get.acme.sh | sh
acme.sh --issue -d domain.com -w /data/var-lib-docker/volumes/andvids-en_andvids-en/_data

## 常用工具
yum install -y tmux
yum -y install lrzsz  
