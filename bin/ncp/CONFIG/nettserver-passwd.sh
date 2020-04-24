#!/bin/bash

# Change password for the nettserver-web user
#
# GPL licensed - end of file
#
#

configure()
{
  # update password
  echo -e "$PASSWORD\n$CONFIRM" | passwd nettserver &>/dev/null && \
    echo "password updated successfully" || \
    { echo "passwords do not match"; return 1; }

  # persist nettserver-web password in docker container
  [[ -f /.docker-image ]] && {
    mv /etc/shadow /data/etc/shadow
    ln -s /data/etc/shadow /etc/shadow
  }

  # Run cron.php once now to get all checks right in CI.
  sudo -u www-data php /var/www/nextcloud/cron.php

  # activate NETTSERVER
  a2ensite  nettserver nextcloud
  a2dissite nettserver-activation
  bash -c "sleep 1.5 && service apache2 reload" &>/dev/null &
}

install() { :; }

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
