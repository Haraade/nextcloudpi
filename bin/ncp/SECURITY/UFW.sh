#!/bin/bash

# Uncomplicated Firewall
#
# GPL licensed - end of file
#
#


install()
{
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ufw
  systemctl disable ufw

  # Disable logging to kernel
  grep -q maxsize /etc/logrotate.d/ufw || sed -i /weekly/amaxsize2M /etc/logrotate.d/ufw

  return 0
}

configure()
{
  [[ "$ACTIVE" != yes ]] && {
    ufw --force reset
    systemctl disable ufw
    systemctl stop ufw
    echo "UFW disabled"
    return 0
  }
  ufw --force enable
  systemctl enable ufw
  systemctl start ufw

  echo -e "\n# web server rules"
  ufw allow 80/tcp
  ufw allow 443/tcp
  ufw allow 4443/tcp

  echo -e "\n# SSH rules"
  ufw allow 22

  echo -e "\n# DNS rules"
  ufw allow 53

  #echo -e "\n# UPnP rules"
  #ufw allow proto udp from 192.168.0.0/16

  echo "UFW enabled"
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

