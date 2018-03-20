# This dockerfile uses the ubuntu image
# VERSION 1 - EDITION 1
# Author: Yourtion, Yale Huang
# Command format: Instruction [arguments / command] ..

# Base image to use, this must be set as the first line
FROM ubuntu

MAINTAINER Yale Huang <calvino.huang@gmail.com>

# Commands to update the image
RUN apt-get -y update && apt-get -y upgrade

RUN apt-get install python3  
RUN apt-get install python3-pip(这个命令好像会同时安装python2.7)  
RUN apt-get install python3-dev  
RUN apt-get install openssl  
RUN apt-get install libssl-dev  
RUN apt-get install libffi-dev  

RUN apt-get install build-essential
RUN wget https://download.libsodium.org/libsodium/releases/LATEST.tar.gz
RUN tar xf libsodium-1.0.10.tar.gz && cd libsodium-1.0.10
RUN ./configure && make -j4 && make install
RUN ldconfig
WORKDIR root
#build-essential
# Install shadowsocks-libev
RUN apt-get install autoconf libtool libssl-dev git openjdk-8-jre unzip \
	libpcap-dev wget supervisor -y
RUN git clone https://github.com/shadowsocks/shadowsocks-libev.git /root/shadowsocks-libev
RUN wget -O /root/finalspeed_server.zip https://github.com/kevinljh11/finalspeed/raw/master/finalspeed_server10.zip
RUN cd /root/shadowsocks-libev && git checkout v2.4.4 && ./configure && make
RUN cd /root/shadowsocks-libev/src && install -c ss-server /usr/bin
RUN apt-get purge git build-essential autoconf libtool libssl-dev -y  && apt-get autoremove -y && apt-get autoclean -y
RUN mkdir -p /opt/finalspeed && cd /opt/finalspeed && unzip /root/finalspeed_server.zip
RUN rm -rf /root/shadowsocks-libev
COPY start_finalspeed /opt/finalspeed/start_finalspeed
COPY supervisord.conf /etc/supervisord.conf
COPY server_linux_amd64 /root/server_linux_amd64
RUN chmod +x /root/server_linux_amd64

ARG BRANCH=manyuser
ARG WORK=/root/ssr
    
RUN mkdir -p $WORK && \
    wget -qO- --no-check-certificate https://github.com/shadowsocksr/shadowsocksr/archive/$BRANCH.tar.gz | tar -xzf - -C $WORK

ENV SS_PASSWORD ibm123456
ENV SS_METHOD aes-256-cfb

EXPOSE 150/udp 151/udp

#ENTRYPOINT /usr/bin/ss-server -s 0.0.0.0 -p 8338 -k ${SS_PASSWORD} -m ${SS_METHOD}
CMD ["/usr/bin/supervisord"]
