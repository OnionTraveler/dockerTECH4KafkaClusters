#!/bin/bash

# docker network rm kafka4onion
 [ `docker network ls | grep 'kafka4onion' | cut -d ' ' -f 9` ] && echo "The network 「kafka4onion」 has existed！" || docker network create -d bridge kafka4onion


 [ `docker images | grep 'oniontraveler/kafka_container' | cut -d ' ' -f 1,4 --output-delimiter=':'` ] && echo "The image 「oniontraveler/kafka_container:19.5.20」 has existed！" || docker build -f ./myDockerfiles/onionfile -t oniontraveler/kafka_container:19.5.20 .

 [ `docker ps -a | grep 'kafka4ZK' | rev | cut -d ' ' -f 1 | rev` ] && echo "The container 「kafka4ZK」 has existed" || docker run -itd --name kafka4ZK --hostname kafka4ZK --network=kafka4onion oniontraveler/kafka_container:19.5.20
 [ `docker ps -a | grep 'kafka4Br1' | rev | cut -d ' ' -f 1 | rev` ] && echo "The container 「kafka4Br1」 has existed" || docker run -id --name kafka4Br1 --hostname kafka4Br1 --network=kafka4onion oniontraveler/kafka_container:19.5.20
 [ `docker ps -a | grep 'kafka4Br2' | rev | cut -d ' ' -f 1 | rev` ] && echo "The container 「kafka4Br2」 has existed" || docker run -td --name kafka4Br2 --hostname kafka4Br2 --network=kafka4onion oniontraveler/kafka_container:19.5.20
 [ `docker ps -a | grep 'kafka4Br3' | rev | cut -d ' ' -f 1 | rev` ] && echo "The container 「kafka4Br3」 has existed" || docker run -td --name kafka4Br3 --hostname kafka4Br3 --network=kafka4onion oniontraveler/kafka_container:19.5.20



#========================= (docker commands for entering into the container(Zookeeper、Broker1、Broker2))
# docker exec -it kafka4ZK /bin/bash
# docker exec -it kafka4Br1 /bin/bash
# docker exec -it kafka4Br2 /bin/bash
# docker exec -it kafka4Br3 /bin/bash


