#!/bin/bash

# Clean up all containers and scripts
count=$(docker ps -q | wc -l)

docker rm -f controller1
docker rm -f controller2
docker rm -f controller3
docker rm -f ihs1
docker rm -f ihs2
docker-compose down
rm -f plugin-cfg.xml
rm -f plugin-key.jks


# Get project name
project=${PWD##*/}

# Create the network
result=$(docker network ls | grep $project | wc -l)
if [ $result -gt 0 ]
    then
        echo "Cleaning up existing network"
        docker network rm $project
fi

echo "Creating new $project network"
docker network create --driver=overlay $project

# Pull images
docker pull wasdev/sample-ihscollective:controller
docker pull wasdev/sample-ihscollective:ihs

# Run controller instances
echo "Creating controller1 and controller2"
controller1=$(docker run -dP -e "HOSTNAME=controller1" --name controller1 --net="$project" --net-alias controller wasdev/sample-ihscollective:controller)
controller2=$(docker run -dP -e "HOSTNAME=controller2" --net="$project" --net-alias controller --name controller2 wasdev/sample-ihscollective:controller)

# Wait for controller2 to finish setting up
result=0
while [ $result -eq 0 ]
do
    echo "Waiting for controller2 to finish setting up"
    sleep 10
    result=$(docker logs controller2 |& grep -s "CWWKE0001I" | wc -l)
done

# Then start container 3
controller3=$(docker run -dP -e "HOSTNAME=controller3" --net="$project" --net-alias controller --name controller3 wasdev/sample-ihscollective:controller)

# Run IHS instances
docker run -h ihs -p 80:80 -d -t  --name ihs1 --net="$project" wasdev/sample-ihscollective:ihs
docker run -h ihs -p 80:80 -d -t  --name ihs2 --net="$project" wasdev/sample-ihscollective:ihs

# Wait for controller 3 to finish generating the plugin-cfg.xml
result=0
while [ $result -eq 0 ]
do
    echo "Waiting for controller3 to finish setting up"
    sleep 10
    result=$(docker logs controller3 |& grep -s "CWWKE0001I" | wc -l)
done

sleep 10

# Get the config
docker exec controller1 bash -c 'export JVM_ARGS=-Dcom.ibm.websphere.collective.utility.autoAcceptCertificates=true && /opt/ibm/wlp/bin/dynamicRouting genKeystore --port=9443 --host=$HOSTNAME --user=admin --password=adminpwd --keystorePassword=controllerKSpassword'
docker cp controller3:plugin-cfg.xml .
docker cp controller1:plugin-key.jks .

# Configure each IHS instance
for (( i=1; i<=2; i++ ))
do
    echo "Copying in certs and config for ihs$i"
    docker cp plugin-cfg.xml ihs$i:/tmp/plugin-cfg.xml
    docker cp plugin-key.jks ihs$i:/tmp/plugin-key.jks

    echo "Reconfiguring ihs$i"
    docker exec ihs$i bash -c 'cd /tmp/ && /opt/IBM/HTTPServer/bin/gskcmd -keydb -convert -pw controllerKSpassword -db plugin-key.jks -old_format jks -target plugin-key.kdb -new_format cms -stash -expire 365'
    docker exec ihs$i bash -c 'cd /tmp/ && /opt/IBM/HTTPServer/bin/gskcmd -cert -setdefault -pw controllerKSpassword -db plugin-key.kdb -label default'
    docker exec ihs$i bash -c 'cd /tmp/ && mv plugin* /opt/IBM/WebSphere/Plugins/config/webserver1/'
    docker stop ihs$i
    docker start ihs$i
done
