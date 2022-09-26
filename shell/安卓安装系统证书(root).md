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
