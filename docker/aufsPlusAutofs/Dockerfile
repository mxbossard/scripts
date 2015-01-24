FROM debian
MAINTAINER Maxime Bossard <mxbossard@gmail.com>

RUN apt-get update && apt-get -y upgrade && apt-get -y install aufs-tools autofs5
RUN apt-get -y install strace
RUN apt-get -y install vim 

COPY testAufs.sh /root/testAufs.sh
COPY testAutofs.sh /root/testAutofs.sh
COPY auto.master /etc/auto.master
COPY auto.aufs /etc/auto.aufs
COPY autofs /etc/init.d/autofs

RUN mkdir -p /mnt/base /mnt/aufs /mnt/autofs/aufs

VOLUME ["/mnt/base", "/mnt/aufs", "/mnt/autofs"]

CMD /root/testAutofs.sh && /bin/bash

