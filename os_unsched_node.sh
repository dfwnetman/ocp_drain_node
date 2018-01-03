#!/bin/bash

oc_cmd='oc --config /root/.kube/config'


DisableNode(){
  $oc_cmd adm manage-node ${node} --schedulable=false

  if ($oc_cmd get pod -o wide --all-namespaces | grep -q ${node}); then
    echo "$node is running the following pods:"
    echo -e "\tNamespace                          Name\n\t--------------------------------   -----------------------------"
    $oc_cmd get pod -o wide --all-namespaces | grep ${node}|awk '{print $1,$2}' | while read nsPod
    do
      printf "\t%-34s %s\n" $(echo $nsPod|awk '{print $1}') $(echo $nsPod|awk '{print $2}')
    done
    $oc_cmd adm drain ${node} --force --delete-local-data

    i=1
    while [ "$i" -le "$numIntervals" ]; do
      echo "checking if node $node has been evacuated, attempt # $i"
      if ($oc_cmd get pod -o wide --all-namespaces | grep -q ${node}); then
        # Kill any pods pinned to this node in an 'Unknown' state
        for podStatus in Unknown
        do
          $oc_cmd get pod --all-namespaces -o wide | egrep "\s+$podStatus\s+.*$node"|while read podInfo
          do
            namespace=$(echo "$podInfo"|awk '{print $1}')
            podname=$(echo "$podInfo"|awk '{print $2}')
            echo -e "$(echo "killing $podInfo"|perl -pe 's/\s+/ /g')"
            $oc_cmd delete pod -n $namespace $podname
          done
        done

        i=$[$i+1]
        sleep $sleepInterval
      else
        break
      fi
    done
    if [ "$i" = "$numIntervals" ]; then
      echo -e "\033[31m\t\t*******  Did NOT evacuate node \033[7m$node\033[0m\033[31m in time  *******\033[0m"
    fi
  fi
}

EnableNode(){
  $oc_cmd adm manage-node ${node} --schedulable
}


node=$(hostname -f)
nodeType=$(hostname | cut -c10-12)

numIntervals=90
sleepInterval=2

case "$1" in
  stop)
      DisableNode
      ;;
  start)
      EnableNode
      ;;
     
  *)
      echo "Usage: $0 <<start|stop>>"
      exit 1
esac


