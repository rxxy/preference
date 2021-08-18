#!/bin/bash

# 预检
preCheck(){
    version=$(rpm -q centos-release)
    echo "系统版本: $version"
    if [[ "" != "$(echo $version | grep centos-release-8)" ]];then
        echo "预检失败，不支持centos8"
        exit
    fi
}


#额外的磁盘初始化
initDisk(){
        read -p "请输入分区名(vdb):" pname
        fdisk /dev/${pname:="vdb"}
        exit
        mkfs -t ext4 /dev/sdb1
}

# 安装docker
installDocker(){
    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    # centos8
    yum makecache
    yum erase podman buildah -y
    # centos7
    #    yum makecache fast
    yum -y install docker-ce
    systemctl enable docker

    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose	
	
    mkdir -p /etc/docker
    tee /etc/docker/daemon.json << EOF
{
  "registry-mirrors": ["https://2v383cca.mirror.aliyuncs.com"]
}
EOF

    systemctl daemon-reload
    systemctl restart docker

# service docker start

}

installAcme(){
    curl  https://get.acme.sh | sh -s email=891841484@qq.com
}

installTool(){
    yum install -y epel-release tmux htop
    yum install -y lrzsz
}



#preCheck

read -p "预检成功，请输入y确认继续操作:"  i
if [ "$i" != y ];then
                exit
fi

# initDisk
installDocker
installAcme
installTool
