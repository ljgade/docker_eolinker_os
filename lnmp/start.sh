#!/bin/sh

nginx;
php-fpm7;

#init project
resp=`curl https://api.eolinker.com/openSource/Update/checkout | grep -o 'eolinker_.*zip'`;
url="http://data.eolinker.com/os/"${resp};
wget `echo $url` -O $resp;
unzip $resp -d /apps/eolinker_os;
chmod -R 777 /apps/eolinker_os/;

# init mysql
mkdir -p /run/mysqld;
mysql_install_db;

# mysql root password
if [ "$MYSQL_ROOT_PASSWORD" = "" ]; then
  MYSQL_ROOT_PASSWORD=123456
  echo "[i] MySQL root Password: $MYSQL_ROOT_PASSWORD"
fi
if [ "$MYSQL_DATABASE" = "" ]; then
  MYSQL_DATABASE=eolinker_os
  echo "[i] MySQL Database: $MYSQL_DATABASE"
fi

# init root password and create database

  tfile=`mktemp`
  if [ ! -f "$tfile" ]; then
      return 1
  fi
  cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("$MYSQL_ROOT_PASSWORD") WHERE user='root';
EOF

  if [ "$MYSQL_DATABASE" != "" ]; then
    echo "[i] Creating database: $MYSQL_DATABASE"
    echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile
  fi

  /usr/bin/mysqld --user=root --bootstrap --verbose=0 < $tfile
  # rm -f $tfile

# start mysql
mysqld_safe;

