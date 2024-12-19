#!/bin/bash

sudo apt update
sudo apt install openjdk-17-jdk

sudo useradd -m -s /bin/bash tomcat

curl -O https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.89/bin/apache-tomcat-9.0.89.tar.gz

sudo tar xzvf apache-tomcat-*tar.gz -C /home/tomcat --strip-components=1

sudo chown -R tomcat:tomcat /home/tomcat

sudo wget https://downloads.mysql.com/archives/get/p/3/file/mysql-connector-java_8.0.29-1ubuntu20.04_all.deb
sudo dpkg -x mysql-connector-java_8.0.29-1ubuntu20.04_all.deb ./temp
sudo mv ./temp/usr/share/java/mysql-connector-java-8.0.29.jar /home/tomcat/lib
sudo rm -rf ./temp

sudo cat  << EOF | sudo tee >> /etc/profile
export CATALINA_HOME=/home/tomcat
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH=$PATH:/usr/lib/jvm/java-17-openjdk-amd64/bin:/home/tomcat/bin
EOF

source /etc/profile

cat << EOF | sudo tee > /etc/systemd/system/tomcat.service 
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 
Environment=CATALINA_PID=/home/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/home/tomcat
Environment=CATALINA_BASE=/home/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/home/tomcat/bin/startup.sh
ExecStop=/home/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl restart tomcat
sudo systemctl enable tomcat