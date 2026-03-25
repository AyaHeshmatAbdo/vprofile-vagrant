#!/usr/bin/env bash
set -e

# Install Java, Maven, Git
yum update -y
dnf install -y java-11-openjdk java-11-openjdk-devel git maven wget

# Install Tomcat
cd /tmp
TOMCAT_VER="9.0.75"
wget https://archive.apache.org/dist/tomcat/tomcat-9/v$TOMCAT_VER/bin/apache-tomcat-$TOMCAT_VER.tar.gz
tar xzf apache-tomcat-$TOMCAT_VER.tar.gz
mv apache-tomcat-$TOMCAT_VER /usr/local/tomcat
useradd -r -s /sbin/nologin tomcat
chown -R tomcat:tomcat /usr/local/tomcat

# Setup systemd service
cat <<EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat
After=network.target
[Service]
User=tomcat
WorkingDirectory=/usr/local/tomcat
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_HOME=/usr/local/tomcat
ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now tomcat

# Clone project and configure application.properties
cd /tmp
git clone -b main https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project

cat <<EOF > src/main/resources/application.properties
jdbc.driverClassName=com.mysql.cj.jdbc.Driver
jdbc.url=jdbc:mysql://db01.vprofile:3306/accounts
jdbc.username=admin
jdbc.password=admin123
memcached.active.host=mc01.vprofile
memcached.active.port=11211
rabbitmq.address=rmq01.vprofile
rabbitmq.port=5672
rabbitmq.username=test
rabbitmq.password=test@1234567
spring.security.user.name=admin_vp
spring.security.user.password=admin_vp
spring.security.user.roles=ADMIN
EOF

# Build app
mvn install

# Deploy WAR
rm -rf /usr/local/tomcat/webapps/ROOT
cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
chown -R tomcat:tomcat /usr/local/tomcat/webapps

systemctl restart tomcat
