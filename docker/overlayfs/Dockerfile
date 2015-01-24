FROM ubuntu
MAINTAINER Maxime Bossard <mxbossard@gmail.com>

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install strace
RUN apt-get -y install vim
COPY testOverlayfs.sh /root/testOverlayfs.sh

RUN mkdir -p /mnt/base /mnt/aufs

VOLUME ["/mnt/base", "/mnt/aufs"]

CMD /root/testAufs.sh && /bin/bash
#CMD /bin/bash

