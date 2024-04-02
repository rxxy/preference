## pv
1. 查询 `pvscan` `pvdisplay`
2. 创建 `pvcreate /dev/xvdc`
3. 删除 `pvremove /dev/xvdc`

## vg
1. 查询 `vgscan` `vgdisplay`
2. 创建 `vgcreate my_data /dev/sdb /dev/sdc`	#创建一个名为my_data的卷组并将sdb和sdc物理卷加入其中，PE的大小默认为4M
3. 扩展 `vgextend centos /dev/xvdc` #/dev/xvdc为加入vg的pv
4. 删除 `vgremove centos`

## lv
1. 查询 `lvscan` `lvdisplay`
2. 扩展 `lvextend -l +100%FREE /dev/centos/root` `lvextend -l +100G /dev/centos/root`
3. 删除 `lvremove /dev/centos/root` #需先卸载文件系统

### 加入新磁盘扩展分区

1. 新建分区
   使用fdisk或gdisk创建好分区(无需格式化)
2. 使用创建好的分区创建pv
3. 将新的pv加入到指定的vg中
4. 扩展lv 
5. 扩展分区  
for xfs filesystem  
`xfs_growfs /dev/centos/root`  
for ext4 filesystem  
`resize2fs /dev/centos/root`

### 缩容
1. 卸载分区
` umount /dev/openeuler/home`
2. 调整文件系统大小  
for ext4 filesystem  
`resize2fs /dev/openeuler/home 200G`  
for xfs filesystem  
`xfs_growfs /dev/openeuler/home 200G`
3. 调整逻辑卷大小  
`lvreduce -L -500G /dev/openeuler/home` 或 `lvreduce -L 200G /dev/openeuler/home`
4. 挂载分区  
`mount /dev/openeuler/home /home`

### 扩容
1. 扩展分区  
`lvextend -L +500G /dev/mapper/openeuler-root` 或 `lvextend -L 800G /dev/mapper/openeuler-root`
2. 扩展文件系统  
for ext4 filesystem  
`resize2fs /dev/mapper/openeuler-root`  
for xfs filesystem  
`xfs_growfs /dev/mapper/openeuler-root`










