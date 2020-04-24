#!/bin/bash

# Init NextCloud database and perform initial configuration
#
# GPL licensed - end of file
#
#

DBADMIN=ncadmin

configure()
{
  source /usr/local/etc/library.sh # sets PHPVER

  echo "Setting up a clean Nextcloud instance... wait until message 'nextclod init done'"

  # checks
  local REDISPASS=$( grep "^requirepass" /etc/redis/redis.conf  | cut -d' ' -f2 )
  [[ "$REDISPASS" == "" ]] && { echo "redis server without a password. Abort"; return 1; }

  ## RE-CREATE DATABASE TABLE

  echo "Setting up database..."

  # launch mariadb if not already running
  if ! pgrep -c mysqld &>/dev/null; then
    mysqld &
  fi

  # wait for mariadb
  pgrep -x mysqld &>/dev/null || {
    echo "mariaDB process not found. Waiting..."
    while :; do
      [[ -S /run/mysqld/mysqld.sock ]] && break
      sleep 0.5
    done
  }

  # workaround to emulate DROP USER IF EXISTS ..;)
  local DBPASSWD=$( grep password /root/.my.cnf | sed 's|password=||' )
  mysql <<EOF
DROP DATABASE IF EXISTS nextcloud;
CREATE DATABASE nextcloud
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;
GRANT USAGE ON *.* TO '$DBADMIN'@'localhost' IDENTIFIED BY '$DBPASSWD';
DROP USER '$DBADMIN'@'localhost';
CREATE USER '$DBADMIN'@'localhost' IDENTIFIED BY '$DBPASSWD';
GRANT ALL PRIVILEGES ON nextcloud.* TO $DBADMIN@localhost;
EXIT
EOF

  ## INITIALIZE NEXTCLOUD

  # make sure redis is running first
  if ! pgrep -c redis-server &>/dev/null; then
    mkdir -p /var/run/redis
    chown redis /var/run/redis
    sudo -u redis redis-server /etc/redis/redis.conf &
  fi

  while :; do
    [[ -S /run/redis/redis.sock ]] && break
    sleep 0.5
  done


  echo "Setting up Nextcloud..."

  cd /var/www/nextcloud/
  rm -f config/config.php
  ncc maintenance:install --database \
    "mysql" --database-name "nextcloud"  --database-user "$DBADMIN" --database-pass \
    "$DBPASSWD" --admin-user "$ADMINUSER" --admin-pass "$ADMINPASS"

  # cron jobs
  ncc background:cron

  # redis cache
  sed -i '$d' config/config.php
  cat >> config/config.php <<EOF
  'memcache.local' => '\\OC\\Memcache\\Redis',
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'redis' =>
  array (
    'host' => '/var/run/redis/redis.sock',
    'port' => 0,
    'timeout' => 0.0,
    'password' => '$REDISPASS',
  ),
);
EOF

  # tmp upload dir
  local UPLOADTMPDIR=/var/www/nextcloud/data/tmp
  mkdir -p "$UPLOADTMPDIR"
  chown www-data:www-data "$UPLOADTMPDIR"
  ncc config:system:set tempdirectory --value "$UPLOADTMPDIR"
  sed -i "s|^;\?upload_tmp_dir =.*$|upload_tmp_dir = $UPLOADTMPDIR|" /etc/php/${PHPVER}/cli/php.ini
  sed -i "s|^;\?upload_tmp_dir =.*$|upload_tmp_dir = $UPLOADTMPDIR|" /etc/php/${PHPVER}/fpm/php.ini
  sed -i "s|^;\?sys_temp_dir =.*$|sys_temp_dir = $UPLOADTMPDIR|"     /etc/php/${PHPVER}/fpm/php.ini

  # 4 Byte UTF8 support
  ncc config:system:set mysql.utf8mb4 --type boolean --value="true"

  # Default trusted domain ( only from ncp-config )
  test -f /usr/local/bin/nextcloud-domain.sh && {
    test -f /.ncp-image || bash /usr/local/bin/nextcloud-domain.sh
  }
  ncc config:system:set trusted_domains 5 --value="nettserver.local"
  # trusted_domains 6 used by docker

  # email
  ncc config:system:set mail_smtpmode     --value="sendmail"
  ncc config:system:set mail_smtpauthtype --value="LOGIN"
  ncc config:system:set mail_from_address --value="admin"
  ncc config:system:set mail_domain       --value="example.com"

  # NETTSERVER theme
  [[ -e /usr/local/etc/logo ]] && {
    local ID=$( grep instanceid config/config.php | awk -F "=> " '{ print $2 }' | sed "s|[,']||g" )
    [[ "$ID" == "" ]] && { echo "failed to get ID"; return 1; }
    mkdir -p data/appdata_${ID}/theming/images
    cp /usr/local/etc/background data/appdata_${ID}/theming/images
    cp /usr/local/etc/logo data/appdata_${ID}/theming/images/logo
    cp /usr/local/etc/logo data/appdata_${ID}/theming/images/logoheader
    chown -R www-data:www-data data/appdata_${ID}
  }

  mysql nextcloud <<EOF
replace into  oc_appconfig values ( 'theming', 'name'          , "nettserver"             );
replace into  oc_appconfig values ( 'theming', 'slogan'        , "private cloud"    );
replace into  oc_appconfig values ( 'theming', 'url'           , "https://nettserver" );
replace into  oc_appconfig values ( 'theming', 'logoMime'      , "image/svg+xml"           );
replace into  oc_appconfig values ( 'theming', 'backgroundMime', "image/png"               );
EOF

  # NETTSERVER app
  cp -r /var/www/nettserver-app /var/www/nextcloud/apps/nettserver
  chown -R www-data:     /var/www/nextcloud/apps/nettserver
  ncc app:enable nettserver

  # enable some apps by default
  ncc app:install calendar
  ncc app:install contacts
  ncc app:install notes
  ncc app:install tasks
  ncc app:install news

  ncc app:enable calendar
  ncc app:enable contacts
  ncc app:enable notes
  ncc app:enable tasks
  ncc app:enable news

  # nettserver-previewgenerator
  cp -r /var/www/nettserver-previewgenerator /var/www/nextcloud/apps/previewgenerator
  ncc app:enable previewgenerator
  chown www-data:www-data /var/www/nextcloud/apps/previewgenerator

  # previews
  ncc config:app:set previewgenerator squareSizes --value="32 256"
  ncc config:app:set previewgenerator widthSizes  --value="256 384"
  ncc config:app:set previewgenerator heightSizes --value="256"
  ncc config:system:set preview_max_x --value 2048
  ncc config:system:set preview_max_y --value 2048
  ncc config:system:set jpeg_quality --value 60
  ncc config:app:set preview jpeg_quality --value="60"

  # other
  ncc config:system:set overwriteprotocol --value=https
  ncc -n db:convert-filecache-bigint
  ncc db:add-missing-indices

  echo "nextclod init done"
}

install(){ :; }

# License
#
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA
