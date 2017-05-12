#!/bin/bash -xe
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

set -e

. ~/nova.rc


#Create mgmt network for neutron for tenant VMs
neutron net-show left > /dev/null 2>&1 || neutron net-create left
neutron subnet-show left_subnet > /dev/null 2>&1 || neutron subnet-create left "10.40.40.0/24"  --name left_subnet --gateway 10.40.40.254 --host-route destination=10.20.20.0/24,nexthop=10.40.40.254 

neutron net-show right > /dev/null 2>&1 || neutron net-create right
neutron subnet-show right_subnet > /dev/null 2>&1 || neutron subnet-create right "10.20.20.0/24" --name right_subnet  --gateway 10.20.20.254
 

if (nova show trafleft  > /dev/null 2>&1 );then
    echo "trafleft already installed"
else
    nova boot --image "Trusty x86_64" trafleft --key-name default --security-group default --flavor m1.small --user-data apache_userdata.txt --nic net-name=mgmt --nic net-name=left
    FLOAT_IP="$(nova floating-ip-create | grep ext_net | awk -F "|" '{ print $3}')"
    nova floating-ip-associate trafleft $FLOAT_IP
fi

if (nova show trafright  > /dev/null 2>&1 );then
    echo "trafright already installed"
else
    nova boot --image "Trusty x86_64" trafright --key-name default --security-group default --flavor m1.small --user-data apache_userdata.txt --nic net-name=mgmt --nic net-name=right
    FLOAT_IP="$(nova floating-ip-create | grep ext_net | awk -F "|" '{ print $3}')"
    nova floating-ip-associate trafright $FLOAT_IP
fi


if (nova show fos542  > /dev/null 2>&1 );then
    echo "fos542 already installed"
else
    neutron port-show left1 > /dev/null 2>&1 ||neutron port-create left --port-security-enabled=False --fixed-ip ip_address=10.40.40.254 --name left1 
    neutron port-show right1 > /dev/null 2>&1 ||neutron port-create right --port-security-enabled=False --fixed-ip ip_address=10.20.20.254 --name right1 
    LEFTPORT=`neutron port-show left1 -F id -f value`
    RIGHTPORT=`neutron port-show right1 -F id -f value`
    nova boot --image "fos542" fos542 --config-drive=true --key-name default  --security-group default  --flavor m1.small  --user-data fos-user-data.txt --nic net-name=mgmt --nic port-id=$LEFTPORT --nic port-id=$RIGHTPORT
    FLOAT_IP="$(nova floating-ip-create | grep ext_net | awk -F "|" '{ print $3}')"
    nova floating-ip-associate fos542 $FLOAT_IP
fi

#sudo iptables -t nat -A PREROUTING -p tcp --dport 4043 -j DNAT --to-destination 10.10.11.15:443
#sudo iptables -t nat -A PREROUTING -p tcp --dport 4022 -j DNAT --to-destination 10.10.11.15:22
