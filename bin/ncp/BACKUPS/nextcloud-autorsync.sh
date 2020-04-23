#!/bin/bash

# Periodically sync Nextcloud datafolder through rsync
#
# GPL licensed - end of file
#

install()
{
  apt-get update
  apt-get install --no-install-recommends -y rsync
}

configure()
{
  [[ $ACTIVE != "yes" ]] && { 
    rm -f /etc/cron.d/nettserver-rsync-auto
    echo "automatic rsync disabled"
    return 0
  }

  local DATADIR
  DATADIR=$( ncc config:system:get datadirectory ) || {
    echo -e "Error reading data directory. Is NextCloud running and configured?";
    return 1;
  }

  # Check if the ssh access is properly configured. For this purpose the command : or echo is called remotely.
  # If one of the commands works, the test is successful.
  [[ "$DESTINATION" =~ : ]] && {
    local NET="$( sed 's|:.*||' <<<"$DESTINATION" )"
    local SSH=( ssh -o "BatchMode=yes" -p "$PORTNUMBER" "$NET" )
    ${SSH[@]} echo || { echo "SSH non-interactive not properly configured"; return 1; }
  }

  echo "0  5  */${SYNCDAYS}  *  *  root  /usr/bin/rsync -ax -e \"ssh -p $PORTNUMBER\" --delete \"$DATADIR\" \"$DESTINATION\"" > /etc/cron.d/nettserver-rsync-auto
  chmod 644 /etc/cron.d/nettserver-rsync-auto
  service cron restart

  echo "automatic rsync enabled"
}

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

