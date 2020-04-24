#!/bin/bash

# Periodically synchronize NextCloud for externally modified files
#
# GPL licensed - end of file
#
#

is_active()
{
  a2query -s nettserver &>/dev/null
}

configure() 
{
  if [[ $ACTIVE != "yes" ]]; then
    a2dissite nettserver
    echo "nettserver-web disabled"
  else
    a2ensite nettserver
    echo "nettserver-web enabled"
  fi

  # delayed in bg so it does not kill the connection, and we get AJAX response
  bash -c "sleep 2 && service apache2 reload" &>/dev/null &
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

