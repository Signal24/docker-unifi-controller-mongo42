FROM lsiobase/ubuntu:xenial

# set version label
ARG BUILD_DATE
ARG VERSION
ARG UNIFI_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

# environment settings
ARG UNIFI_BRANCH="stable"
ARG DEBIAN_FRONTEND="noninteractive"

RUN \
 echo "**** add mongo repository ****" && \
 curl https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add - && \
 echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" >> /etc/apt/sources.list.d/mongo.list && \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
	binutils \
	jsvc \
	mongodb-org-server \
	openjdk-8-jre-headless \
	wget && \
 echo "**** install unifi ****" && \
 if [ -z ${UNIFI_VERSION+x} ]; then \
	UNIFI_VERSION=$(curl -sX GET http://dl-origin.ubnt.com/unifi/debian/dists/${UNIFI_BRANCH}/ubiquiti/binary-amd64/Packages \
	|grep -A 7 -m 1 'Package: unifi' \
	| awk -F ': ' '/Version/{print $2;exit}' \
	| awk -F '-' '{print $1}'); \
 fi && \
 curl -o \
 /tmp/unifi.deb -L \
	"https://dl.ui.com/unifi/${UNIFI_VERSION}/unifi_sysvinit_all.deb" && \
 dpkg -i --ignore-depends=mongodb-server,mongodb-10gen,mongodb-org-server /tmp/unifi.deb && \
 echo "**** cleanup ****" && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY root/ /

# Volumes and Ports
WORKDIR /usr/lib/unifi
VOLUME /config
EXPOSE 8080 8081 8443 8843 8880
