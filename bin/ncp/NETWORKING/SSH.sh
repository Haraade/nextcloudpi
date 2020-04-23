#!/bin/bash

# Activate/deactivate SSH
#
# GPL licensed - end of file
#

install() { :; }

is_active()
{
  systemctl -q is-enabled ssh &>/dev/null
}

configure() 
{
  [[ $ACTIVE != "yes" ]]  && {
    systemctl stop    ssh
    systemctl disable ssh
    echo "SSH disabled"
    return 0
  }

  [[ "$USER" == "root" ]] && [[ "$PASS" == "1234" ]] && {
    echo "Refusing to use the default Armbian user and password. It's insecure"
    return 1
  }

  # Check for insecure default root password ( taken from old jessie method )
  local SHADOW="$( grep -E '^root:' /etc/shadow )"
  test -n "${SHADOW}" && {
    local SALT=$(echo "${SHADOW}" | sed -n 's/root:\$6\$//;s/\$.*//p')

    [[ "${SALT}" != "" ]] && {
      local HASH=$(mkpasswd -msha-512 1234 "$SALT")
      grep -q "${HASH}" <<< "${SHADOW}" && {
        systemctl stop    ssh
        systemctl disable ssh
        echo "The user root is using the default password. Refusing to activate SSH"
        echo "SSH disabled"
        return 1
      }
    }
  }

  # Enable
  chage -d 0 "$USER"
  systemctl enable ssh
  systemctl start  ssh
  echo "SSH enabled"
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
