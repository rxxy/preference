## 更换阿里源
```
sed -i 's_downloads.openwrt.org_mirrors.aliyun.com/openwrt_' /etc/opkg/distfeeds.conf
```


```
opkg install luci-i18n-base-zh-cn
opkg install luci-i18n-opkg-zh-cn

opkg update
opkg install block-mount
```
## 扩容
#### 把软件包列表更新
`opkg update`
#### 安装分区软件
`opkg install cfdisk`
#### 使用cfdisk进行空间划分
`cfdisk /dev/mmcblk0`

`mkfs.ext4 /dev/mmcblk0p3`

```
opkg update
opkg install luci luci-base luci-compat
```
