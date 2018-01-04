#!/bin/bash

DisableNode(){
  echo -e "$logHdr\n$(date) Unscheduling node"  >> ${logFile}
  $oc_cmd adm manage-node ${node} --schedulable=false  >> ${logFile} 2>&1

  if ($oc_cmd get pod -o wide --all-namespaces | grep -q ${node}); then
    echo "$node is running the following pods:" >> ${logFile}
    echo -e "\tNamespace                          Name\n\t--------------------------------   -----------------------------" >> ${logFile}
    $oc_cmd get pod -o wide --all-namespaces | grep ${node}|awk '{print $1,$2}' | while read nsPod
    do
      printf "\t%-34s %s\n" $(echo $nsPod|awk '{print $1}') $(echo $nsPod|awk '{print $2}') >> ${logFile}
    done
    $oc_cmd adm drain ${node} --force --delete-local-data  >> ${logFile} 2>&1

    i=1
    while [ "$i" -le "$numIntervals" ]; do
      echo "checking if node $node has been drained, attempt # $i" >> ${logFile}
      if ($oc_cmd get pod -o wide --all-namespaces | grep -q ${node}); then
        # Kill any pods pinned to this node in an 'Unknown' state
        for podStatus in Unknown
        do
          $oc_cmd get pod --all-namespaces -o wide | egrep "\s+$podStatus\s+.*$node"|while read podInfo
          do
            namespace=$(echo "$podInfo"|awk '{print $1}')
            podname=$(echo "$podInfo"|awk '{print $2}')
            echo -e "$(echo "killing $podInfo"|perl -pe 's/\s+/ /g')" >> ${logFile}
            $oc_cmd delete pod -n $namespace $podname  >> ${logFile} 2>&1
          done
        done

        i=$[$i+1]
        sleep $sleepInterval
      else
        break
      fi
    done
    if [ "$i" = "$numIntervals" ]; then
      echo -e "\033[31m\t\t*******  Did NOT evacuate node \033[7m$node\033[0m\033[31m in time  *******\033[0m" >> ${logFile}
    else
      echo "$(date) Node Drained"  >> ${logFile}
    fi
  fi
  echo "$(date) Node Unscheduled"  >> ${logFile}
}

EnableNode(){
  echo -e "$logHdr\n$(date) Scheduling node" >> ${logFile}
  if [ ! -d /etc/origin/master ]; then
    $oc_cmd adm manage-node ${node} --schedulable  >> ${logFile} 2>&1
    echo "$(date) Node Scheduled"  >> ${logFile}
  else
    echo "$(date) Node NOT Scheduled, as /etc/origin/master indicates node is a master"  >> ${logFile}
  fi
}

# Main
oc_cmd='oc --config /root/.kube/config'
node=$(hostname -f)
logFile=/var/log/os-unsched-node.log
logHdr="========================================================================"

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



