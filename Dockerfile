FROM phusion/baseimage:latest
MAINTAINER Andrey Kobyshev <yokotoka@gmail.com>

# tty off
ENV DEBIAN_FRONTEND noninteractive

# UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8


#SOME init
RUN locale-gen en_US.UTF-8 \
	&& /etc/my_init.d/00_regen_ssh_host_keys.sh \
	&& echo "mysql-server mysql-server/root_password password root" | debconf-set-selections \
	&& echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections \
	&& sed -i "s/^exit 101$/exit 0/" /usr/sbin/policy-rc.d

#APT init
RUN add-apt-repository -y ppa:ondrej/php5 \
	&& add-apt-repository -y ppa:nginx/stable \
	&& apt-get update \
	&& apt-get upgrade -y


# Install and configure MYSQL
RUN apt-get -y install mysql-server mysql-client
ADD build/etc/mysql/my.cnf /etc/mysql/my.cnf
RUN mkdir /etc/service/mysql
ADD build/etc/service/mysql/run /etc/service/mysql/run
RUN chmod +x /etc/service/mysql/run \
	&& mkdir -p /var/lib/mysql/ \
	&& chmod -R 755 /var/lib/mysql/
ADD build/etc/my_init.d/99_mysql_setup.sh /etc/my_init.d/99_mysql_setup.sh
ADD build/var/lib/mysql/setup/* /var/lib/mysql/setup/*
RUN chmod +x /etc/my_init.d/99_mysql_setup.sh



RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 3306


#START
CMD ["/sbin/my_init"]