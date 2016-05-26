#!/bin/bash
sudo apt-get -y install git-all
#	if [ $? -ne 0 ]; then exit 1; fi

# sudo gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EA312927
sudo echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
sudo apt-get update
sudo apt-get install -y --force-yes mongodb-org=3.2.4 mongodb-org-server=3.2.4 mongodb-org-shell=3.2.4 mongodb-org-mongos=3.2.4 mongodb-org-tools=3.2.4
sudo service mongod stop
sudo ex -sc '%s/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g|x' /etc/mongod.conf
sudo mkdir -p /data/db 
sudo service mongod start
