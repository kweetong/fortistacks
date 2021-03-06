#!/bin/bash

# #######
# Copyright (c) 2016 Fortinet All rights reserved
# Author: Nicolas Thomas nthomas_at_fortinet.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
#    * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    * See the License for the specific language governing permissions and
#    * limitations under the License.

set -x

#if nova access not set then get them from nova.rc
if [ -x "$OS_AUTH_URL" ]; then 
  echo "get the Openstack access from ~/nova.rc"
  . ~/nova.rc
fi

echo "deleting VMs, ports and networks may raise errors (floating for expl)"
echo "please check if actually cleaning before logging a bug"

cat << EOF | openstack
server delete trafleft
server delete trafright
server delete fortigate


port delete left1
port delete right1
network delete left
network delete right

EOF
# release all floating ip not in use (save $$)
openstack floating ip list -f value -c "Floating IP Address" --status DOWN |xargs openstack floating ip delete
