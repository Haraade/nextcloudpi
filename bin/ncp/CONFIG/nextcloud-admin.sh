#!/bin/bash

# Change password for the Nextcloud admin user
#
# GPL licensed - end of file
#
#

configure()
{
  [[ "$PASSWORD" == "" ]] && { echo "empty password"; return 1; }
  [[ "$USER"     == "" ]] && { echo "empty user"    ; return 1; }
  [[ "$PASSWORD" == "$CONFIRM" ]] || { echo "passwords do not match"; return 1; }

  OC_PASS="$PASSWORD" \
    sudo -E -u www-data php /var/www/nextcloud/occ \
    user:resetpassword --password-from-env "$USER"
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
