#!/bin/bash

# Automatically apply NETTSERVER updates
#
# GPL licensed - end of file
#
#

configure()
{
  [[ $ACTIVE != "yes" ]] && { 
    rm -f /etc/cron.daily/nettserver-autoupdate
    echo "automatic NETTSERVER updates disabled"
    return 0
  }

  cat > /etc/cron.daily/nettserver-autoupdate <<EOF
#!/bin/bash
source /usr/local/etc/library.sh
if /usr/local/bin/nettserver-test-updates; then
  /usr/local/bin/nettserver-update || exit 1
  notify_admin "NETTSERVER" "NETTSERVER was updated to \$(cat /usr/local/etc/nettserver-version)"
fi
EOF
  chmod 755 /etc/cron.daily/nettserver-autoupdate
  echo "automatic NETTSERVER updates enabled"
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

