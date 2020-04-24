#!/bin/bash

# Automount configuration for NETTSERVER
#
# GPL licensed - end of file
#
#


install()
{
  apt-get update
  apt-get install -y --no-install-recommends udiskie inotify-tools

  cat > /etc/udev/rules.d/99-udisks2.rules <<'EOF'
ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{UDISKS_FILESYSTEM_SHARED}="1"
EOF

  cat > /usr/lib/systemd/system/nettserver-automount.service <<'EOF'
[Unit]
Description=Automount USB drives
Before=mysqld.service dphys-swapfile.service fail2ban.service

[Service]
Restart=always
ExecStartPre=/bin/bash -c "rmdir /media/* || true"
ExecStart=/usr/bin/udiskie -NTF

[Install]
WantedBy=multi-user.target
EOF

  cat > /usr/lib/systemd/system/nettserver-automount-links.service <<'EOF'
[Unit]
Description=Monitor /media for mountpoints and create nextcloud* symlinks
Before=nc-automount.service

[Service]
Restart=always
ExecStart=/usr/local/etc/nettserver-automount-links-mon

[Install]
WantedBy=multi-user.target
EOF

  cat > /usr/local/etc/nettserver-automount-links <<'EOF'
#!/bin/bash

ls -d /media/* &>/dev/null && {

  # remove old links
  for l in $( ls /media/ ); do
    test -L /media/"$l" && rm /media/"$l"
  done

  # create links
  i=0
  for d in $( ls -d /media/* 2>/dev/null ); do
    if [ $i -eq 0 ]; then
      test -e /media/nextcloud   || test -d "$d" && ln -sT "$d" /media/nextcloud
    else
      test -e /media/nextcloud$i || test -d "$d" && ln -sT "$d" /media/nextcloud$i
    fi
    i=$(( i + 1 ))
  done

}
EOF
  chmod +x /usr/local/etc/nettserver-automount-links

  cat > /usr/local/etc/nettserver-automount-links-mon <<'EOF'
#!/bin/bash
inotifywait --monitor --event create --event delete --format '%f %e' /media/ | \
  grep --line-buffered ISDIR | while read f; do
    echo $f
    sleep 0.5
    /usr/local/etc/nettserver-automount-links
done
EOF
  chmod +x /usr/local/etc/nettserver-automount-links-mon
}

configure()
{
  [[ $ACTIVE != "yes" ]] && {
    systemctl stop    nettserver-automount
    systemctl stop    nettserver-automount-links
    systemctl disable nettserver-automount
    systemctl disable nettserver-automount-links
    rm -rf /etc/systemd/system/{mariadb,dphys-swapfile,fail2ban}.service.d
    systemctl daemon-reload
    echo "automount disabled"
    return 0
  }
  systemctl enable  nettserver-automount
  systemctl enable  nettserver-automount-links
  systemctl start   nettserver-automount
  systemctl start   nettserver-automount-links

  # create delays in some units
  mkdir -p /etc/systemd/system/mariadb.service.d
  cat > /etc/systemd/system/mariadb.service.d/nettserver-delay-automount.conf <<'EOF'
[Service]
ExecStartPre=/bin/sleep 20
Restart=on-failure
EOF

  mkdir -p /etc/systemd/system/dphys-swapfile.service.d
  cat > /etc/systemd/system/dphys-swapfile.service.d/nettserver-delay-automount.conf <<'EOF'
[Service]
ExecStartPre=/bin/sleep 30
EOF

  mkdir -p /etc/systemd/system/fail2ban.service.d
  cat > /etc/systemd/system/fail2ban.service.d/nettserver-delay-automount.conf <<'EOF'
[Service]
ExecStartPre=/bin/sleep 10
EOF

  systemctl daemon-reload
  echo "automount enabled"
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

