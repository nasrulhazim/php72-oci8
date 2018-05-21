FROM adrianharabula/php7-with-oci8

MAINTAINER Nasrul Hazim <nasrulhazim.m@gmail.com>

RUN apt-get update && apt-get install -y mysql-client \
	unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libaio1 \
	git \
	zlib1g-dev \
	libgmp3-dev \
	&& docker-php-ext-install mbstring json zip gmp bcmath mysqli pdo pdo_mysql \
	&& pecl install xdebug \
	&& docker-php-ext-enable xdebug 

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

#RUN echo 'export LD_LIBRARY_PATH="/usr/local/instantclient"' >> /etc/apache2/envars

# To speed up Composer
RUN composer global require hirak/prestissimo

# Start services
RUN service apache2 restart

# Setup Oracle Environment
ENV LD_LIBRARY_PATH /usr/local/instantclient/
ENV ORACLE_HOME /usr/local/instantclient/
ENV TNS_ADMIN /usr/local/instantclient/
ENV ORACLE_BASE /usr/local/instantclient/

# Setup Laravel Environment
ENV APP_ENV=local
ENV APP_KEY=base64:4vPv4DW4WITgMUhyNasTkLVnzAhMw7zPijVluE5iAAk=
ENV APP_DEBUG=true
ENV APP_LOG_LEVEL=debug
ENV APP_URL=http://localhost:8000

# Working Directory
WORKDIR /var/www/html

EXPOSE 80
EXPOSE 443
EXPOSE 8000
EXPOSE 8080