FROM php:7.4-apache
WORKDIR /var/www/html

RUN a2enmod rewrite

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    git-core \
    apt-utils \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libmemcached-dev \
    zlib1g-dev \
    imagemagick

RUN pecl install mcrypt-1.0.3
RUN docker-php-ext-enable mcrypt

RUN docker-php-ext-install -j$(nproc) iconv pdo pdo_mysql gd mysqli
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/


RUN curl -J -L -s -k https://github.com/omeka/omeka-s/releases/download/v3.0.2/omeka-s-3.0.2.zip -o ./omeka-s.zip \
    && unzip -q ./omeka-s.zip -d ./ \
    && rm -rf omeka-s.zip \
    && mv omeka-s/* ./ 

RUN cd modules/ \
    && git clone https://github.com/KompetenzwerkD/omeka-s-ItemRelation \
    && mv omeka-s-ItemRelation/ ./ItemRelation \
    && git clone https://github.com/KompetenzwerkD/omeka-s-Reference \
    && mv omeka-s-Reference/ ./Reference \
    && git clone https://github.com/KompetenzwerkD/omeka-s-Thesauri \
    && mv omeka-s-Thesauri/ ./Thesauri \
    && git clone https://github.com/KompetenzwerkD/omeka-s-ProjectDashboard \
    && mv omeka-s-ProjectDashboard/ ./ProjectDashboard \
    && curl -J -L -s -k https://github.com/omeka-s-modules/CustomVocab/releases/download/v1.3.1/CustomVocab-1.3.1.zip -o ./CustomVocab.zip \
    && unzip -q ./CustomVocab.zip -d ./ \
    && rm -rf CustomVocab.zip \
    && cd ..

RUN chown -R www-data:www-data /var/www/html

COPY ./install/.htaccess /var/www/html/.htaccess    
COPY ./install/database.ini /var/www/html/config/database.ini
COPY ./install/imagemagick-policy.xml /etc/ImageMagick/policy.xml
