#!/bin/bash

chmod +x /opt/bash/init.sh && . /opt/bash/init.sh

kill -HUP $(pgrep supervisord)
#supervisorctl restart nginx && supervisorctl restart php-fpm
