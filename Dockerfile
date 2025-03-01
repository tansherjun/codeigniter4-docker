FROM php:7.3-apache

LABEL original_author="Antonio Sanna <atsanna@tiscali.it>"
LABEL maintainer="Sher Jun Tan <tansherjun@gmail.com>"




RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install --fix-missing -y libpq-dev
RUN apt-get install --no-install-recommends -y libpq-dev
RUN apt-get install -y libxml2-dev libbz2-dev zlib1g-dev
RUN apt-get -y install libsqlite3-dev libsqlite3-0 mariadb-client curl exif ftp
RUN docker-php-ext-install intl pdo pdo_mysql mysqli
RUN apt-get -y install --fix-missing zip unzip

# Composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer
RUN composer self-update

#Commenting out as the ENV APACHE_DOCUMENT_ROOT is probably a better way of doing this
#ADD conf/apache.conf /etc/apache2/sites-available/000-default.conf

ENV APACHE_DOCUMENT_ROOT /var/www/html/codeigniter4/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf


RUN a2enmod rewrite

# The printf command below creates the script /startScript.sh with the following 3 lines. 
# #!/bin/bash
# mv /codeigniter4 /var/www/html
# /usr/sbin/apache2ctl -D FOREGROUND
RUN printf "#!/bin/bash\nmv /codeigniter4 /var/www/html\n/usr/sbin/apache2ctl -D FOREGROUND" > /startScript.sh
RUN chmod +x /startScript.sh

RUN cd /var/www/html

RUN composer create-project codeigniter4/appstarter codeigniter4 v4.0.3
RUN chmod -R 0777 /var/www/html/codeigniter4/writable

RUN mv codeigniter4 /

RUN apt-get clean \
    && rm -r /var/lib/apt/lists/*

RUN printf 'memory_limit = ${PHP_MEMORY_LIMIT}' >> /usr/local/etc/php/conf.d/environment.ini;

EXPOSE 80
VOLUME ["/var/www/html", "/var/log/apache2", "/etc/apache2"]

CMD ["bash", "/startScript.sh"]