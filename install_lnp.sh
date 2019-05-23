#!/bin/bash

SOURCE_PATH=/usr/local/src
WEBSOFT_PATH=/usr/local/websoft
WEB_USER_GROUP=nobody
WEB_USER=nobody

if [ ! -d "${SOURCE_PATH}" ]; then
    mkdir -p ${SOURCE_PATH}
else
    echo "dir ${SOURCE_PATH} is exist"
fi


if [ ! -d "${WEBSOFT_PATH}" ]; then
	mkdir -p ${WEBSOFT_PATH}
else
	echo "dir ${WEBSOFT_PATH} is exist"
fi

groupadd ${WEB_USER_GROUP}
useradd ${WEB_USER} -g ${WEB_USER_GROUP}


#安装centos常用的软件包及工具
echo "centos常用的软件包及工具安装开始..."
yum -y install gcc gcc-c++ make perl wget libicu-devel libreadline libcurl-devel libtool libpcre pcre pcre-devel libssl autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers libpq*
echo "centos常用的软件包及工具安装结束..."


#=============================== 安装openresty nginx ===========================
echo "openresty nginx基础环境安装开始..."
yum -y install readline-devel pcre-devel openssl-devel
echo "openresty_nginx基础环境安装结束..."

#安装 libdrizzle 1.0
if [ ! -d "/usr/local/include/libdrizzle-1.0/libdrizzle" ]; then
	echo  "libdrizzle 1.0安装开始..."
	cd ${SOURCE_PATH}
	wget http://agentzh.org/misc/nginx/drizzle7-2011.07.21.tar.gz
	tar -xf drizzle7-2011.07.21.tar.gz
	cd drizzle7-2011.07.21
	./configure --without-server
	make libdrizzle-1.0
	make install-libdrizzle-1.0
	echo "libdrizzle 1.0安装结束..."
else
	echo "libdrizzle 1.0已经安装..."
fi

#在/usr/local/websoft/目录下
if [ ! -d "${WEBSOFT_PATH}openresty/nginx/" ]; then
	echo "ngx_openresty-1.2.4.14.tar.gz安装开始..."
	cd ${SOURCE_PATH}
	wget http://agentzh.org/misc/nginx/ngx_openresty-1.2.4.14.tar.gz
	tar -zxvf  ngx_openresty-1.2.4.14.tar.gz
	cd ngx_openresty-1.2.4.14 
	./configure --prefix=${WEBSOFT_PATH}openresty --with-luajit --with-pcre --with-http_drizzle_module --with-libdrizzle=/usr/local --without-http_redis2_module --with-http_iconv_module
	gmake
	gmake install
	echo "ngx_openresty-1.2.4.14.tar.gz安装结束..."
else
	echo "ngx_openresty-1.2.4.14.tar.gz已经安装..."
fi

#=============================== 安装 php ===========================
yum -y install gmp-devel libxslt-devel

cp -frp /usr/lib64/libldap* /usr/lib/

if [ ! -f "/usr/local/bin/libmcrypt-config" ]; then
	echo "libmcrypt-2.5.8.tar.gz安装开始..."
	#cd /usr/local/websoft/
	cd ${SOURCE_PATH}
	wget http://sourceforge.net/projects/mcrypt/files/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
	tar -zxvf libmcrypt-2.5.8.tar.gz 
	cd libmcrypt-2.5.8 
	./configure && make && make install 
	echo "libmcrypt-2.5.8.tar.gz安装结束..."

else
	echo "libmcrypt-2.5.8.tar.gz已经安装..."
fi

if [ ! -d "${WEBSOFT_PATH}php/" ]; then
	cd ${SOURCE_PATH}
	echo "php-5.4.7.tar.bz2安装开始..."
	wget cn2.php.net/get/php-5.4.7.tar.bz2/from/this/mirror
	#低版本的cn2.php.net/get/php-5.3.18.tar.bz2/from/this/mirror
	tar jvxf php-5.4.7.tar.bz2
	cd php-5.4.7
	./configure   --prefix=${WEBSOFT_PATH}php   --with-iconv   --with-zlib  --enable-xml   --disable-rpath   --enable-bcmath   --enable-shmop   --enable-sysvsem   --enable-inline-optimization   --with-curl   --with-curlwrappers   --enable-mbregex   --enable-mbstring   --with-mcrypt   --with-gd   --enable-gd-native-ttf   --with-openssl   --with-mhash   --enable-pcntl   --enable-sockets   --with-xmlrpc   --enable-zip   --enable-soap   --without-pear   --with-mysql   --with-mysqli   --with-pgsql   --with-pdo-mysql   --enable-ftp   --with-jpeg-dir   --with-freetype-dir   --with-png-dir   --enable-fpm   --with-gettext   --with-ldap   --with-xsl   --with-gmp   --enable-exif
	#
	#--with-mysql是mysql的安装路径，比如--with-mysql=/usr/local/mysql/
	#--with-mysqli是mysql_config的安装路径，比如--with-mysqli=/usr/bin/mysql_config
	#
	#配置错误：
	#configure: error: Unable to locate gmp.h
	#
	#解决：
	#yum install gmp-devel
	#
	#错误：
	#error: Cannot find ldap libraries in /usr/lib.
	#解决：
	#cp -frp /usr/lib64/libldap* /usr/lib/
	#
	#php错误：
	#configure: error: mcrypt.h not found. Please reinstall libmcrypt
	#解决：
	#cd /usr/local/websoft/
	#wget http://sourceforge.net/projects/mcrypt/files/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
	#tar -zxvf libmcrypt-2.5.8.tar.gz 
	#cd libmcrypt-2.5.8 
	#./configure && make && make install 
	#./configure --with-libmcrypt-prefix=/usr/local/lib #这一步不需要
	#cd ..
	#
	#错误：Cannot find libpq-fe.h. Please specify correct PostgreSQL installation path
	#解决：
	#yum install postgresql-devel
	#
	#错误：
	#configure: error: xslt-config not found. Please reinstall the libxslt >= 1.1.0 distribution
	#解决：
	#yum install libxslt-devel
	#

	make
	make install
	
	#把/usr/local/websoft/php-5.4.7/php.ini-development 文件拷贝到/usr/local/websoft/php/lib/目录下并更名为php.ini
	cp ${SOURCE_PATH}php-5.4.7/php.ini-development ${WEBSOFT_PATH}php/lib/php.ini
	#关闭php.ini的display_errors
	#echo "display_errors = Off" >> ${WEBSOFT_PATH}php/lib/php.ini
	count=`grep display_errors\ \=\ Off -rl ${WEBSOFT_PATH}php/lib/php.ini | wc -l`
	if [ $count -eq 0 ]; then
		sed -i "s/display_errors\ \=\ On/display_errors\ \= \Off/g" `grep display_errors\ \=\ On -rl ${WEBSOFT_PATH}php/lib/php.ini`
	fi
	echo "php-5.4.7.tar.bz2安装结束..."

else
	echo "php-5.4.7.tar.bz2已经安装..."
fi


echo "配置${WEBSOFT_PATH}openresty/nginx/conf/nginx.conf开始..."
count=`grep user\ \ ${WEB_USER} -rl ${WEBSOFT_PATH}openresty/nginx/conf/nginx.conf | wc -l`
echo "$count"
if [ $count -eq 0 ]; then
	sed -i "s/\#user\ \ nobody/user\ \ ${WEB_USER}/g" `grep \#user\ \ nobody -rl ${WEBSOFT_PATH}openresty/nginx/conf/nginx.conf`
else
	echo "user\ \ ${WEB_USER}配置已经存在${WEBSOFT_PATH}openresty/nginx/conf/nginx.conf中..."
fi
echo "配置${WEBSOFT_PATH}openresty/nginx/conf/nginx.conf结束..."

echo "配置${WEBSOFT_PATH}php/etc/php-fpm.conf开始..."

count=`grep user\ =\ ${WEB_USER} -rl ${WEBSOFT_PATH}php/etc/php-fpm.conf | wc -l`
if [ $count -eq 0 ]; then
	sed -i "s/user\ =\ nobody/user\ =\ ${WEB_USER}/g" `grep user\ =\ nobody -rl ${WEBSOFT_PATH}php/etc/php-fpm.conf`
else
	echo "user\ =\ ${WEB_USER}配置已经存在${WEBSOFT_PATH}php/etc/php-fpm.conf中..."
fi
count=`grep group\ =\ ${WEB_USER_GROUP} -rl ${WEBSOFT_PATH}php/etc/php-fpm.conf | wc -l`
if [ $count -eq 0 ]; then
	sed -i "s/group\ =\ nobody/group\ =\ ${WEB_USER_GROUP}/g" `grep group\ =\ nobody -rl ${WEBSOFT_PATH}php/etc/php-fpm.conf`
else
	echo "group\ =\ ${WEB_USER_GROUP}配置已经存在${WEBSOFT_PATH}php/etc/php-fpm.conf中..."
fi

echo "配置${WEBSOFT_PATH}php/etc/php-fpm.conf结束..."

#============安装PHP的phpredis扩展(下载地址https://github.com/nicolasff/phpredis)============
if [ ! -f "${WEBSOFT_PATH}php/lib/php/extensions/no-debug-non-zts-20100525/redis.so" ]; then
	echo "正在安装phpredis-master..."
	cd ${SOURCE_PATH}
	if [ ! -f ${SOURCE_PATH}phpredis.zip ]; then
		wget https://github.com/nicolasff/phpredis/archive/master.zip
		mv master phpredis.zip
	fi
	unzip phpredis.zip
	cd phpredis-master
	${WEBSOFT_PATH}php/bin/phpize
	./configure --with-php-config=${WEBSOFT_PATH}php/bin/php-config
	make && make install
	echo "extension=${WEBSOFT_PATH}php/lib/php/extensions/no-debug-non-zts-20100525/redis.so" >> ${WEBSOFT_PATH}php/lib/php.ini
	echo "phpredis-master安装完成..."
else
    echo "phpredis-master已经安装..."
fi

echo "安装redis结束..."

#============安装PHP的rar扩展============
if [ ! -f "${WEBSOFT_PATH}php/lib/php/extensions/no-debug-non-zts-20100525/rar.so" ]; then
	echo "正在安装phprar扩展rar-3.0.0.tgz..."
	cd ${SOURCE_PATH}
	if [ ! -f ${SOURCE_PATH}rar-3.0.0.tgz ]; then
		wget http://pecl.php.net/get/rar-3.0.0.tgz
	fi
	tar -xvf rar-3.0.0.tgz
	cd rar-3.0.0
	${WEBSOFT_PATH}php/bin/phpize
	./configure --with-php-config=${WEBSOFT_PATH}php/bin/php-config
	make
	make install
	#php.ini增加
	echo "extension=${WEBSOFT_PATH}php/lib/php/extensions/no-debug-non-zts-20100525/rar.so" >> ${WEBSOFT_PATH}php/lib/php.ini
	echo "phprar扩展rar-3.0.0.tgz安装完成..."
else
    echo "phprar扩展rar-3.0.0.tgz已经安装..."
fi

#============安装PHP的radius扩展============
if [ ! -f "${WEBSOFT_PATH}php/lib/php/extensions/no-debug-non-zts-20100525/radius.so" ]; then
	echo "正在安装php的radius扩展radius-1.2.7.tgz..."
	cd ${SOURCE_PATH}
	if [ ! -f ${SOURCE_PATH}radius-1.2.7.tgz ]; then
		wget http://pecl.php.net/get/radius-1.2.7.tgz
	fi
	tar -zxvf radius-1.2.7.tgz
	cd radius-1.2.7
	${WEBSOFT_PATH}php/bin/phpize
	./configure --with-php-config=${WEBSOFT_PATH}php/bin/php-config
	make
	make install
	#php.ini增加
	echo "extension=${WEBSOFT_PATH}php/lib/php/extensions/no-debug-non-zts-20100525/radius.so" >> ${WEBSOFT_PATH}php/lib/php.ini
	echo "php的radius扩展radius-1.2.7.tgz安装完成..."
else
        echo "php的radius扩展radius-1.2.7.tgz已经安装..."
fi
rm -rf ${SOURCE_PATH}
