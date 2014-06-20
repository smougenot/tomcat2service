#!/bin/sh
# init

# RPM
echo "Building rpm"
# builder
yum install -y rpm-build
# build
pushd initd-util
  sh ./build.sh 1.2.3 && yum localinstall -y RPMS/noarch/*.rpm
popd

# Tomcat
if [ ! -d /opt/tomcat/ ]; then
  echo "déploiement tomcat"
  if [ ! -f apache-tomcat-7.0.54.tar.gz ]; then
    echo "Téléchargement de tomcat"
    wget http://mirrors.ircam.fr/pub/apache/tomcat/tomcat-7/v7.0.54/bin/apache-tomcat-7.0.54.tar.gz
  fi
  tar -xzvf apache-tomcat-7.0.54.tar.gz
  ln -s `pwd`/apache-tomcat-7.0.54 /opt/tomcat
fi

# Java
if [ $(command -v java | wc -l) -eq 0 ]; then
  echo "déploiement de java"
  yum install -y java-1.7.0-openjdk-devel
fi

# configuration
pushd tomcat-util
  sh ./sample.sh
popd

# lancement
service my_app_demo version

echo "Tout est prêt"
echo "Le service est : service my_app_demo"
