## pv
1. 查询 `pvscan` `pvdisplay`
2. 创建 `pvcreate /dev/xvdc`

## vg
1. 查询 `vgscan` `vgdisplay`
2. 创建 `vgcreate my_data /dev/sdb /dev/sdc`	#创建一个名为my_data的卷组并将sdb和sdc物理卷加入其中，PE的大小默认为4M
3. 扩展 `vgextend centos /dev/xvdc` #/dev/xvdc为加入vg的pv 

## lv
1. 查询 `lvscan` `lvdisplay`
2. 扩展 `lvextend -l +100%FREE /dev/centos/root` `lvextend -l +100G /dev/centos/root`


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

