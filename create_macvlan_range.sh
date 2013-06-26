#!/bin/bash

COMMAND="$1"
END="$2"

case $COMMAND in
status)
    echo "Status..."
    ;;
start)
    echo "Starting $END devices"
    for device in $(seq 1 $END); do 
      echo "Starting mac$device..."
      ip link add link eth0 mac$device type macvlan
      dhclient mac$device
    done
    ;;
stop)
    echo "Stopping $END devices"
    for device in $(seq 1 $END); do
      echo "Deleting mac$device"
      ip link del mac$device
      ## Do something about dhclient processes
    done
    ;;
*)
    echo "Oops"
    exit 1
esac





