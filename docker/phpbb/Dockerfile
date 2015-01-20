FROM php:apache
MAINTAINER Maxime Bossard <mxbossard@gmail.com>

RUN apt-get update
RUN apt-get -y upgrade

# Config supervisord
RUN apt-get -y install supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Install php5 plugins
RUN apt-get -y install php5-mysql php5-gd imagemagick libpng12-dev libssl-dev
RUN docker-php-ext-install gd mysql ftp

# Download and install phpbb
ENV phpbbFilename phpBB-3.1.2.tar.bz2
ENV phpbbBaseUrl https://www.phpbb.com/files/release/

RUN apt-get -y install wget bzip2
RUN mkdir -p /root/phpbb
WORKDIR /root/phpbb
RUN wget $phpbbBaseUrl$phpbbFilename
RUN tar -xjf $phpbbFilename
RUN cp -rp /root/phpbb/$(ls -d */)/* /var/www/html
RUN rm -rf /root/phpbb

#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 20M
ENV PHP_POST_MAX_SIZE 10M

# Install sshd
RUN apt-get -y install openssh-server
RUN mkdir -p /var/run/sshd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN echo 'root:root' | chpasswd

# Add volumes for logs and application
VOLUME  ["/var/log", "/var/www/html"]

EXPOSE 22 80

CMD ["/usr/bin/supervisord"]

