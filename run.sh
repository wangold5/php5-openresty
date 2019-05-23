#!/bin/bash


# Start php and nginx
while :
do
  runningPHP=$(ps -ef |grep "php-fpm" |grep -v "grep" | wc -l)
  if [ "$runningPHP" -eq 0 ] ; then
    echo "PHP service was not started. Startting now."
    /usr/local/websoft/php/sbin/php-fpm
  fi

  runningNginx=$(ps -ef |grep "nginx" |grep -v "grep" | wc -l)
  if [ "$runningNginx" -eq 0 ] ; then
    echo "Nginx service was not started. Startting now."
    /usr/local/websoft/openresty/nginx/sbin/nginx
  fi

  sleep 6
done
