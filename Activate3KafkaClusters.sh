#!/bin/bash

#========================= (Zookeeper、Broker1、Broker2的IP位置) =========================#
ipkafka4ZK=`docker inspect --format "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" kafka4ZK`  # 172.20.0.2
ipkafka4Br1=`docker inspect --format "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" kafka4Br1` # 172.20.0.3
ipkafka4Br2=`docker inspect --format "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" kafka4Br2` # 172.20.0.4
ipkafka4Br3=`docker inspect --format "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" kafka4Br3` # 172.20.0.5



#========================= (啟動Zookeeper服務)
docker exec -i kafka4ZK /bin/bash << ONION
cd /usr/kafka/kafka; bin/zookeeper-server-start.sh config/zookeeper.properties > /dev/null 2>&1 &
ONION


docker exec -i kafka4Br1 /bin/bash << ONION
#========================= (更改Broker1的參數設定)
sed -i "s/broker.id=0/broker.id=1/g" /usr/kafka/kafka/config/server.properties
sed -i "s/#listeners=PLAINTEXT:\/\/:9092/listeners=PLAINTEXT:\/\/$ipkafka4Br1:9092/g" /usr/kafka/kafka/config/server.properties
sed -i "s/zookeeper.connect=localhost:2181/zookeeper.connect=$ipkafka4ZK:2181/g" /usr/kafka/kafka/config/server.properties

#========================= (啟動Broker1服務)
cd /usr/kafka/kafka; bin/kafka-server-start.sh -daemon config/server.properties
ONION


docker exec -i kafka4Br2 /bin/bash << ONION
#========================= (更改Broker2的參數設定)
sed -i "s/broker.id=0/broker.id=2/g" /usr/kafka/kafka/config/server.properties
sed -i "s/#listeners=PLAINTEXT:\/\/:9092/listeners=PLAINTEXT:\/\/$ipkafka4Br2:9092/g" /usr/kafka/kafka/config/server.properties
sed -i "s/zookeeper.connect=localhost:2181/zookeeper.connect=$ipkafka4ZK:2181/g" /usr/kafka/kafka/config/server.properties

#========================= (啟動Broker2服務)
cd /usr/kafka/kafka; bin/kafka-server-start.sh -daemon config/server.properties
ONION


docker exec -i kafka4Br3 /bin/bash << ONION
#========================= (更改Broker3的參數設定)
sed -i "s/broker.id=0/broker.id=3/g" /usr/kafka/kafka/config/server.properties
sed -i "s/#listeners=PLAINTEXT:\/\/:9092/listeners=PLAINTEXT:\/\/$ipkafka4Br3:9092/g" /usr/kafka/kafka/config/server.properties
sed -i "s/zookeeper.connect=localhost:2181/zookeeper.connect=$ipkafka4ZK:2181/g" /usr/kafka/kafka/config/server.properties

#========================= (啟動Broker3服務)
cd /usr/kafka/kafka; bin/kafka-server-start.sh -daemon config/server.properties
ONION





sleep 5
#========================= (創建topic; 註: 不論在哪個叢集創建topic，只要是對同個zookeeper創建topic其效果都一樣，資料都是存在同個kafka叢集中)
docker exec -i kafka4ZK /bin/bash << ONION
cd /usr/kafka/kafka; bin/kafka-topics.sh --zookeeper $ipkafka4ZK:2181 --create --topic onionTopic1 --partitions 3 --replication-factor 3
ONION


docker exec -i kafka4Br1 /bin/bash << ONION
cd /usr/kafka/kafka; bin/kafka-topics.sh --zookeeper $ipkafka4ZK:2181 --create --topic onionTopic2 --partitions 3 --replication-factor 3
ONION


docker exec -i kafka4Br2 /bin/bash << ONION
cd /usr/kafka/kafka; bin/kafka-topics.sh --zookeeper $ipkafka4ZK:2181 --create --topic onionTopic3 --partitions 3 --replication-factor 3
ONION


#========================= (顯示目前該kafka之該zookeeper中所有topic的清單)
docker exec -i kafka4Br3 /bin/bash << ONION
cd /usr/kafka/kafka; bin/kafka-topics.sh --list --zookeeper $ipkafka4ZK:2181
ONION










#========================= (CONSUMER和PRODUCER在不同網域下的連接的成功範例測試) =========================#
#========================= (創建一個PRODUCER)
# docker run -td --rm --name PRODUCER --hostname PRODUCER --network=kafka4onion oniontraveler/kafka_container:19.5.20


#========================= (創建一個新網域HDSP4onion)
# docker network create -d bridge HDSP4onion
# docker network ls

#========================= (創建一個CONSUMER)
# docker run -td --rm --name CONSUMER --hostname CONSUMER --network=HDSP4onion oniontraveler/kafka_container:19.5.20
# docker network connect kafka4onion CONSUMER

# docker inspect --format "{{ .NetworkSettings.Networks.kafka4onion.IPAddress }}" CONSUMER
# docker inspect --format "{{ .NetworkSettings.Networks.HDSP4onion.IPAddress }}" CONSUMER
# docker inspect --format "{{range .NetworkSettings.Networks}} {{.IPAddress}}{{end}}" CONSUMER


#========================= (啟動CONSUMER和PRODUCER進行測試)
# docker exec -it PRODUCER /bin/bash
# cd /usr/kafka/kafka; bin/kafka-console-producer.sh --broker-list $ipkafka4Br1:9092 --topic onionTopic1

# docker exec -it CONSUMER /bin/bash
# cd /usr/kafka/kafka; bin/kafka-console-consumer.sh --zookeeper ipkafka4ZK:2181 --topic onionTopic1


#========================= (siao sheng miè ji)
# docker stop PRODUCER CONSUMER
# docker network rmHDSP4onion

