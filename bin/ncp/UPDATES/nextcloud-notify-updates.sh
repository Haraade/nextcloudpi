#!/bin/bash

# Install the latest News third party app
#
# GPL licensed - end of file
#
#

# check every hour
CHECKINTERVAL=1
NCDIR=/var/www/nextcloud

configure()
{
  [[ $ACTIVE != "yes" ]] && {
    rm -f /etc/cron.d/nettserver-notify-updates
    service cron restart
    echo "update web notifications disabled"
    return 0
  }

  # code
  cat > /usr/local/bin/nettserver-notify-update <<EOF
#!/bin/bash
source /usr/local/etc/library.sh
VERFILE=/usr/local/etc/nettserver-version
LATEST=/var/run/.nettserver-latest-version
NOTIFIED=/var/run/.nettserver-version-notified

test -e \$LATEST || exit 0;
/usr/local/bin/nettserver-test-updates || { echo "NETTSERVER up to date"; exit 0; }

test -e \$NOTIFIED && [[ "\$( cat \$LATEST )" == "\$( cat \$NOTIFIED )" ]] && {
  echo "Found update from \$( cat \$VERFILE ) to \$( cat \$LATEST ). Already notified"
  exit 0
}

echo "Found update from \$( cat \$VERFILE ) to \$( cat \$LATEST ). Sending notification..."

IFACE=\$( ip r | grep "default via" | awk '{ print \$5 }' | head -1 )
IP=\$( ip a show dev "\$IFACE" | grep global | grep -oP '\d{1,3}(\.\d{1,3}){3}' | head -1 )

notify_admin \
  "NETTSERVER update" \
  "Update from \$( cat \$VERFILE ) to \$( cat \$LATEST ) is available. Update from https://\$IP:4443"

cat \$LATEST > \$NOTIFIED
EOF
  chmod +x /usr/local/bin/nettserver-notify-update

  cat > /usr/local/bin/nettserver-notify-unattended-upgrade <<EOF
#!/bin/bash
source /usr/local/etc/library.sh

LOGFILE=/var/log/unattended-upgrades/unattended-upgrades.log
STAMPFILE=/var/run/.nettserver-notify-unattended-upgrades
VERFILE=/usr/local/etc/nettserver-version

test -e "\$LOGFILE" || { echo "\$LOGFILE not found"; exit 1; }

# find lines with package updates
LINE=\$( grep "INFO Packages that will be upgraded:" "\$LOGFILE" )

[[ "\$LINE" == "" ]] && { echo "no new upgrades"; exit 0; }

# extract package names
PKGS=\$( sed 's|^.*Packages that will be upgraded: ||' <<< "\$LINE" | tr '\\n' ' ' )

# mark lines as read
sed -i 's|INFO Packages that will be upgraded:|INFO Packages that will be upgraded :|' \$LOGFILE

echo -e "Packages automatically upgraded: \$PKGS\\n"

# notify
notify_admin \
  "NETTSERVER Unattended Upgrades" \
  "Packages automatically upgraded \$PKGS"
EOF
  chmod +x /usr/local/bin/nettserver-notify-unattended-upgrade

  # check every hour at 50th minute
  echo -e "MAILTO=\"\"\n50  */${CHECKINTERVAL} *  *  *  root /usr/local/bin/nettserver-notify-update && /usr/local/bin/nettserver-notify-unattended-upgrade" > /etc/cron.d/nettserver-notify-updates
  chmod 644 /etc/cron.d/nettserver-notify-updates
  [[ -f /run/crond.pid ]] && service cron restart

  echo "update web notifications enabled"
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

