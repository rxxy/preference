## 安装
https://www.wireguard.com/install

## 配置
### 开启转发
```
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p
```
### 配置服务端
```
mkdir -p /etc/wireguard && chmod 0777 /etc/wireguard
cd /etc/wireguard
umask 077
wg genkey | tee server_privatekey | wg pubkey > server_publickey
wg genkey | tee client_privatekey | wg pubkey > client_publickey

echo "
[Interface]
PrivateKey = $(cat server_privatekey) # 填写本机的privatekey 内容
Address = 192.168.8.1/24
# 未测试
#PostUp   = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
# 另一篇博文里的 未测试
#PostUp = iptables -A FORWARD -i wg0 -j ACCEPT && iptables -t nat -A POSTROUTING -s 192.168.8.0/24 -o eth0 -j MASQUERADE && iptables -A INPUT -i wg0 -p udp --dport 50814 -j ACCEPT
#PostDown = iptables -D FORWARD -i wg0 -j ACCEPT && iptables -t nat -D POSTROUTING -s 192.168.8.0/24 -o eth0 -j MASQUERADE && iptables -D INPUT -i wg0 -p udp --dport 50814 -j ACCEPT

PostUp     = firewall-cmd --zone=public --add-port 50814/udp && firewall-cmd --zone=public --add-masquerade
PostDown   = firewall-cmd --zone=public --remove-port 50814/udp && firewall-cmd --zone=public --remove-masquerade

ListenPort = 50814 # 注意该端口是UDP端口
DNS = 8.8.8.8
MTU = 1420
[Peer]
PublicKey =  $(cat client_publickey)  # 填写对端的publickey 内容
AllowedIPs = 192.168.8.2/32 " > wg0.conf

systemctl enable wg-quick@wg0

```
### 生成客户端证书
```
echo "
[Interface]
  PrivateKey = $(cat client_privatekey)  # 填写本机的privatekey 内容
  Address = 192.168.8.2/24
  DNS = 8.8.8.8
  MTU = 1420

[Peer]
  PublicKey = $(cat server_publickey)  # 填写对端的publickey 内容
  Endpoint = server公网的IP:50814
  AllowedIPs = 0.0.0.0/0, ::0/0
  PersistentKeepalive = 25 " > client.conf

```
### 启动
```
wg-quick up wg0
```

参考  
1. [WireGuard VPN 設定與使用教學](https://notes.wadeism.net/post/learning-wireguard-vpn/)  
2. [组网神器WireGuard安装与配置教程（超详细）](https://blog.csdn.net/qq_20042935/article/details/127089626)
