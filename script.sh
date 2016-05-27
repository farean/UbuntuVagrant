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
