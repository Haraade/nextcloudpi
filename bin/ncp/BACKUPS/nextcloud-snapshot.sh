#!/bin/bash

# Nextcloud BTRFS snapshots
#
# GPL licensed - end of file
#

install()
{
  wget https://raw.githubusercontent.com/nachoparker/btrfs-snp/master/btrfs-snp -O /usr/local/bin/btrfs-snp
  chmod +x /usr/local/bin/btrfs-snp
}

configure()
{
  ncc maintenance:mode --on

  local DATADIR MOUNTPOINT
  DATADIR=$( ncc config:system:get datadirectory ) || {
    echo -e "Error reading data directory. Is NextCloud running?";
    return 1;
  }

  # file system check
  MOUNTPOINT="$( stat -c "%m" "$DATADIR" )" || return 1
  [[ "$( stat -fc%T "$MOUNTPOINT" )" != "btrfs" ]] && {
    echo "$MOUNTPOINT is not in a BTRFS filesystem"
    return 1
  }

  btrfs-snp $MOUNTPOINT manual $LIMIT 0 ../nettserver-snapshots

  ncc maintenance:mode --off
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

