#!/bin/bash
read -p "输入y确认继续操作:"  i
if [ "$i" != y ];then
                exit
fi



#额外的磁盘初始化
initDisk(){
        read -p "请输入分区名(vdb):" pname
        fdisk /dev/${pname:="vdb"}
        exit
        mkfs -t ext4 /dev/sdb1
}


initDisk
