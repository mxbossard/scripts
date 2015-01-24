FROM ubuntu
MAINTAINER Maxime Bossard <mxbossard@gmail.com>

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install strace
RUN apt-get -y install vim

COPY testOverlayfs.sh /root/testOverlayfs.sh
COPY testAutofs.sh /root/testAutofs.sh
COPY auto.master /etc/auto.master
COPY auto.overlayfs /etc/auto.overlayfs
COPY autofs /etc/init.d/autofs

RUN mkdir -p /mnt/base /mnt/aufs

ENV NB_DIR 1000

VOLUME ["/mnt/overlayfs"]

CMD /root/testAutofs.sh && /bin/bash
#CMD /bin/bash

