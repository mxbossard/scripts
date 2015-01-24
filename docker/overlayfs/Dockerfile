FROM ubuntu
MAINTAINER Maxime Bossard <mxbossard@gmail.com>

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install strace
RUN apt-get -y install vim
COPY testOverlayfs.sh /root/testOverlayfs.sh

RUN mkdir -p /mnt/base /mnt/aufs

ENV NB_DIR 1000

VOLUME ["/mnt/base", "/mnt/aufs"]

CMD /root/testOverlayfs.sh && /bin/bash
#CMD /bin/bash

