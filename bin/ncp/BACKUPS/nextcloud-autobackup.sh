#!/bin/bash
# Nextcloud backups
#
# GPL licensed - end of file
#
#

configure()
{
  [[ $ACTIVE != "yes" ]] && {
    rm -f /etc/cron.d/nettserver-backup-auto
    service cron restart
    echo "automatic backups disabled"
    return 0
  }

  cat > /usr/local/bin/nettserver-backup-auto <<EOF
#!/bin/bash
source /usr/local/etc/library.sh
[ -x /usr/local/bin/nettserver-backup-auto-before ] && /usr/local/bin/nettserver-backup-auto-before
/usr/local/bin/ncc maintenance:mode --on
/usr/local/bin/nettserver-backup "$DESTDIR" "$INCLUDEDATA" "$COMPRESS" "$BACKUPLIMIT" || failed=true
/usr/local/bin/ncc maintenance:mode --off
[[ "\$failed" == "true" ]] && \
 notify_admin "Auto-backup failed" "Your automatic backup failed"
[ -x /usr/local/bin/nettserver-backup-auto-after ] && /usr/local/bin/nettserver-backup-auto-after
EOF
  chmod +x /usr/local/bin/nettserver-backup-auto

  echo "0  3  */${BACKUPDAYS}  *  *  root  /usr/local/bin/nettserver-backup-auto" > /etc/cron.d/nettserver-backup-auto
  chmod 644 /etc/cron.d/nettserver-backup-auto
  service cron restart

  echo "automatic backups enabled"
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

