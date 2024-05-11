FROM ubuntu:20.04

WORKDIR /halite-1-full

# Install items for Web Site
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update
RUN apt-get install -y php5.6 php5.6-mysql apache2
RUN a2enmod rewrite expires
RUN apt-get install -y python3 python3-pip
RUN pip3 install trueskill boto paramiko pymysql
RUN apt-get install -y zip curl

# Install SQL
RUN apt-get install -y mysql-server

COPY . .

# Install website components
RUN cd website;curl -sS https://getcomposer.org/installer | php;php composer.phar install

# Install sql dummy data
RUN service mysql start;cd /halite-1-full/website/sql/;echo "drop database Halite; create database Halite;" | mysql -u root -p;mysql -u root Halite < schema.sql -p;mysql -u root Halite < dummyData.sql -p;sleep 10

RUN echo "Listen 8080" >> /etc/apache2/ports.conf
RUN echo "RedirectMatch ^/$ /website/">>/etc/apache2/apache2.conf

RUN rm -rf /var/www/html
RUN ln -s /halite-1-full/ /var/www/html

EXPOSE 8080
CMD service apache2 start; tail -F /var/log/apache2
