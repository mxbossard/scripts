FROM debian
MAINTAINER Maxime Bossard <mxbossard@gmail.com>

RUN apt-get update && apt-get -y upgrade && apt-get -y install aufs-tools
COPY testAufs.sh /root/testAufs.sh

VOLUME ["/root/base", "/root/aufs"]

CMD /root/testAufs.sh && /bin/bash

