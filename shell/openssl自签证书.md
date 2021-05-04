
### 生成CA根证书
ca.conf

```
[ req ]
default_bits       = 4096
distinguished_name = req_distinguished_name

[ req_distinguished_name ]
countryName                 = Country Name (2 letter code)
countryName_default         = CN
stateOrProvinceName         = State or Province Name (full name)
stateOrProvinceName_default = HeBei
localityName                = Locality Name (eg, city)
localityName_default        = ZhangJiaKou
organizationName            = Organization Name (eg, company)
organizationName_default    = Rxxy
commonName                  = Common Name (e.g. server FQDN or YOUR name)
commonName_max              = 64
commonName_default          = Rxxy
```

生成私钥、签发请求文件、证书文件
```
openssl genrsa -out ca.key 4096

openssl req \
  -new \
  -sha256 \
  -out ca.csr \
  -key ca.key \
  -config ca.conf

openssl x509 \
    -req \
    -days 3650 \
    -in ca.csr \
    -signkey ca.key \
    -out ca.crt
```

### 签发终端证书

server.conf

```
[ req ]
default_bits       = 2048
distinguished_name = req_distinguished_name
req_extensions     = req_ext

[ req_distinguished_name ]
countryName                 = Country Name (2 letter code)
countryName_default         = CN
stateOrProvinceName         = State or Province Name (full name)
stateOrProvinceName_default = HeBei
localityName                = Locality Name (eg, city)
localityName_default        = ZhangJiaKou
organizationName            = Organization Name (eg, company)
organizationName_default    = Rxxy
commonName                  = Common Name (e.g. server FQDN or YOUR name)
commonName_max              = 64
commonName_default          = rxxy.icu

[ req_ext ]
subjectAltName = @alt_names

[alt_names]
DNS.1   = rxxy.icu
DNS.2   = *.rxxy.icu
DNS.3   = rxxy.pi
DNS.4   = *.rxxy.pi
IP.1    = 192.168.2.170
```

生成私钥、签发请求文件、证书文件
```
openssl genrsa -out server.key 2048

openssl req \
  -new \
  -sha256 \
  -out server.csr \
  -key server.key \
  -config server.conf

openssl x509 \
  -req \
  -days 3650 \
  -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -in server.csr \
  -out server.crt \
  -extensions req_ext \
  -extfile server.conf
```
