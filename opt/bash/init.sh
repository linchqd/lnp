#!/bin/bash

WEBSITE_PATH="/home/website/default"
CONFIG_PATH="/home/config"

mkdir -p $WEBSITE_PATH
mkdir -p $CONFIG_PATH

if [[ "`ls -A $WEBSITE_PATH`" = "" ]];then
    \cp -rf /opt/website/default/* $WEBSITE_PATH
fi

if [[ "`ls -A $CONFIG_PATH`" = "" ]];then
    \cp -rf /opt/config/* $CONFIG_PATH
fi

#nginx
\cp -rf $CONFIG_PATH/nginx/nginx.conf /usr/local/nginx/conf/nginx.conf
mkdir -p /usr/local/nginx/conf/conf.d
\cp -rf $CONFIG_PATH/nginx/conf.d/* /usr/local/nginx/conf/conf.d/

#php
\cp -rf $CONFIG_PATH/php/php.ini /usr/local/php/etc/php.ini
\cp -rf $CONFIG_PATH/php/php-fpm.conf /usr/local/php/etc/php-fpm.conf
\cp -rf $CONFIG_PATH/php/php-fpm.d/* /usr/local/php/etc/php-fpm.d/

#supervisor
\cp -rf $CONFIG_PATH/supervisor/supervisord.conf /etc/supervisord.conf
\cp -rf $CONFIG_PATH/supervisor/supervisord.d/* /etc/supervisord.d/
