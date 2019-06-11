#!/bin/bash -ex

[ -z "$1" ] && myblueprint="" || myblueprint=$1
cfy blueprint upload -b $myblueprint openstack--simple-blueprint.yaml
cfy deployment create -vvvv --skip-plugins-validation $myblueprint -b $myblueprint -i inputs-citycloud.yaml
cfy -v executions start -d $myblueprint install
