FROM ubuntu:bionic

RUN apt-get -y update
RUN apt-get -y install wget openjdk-8-jdk gnupg
RUN wget -O - http://package.mapr.com/releases/pub/maprgpg.key > /tmp/ik
RUN apt-key add /tmp/ik
RUN echo "deb http://package.mapr.com/releases/v6.1.0/ubuntu binary trusty" >> /etc/apt/sources.list
RUn echo "deb http://package.mapr.com/releases/MEP/MEP-6.0/ubuntu  binary trusty" >> /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get -y install mapr-core
RUN apt-get -y install mapr-spark
RUN apt-get -y install mapr-spark-master

COPY mapr_conf.sh /tmp
