#!/bin/bash -x 

#Tearing down
[ -z "$1" ] && myblueprint="cfy-plugin" || myblueprint=$1

# checking
TOBECANCELED=`cfy execution list -d $myblueprint --json |grep '"status": "started"'|jq .id |  sed 's/\"//g'`
[ -z "$TOBECANCELED" ] || cfy execution cancel $TOBECANCELED
cfy executions start uninstall -d $myblueprint --force -p ignore_failure=true
sleep 2
cfy deployments delete $myblueprint
sleep 2
cfy blueprint delete $myblueprint

