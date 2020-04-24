#!/bin/bash

# Automatically apply Nextcloud updates
#
# GPL licensed - end of file
#
#

# just change NCVER and re-activate in update.sh to upgrade users
source /usr/local/etc/library.sh # sets NCVER

configure()
{
  [[ "$ACTIVE" != "yes" ]] && {
    rm -f /etc/cron.daily/nettserver-autoupdate-nextcloud
    echo "automatic Nextcloud updates disabled"
    return 0
  }

  cat > /etc/cron.daily/nettserver-autoupdate-nextcloud <<EOF
#!/bin/bash
source /usr/local/etc/library.sh

echo -e "[nettserver-update-nextcloud]"                          >> /var/log/nettserver.log
/usr/local/bin/nettserver-update-nextcloud "$NCVER" 2>&1 | tee -a /var/log/nettserver.log

if [[ \${PIPESTATUS[0]} -eq 0 ]]; then

  VER="\$( /usr/local/bin/ncc status | grep "version:" | awk '{ print \$3 }' )"

  notify_admin "NETTSERVER" "Nextcloud was updated to \$VER"
fi
echo "" >> /var/log/nettserver.log
EOF
  chmod 755 /etc/cron.daily/nettserver-autoupdate-nextcloud
  echo "automatic Nextcloud updates enabled"
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

