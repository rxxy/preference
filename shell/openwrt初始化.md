# 初始化openwrt
 一步步来，搭建一个好用的openwrt系统
##

## 更换阿里源  
```
sed -i 's_downloads.openwrt.org_mirrors.aliyun.com/openwrt_' /etc/opkg/distfeeds.conf
```

## 扩容(squashfs)
https://juejin.cn/post/7248648256284901437#heading-3

## 基础软件
`opkg install luci-i18n-filemanager-zh-cn curl luci-i18n-base-zh-cn git-http`

## 主题
https://github.com/jerrykuku/luci-theme-argon

## openclash
https://github.com/vernesong/OpenClash/wiki/%E5%AE%89%E8%A3%85
> 按文档安装, 以下命令仅供参考  

`opkg install luci luci-base iptables  coreutils coreutils-nohup bash curl jsonfilter ca-certificates ipset ip-full iptables-mod-tproxy kmod-tun luci-compat`
> 安装dnsmasq-full需要先将dnsmasq卸载  

`opkg remove dnsmasq && opkg install dnsmasq-full`


## 局域网网卡唤醒
`opkg install luci-app-wol`

## wireguard
`opkg install luci-proto-wireguard`  
配置防火墙 入站数据 接受

## docker
`opkg install luci-i18n-dockerman-zh-cn`  
配置防火墙 docker 入站数据	出站数据	区域内转发都配置接受

## frpc(docker)
https://github.com/fatedier/frp  
https://gofrp.org/zh-cn/  

frps(服务端搭建)
```yaml
services:
  frp-server:
    container_name: "frp-server"
    image: snowdreamtech/frps:0.53.0
    environment:
      TZ: Asia/Shanghai
    ports:
      - 7500:7500
      - 7000:7000
      - 1236:1236/udp
    volumes:
      - ./frps.toml:/etc/frp/frps.toml
    restart: always
```

frps.toml
```toml
bind_port = 7000
vhostHTTPPort = 8080
auth.token = "tokenxxx"
log.level = "info"
webServer.addr="0.0.0.0"
webServer.port = 7500
webServer.user = "admin"
webServer.password = "xxx"
```

frpc(openwrt搭建)
```yaml
services:
  frpc:
    container_name: "frpc"
    image: snowdreamtech/frpc:0.53.0
    environment:
      TZ: Asia/Shanghai
    network_mode: host
    volumes:
      - ./frpc.toml:/etc/frp/frpc.toml
    restart: always
```
frpc.toml
```toml
auth.token = "tokenxxxxxx"
serverAddr = "x.x.x.x"
serverPort = 7000

[[proxies]]
name = "wireguard"
type = "udp"
localIP = "192.168.2.1"
localPort = xxx
remotePort = xxx
```
