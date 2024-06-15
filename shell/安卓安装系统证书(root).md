pem证书转.cer证书
openssl x509 -outform der -in ca.pem -out ca.cer
cer证书转.pem证书
openssl x509 -inform der -in ca.cer -out ca.pem
adb.exe devices
nox_adb.exe root
adb remount
openssl x509 -subject_hash_old -in ca.pem 
adb push 9a5ba575.0 /system/etc/security/cacerts/



1. 安卓中需要pem格式证书，cer测试无效
2. 必须root后remount重新挂在目录为rw



# 模拟器导入证书
1. 导出der证书
2. 转换证书格式，转换为pem
```
openssl x509 -inform der -in ouo.der -out ouo.pem
```
3. 计算证书hash
```
openssl x509 -subject_hash_old -in ouo.pem
```
4. 将文件名重命名为hash.0
5. 将文件拷贝到模拟器目录`/etc/security/cacerts/`
6. 修改文件权限为777
7. 进入手机证书页面查看证书是否安装成功
