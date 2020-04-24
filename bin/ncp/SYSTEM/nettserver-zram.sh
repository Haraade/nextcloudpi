#!/bin/bash

# NETTSERVER ZRAM settings
#
# GPL licensed - end of file
#
#

install()
{
  cat > /etc/systemd/system/zram.service <<EOF
[Unit]
Description=Set up ZRAM

[Service]
Type=oneshot
ExecStart=/usr/local/bin/nettserver-zram start
ExecStop=/usr/local/bin/nettserver-zram  stop
RemainAfterExit=yes

[Install]
WantedBy=sysinit.target
EOF

cat > /usr/local/bin/nettserver-zram <<'EOF'
#!/bin/bash

case "$1" in
  start)
      CORES=$(nproc --all)
      modprobe zram num_devices=$CORES || exit 1

      swapoff -a

      TOTALMEM=`free | grep -e "^Mem:" | awk '{print $2}'`
      MEM=$(( ($TOTALMEM / $CORES)* 1024 ))

      core=0
      while [ $core -lt $CORES ]; do
        echo $MEM > /sys/block/zram$core/disksize
        mkswap /dev/zram$core
        swapon -p 5 /dev/zram$core
        let core=core+1
      done
      ;;

  stop)
      swapoff -a
      rmmod zram
      ;;
  *)
      echo "Usage: $0 {start|stop}" >&2
      exit 1
      ;;
esac
EOF
chmod +x /usr/local/bin/nettserver-zram
}

configure()
{
  [[ $ACTIVE != "yes" ]] && { 
    systemctl stop    zram
    systemctl disable zram
    echo "ZRAM disabled"
    return 0
  }
  systemctl start  zram
  systemctl enable zram
  echo "ZRAM enabled"
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

