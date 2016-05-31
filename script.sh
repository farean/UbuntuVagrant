#!/bin/bash

VERSION=${VERSION:-3.2.4}

sudo apt-get -y install git-all
if [ $? -ne 0 ]; then
     echo "Error installing git-all"
     exit 1
fi

sudo gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EA312927
ok=$?
if [ $ok -ne 0 ]; then
     echo "WARNING : can't downloading GPG Key (going anyways)"
fi

echo "Adding mongo repo and updateding package manager database"
sudo echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
sudo apt-get update


sudo apt-get install -y $([ $ok -ne 0 ] && echo "--force-yes") mongodb-org=${VERSION} mongodb-org-server=${VERSION} mongodb-org-shell=${VERSION} mongodb-org-mongos=${VERSION} mongodb-org-tools=${VERSION}
if [ $? -ne 0 ]; then
     echo "ERROR : Couldn't install mongo"
     exit 1
fi

sudo service mongod stop
sudo ex -sc '%s/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g|x' /etc/mongod.conf
sudo mkdir -p /data/db 
sudo service mongod start

echo "Installing Redis Server"
sudo apt-get -y install redis-server

echo "Changing configuration for IP in Redis Server"
sudo service redis-server stop
sudo ex -sc '%s/bind 127.0.0.1/bind 0.0.0.0/g|x' /etc/redis/redis.conf
sudo service redis-server start

echo "Dynamodb : Installing"
echo "Dynamodb : downloading bytes"
sudo wget http://dynamodb-local.s3-website-us-west-2.amazonaws.com/dynamodb_local_latest.tar.gz
if [ $? -ne 0 ]; then
	echo "ERROR : Dynamodb is not installed"
	exit 1
fi

echo "Dynamodb : Tarring file"
tar xvzf dynamodb_local_latest.tar.gz

echo "Dynamodb : removing bytes"
rm dynamodb_local_latest.tar.gz

echo "Dynamodb : searching Dynamodb into rc.local"
sudo grep 'java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb' /etc/rc.local
if [ $? -ne 0 ]; then
     echo "Dynamodb : adding Dynamodb to rc.local"
    sudo sed -i '13 a nohup java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb &' /etc/rc.local
fi
echo "Dynamodb : launching Dynamodb "
sudo nohup java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb & 
echo "Dynamodb : installed"

