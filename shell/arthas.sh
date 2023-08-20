#!/bin/bash
docker exec -it 容器ID /bin/bash -c "wget https://arthas.aliyun.com/arthas-boot.jar && java -jar arthas-boot.jar"
