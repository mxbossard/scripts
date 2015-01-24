FROM debian
MAINTAINER Maxime Bossard <mxbossard@gmail.com>

RUN apt-get update && apt-get -y upgrade && apt-get -y install aufs-tools

COPY testAufs.sh /root/testAufs.sh

RUN mkdir -p /mnt/base /mnt/aufs

VOLUME ["/mnt/aufs"]

CMD /root/testAufs.sh && /bin/bash

