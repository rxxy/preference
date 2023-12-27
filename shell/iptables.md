## 端口转发

### 开启ipv4转发
```
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
sysctl -p
```

### 使用本地服务器的60000端口来转发目标IP为1.1.1.1的50000端口
```
iptables -t nat -A PREROUTING -p tcp -m tcp --dport 60000 -j DNAT --to-destination 1.1.1.1:50000
iptables -t nat -A PREROUTING -p udp -m udp --dport 60000 -j DNAT --to-destination 1.1.1.1:50000
iptables -t nat -A POSTROUTING -d 1.1.1.1/32 -p tcp -m tcp --dport 50000 -j SNAT --to-source [本地服务器IP]
iptables -t nat -A POSTROUTING -d 1.1.1.1/32 -p udp -m udp --dport 50000 -j SNAT --to-source [本地服务器IP]
```
