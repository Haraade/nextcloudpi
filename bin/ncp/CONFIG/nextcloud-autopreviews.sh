#!/bin/bash

# Periodically generate previews for the gallery
#
# GPL licensed - end of file
#

isactive()
{
  [[ -f "/etc/cron.d/nettserver-previews-auto" ]]
}

configure()
{
  [[ "$ACTIVE" != "yes" ]] && {
    rm -f /etc/cron.d/nettserver-previews-auto
    service cron restart
    echo "Automatic preview generation disabled"
    return 0
  }

  grep -qP "^\d+$" <<<"$RUNTIME" || { echo "Invalid RUNTIME value $RUNTIME"; return 1; }
  RUNTIME=$((RUNTIME*60))

  echo "0  2  *  *  *  root  /usr/local/bin/nextcloud-previews" >  /etc/cron.d/nettserver-previews-auto
  chmod 644 /etc/cron.d/nettserver-previews-auto

  cat > /usr/local/bin/nextcloud-previews <<EOF
#!/bin/bash
echo -e "\n[ nc-previews-auto ]" >> /var/log/nettserver.log
(
    for i in \$(seq 1 \$(nproc)); do
      ionice -c3 nice -n20 /usr/local/bin/ncc preview:pre-generate -n -vvv &
    done
    wait
) 2>&1 >>/var/log/nettserver.log &

PID=\$!
[[ "$RUNTIME" != 0 ]] && {
  for i in \$(seq 1 1 $RUNTIME); do
    sleep 1
    kill -0 "\$PID" &>/dev/null || break
  done
  pkill -f preview:pre-generate
}
wait "\$PID"
EOF
chmod +x /usr/local/bin/nextcloud-previews

  service cron restart
  echo "Automatic preview generation enabled"
  return 0
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
