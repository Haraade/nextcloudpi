#!/bin/bash

# Periodically update all installed Nextcloud Apps
#
# GPL licensed - end of file
#
#

configure() 
{
  local cronfile=/etc/cron.daily/nettserver-autoupdate-apps

  [[ "$ACTIVE" != "yes" ]] && { 
    rm -f "$cronfile"
    echo "automatic app updates disabled"
    return 0
  }

  cat > "$cronfile" <<EOF
#!/bin/bash
source /usr/local/etc/library.sh
OUT="\$(
echo "[ nextcloud-autoupdate-apps ]"
echo "checking for updates..."
/usr/local/bin/ncc app:update --all -n
)"
echo "\$OUT" >> /var/log/nettserver.log

APPS=\$( echo "\$OUT" | grep 'updated\$' | awk '{ print \$1 }')
[[ "\$APPS" != "" ]] && notify_admin "Apps updated" "\$APPS"
EOF
  chmod 755 "$cronfile"
  echo "automatic app updates enabled"
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

