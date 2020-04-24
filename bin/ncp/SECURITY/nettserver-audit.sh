#!/bin/bash

# Launch security audit reports for NETTSERVER
#
# GPL licensed - end of file
#
#

install()
{
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    lynis debsecan debian-goodies debsums
  cp /etc/lynis/default.prf /etc/lynis/nettserver.prf
  cat >> /etc/lynis/nettserver.prf <<EOF
# Won't install apt-listbugs and all its ruby dependencies
skip-test=CUST-0810

# Won't install puppet or similar
skip-test=TOOL-5002

# Have a preset partition scheme in the storage
skip-test=FILE-6310

# Don't use firewire
skip-test=STRG-1846

# USB is used in nettserver
skip-test=STRG-1840

# Won't recompile kernel to support auditd
skip-test=ACCT-9628

# Won't be protected against DDOS in self-hosting, will save the resources
skip-test=HTTP-6640
skip-test=HTTP-6641

# False positive about mysql root password
skip-test=DBS-1816

# won't recompile kernels for PAE NX
skip-test=KRNL-5677

# false positive with DNS settings. mDNS and dnsmasq
skip-test=NAME-4028

# false positive due to fail2ban
skip-test=FIRE-4513
EOF
}

configure()
{
  echo "General security audit"
  lynis audit system --profile /etc/lynis/nettserver.prf --no-colors

  echo "Known vulnerabilities in this system"
  debsecan
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

