#!/bin/bash

COMMAND="$1"
START=101
END="$2"
END=$(($END+$START-1))

GATEWAY=10.122.152.1
PHY="eth0"

case $COMMAND in
status)
    echo "Status... pretty good, thanks"
    ;;
start)
    ## Modprobe some handy modules
    modprobe macvlan
    modprobe 8021q

    ## Ensure the wired interface is up
    ip link set $PHY up
    
    #echo "Starting $(($END-$START+1)) devices"
    for device in $(seq $START $END); do 

      ## Add physical interface to the VLAN
      vconfig add $PHY $device &> /dev/null

      ## Ensure the VLAN interface is up, and link it to the physical interface
      ip link set $PHY.$device up
      ip link add dev mac$device link $PHY.$device type macvlan

      ## Try and get an IP for this interface
      dhclient -v mac$device &>/tmp/dhcpmac$device.log ; PID=$!
      ADDRESS=`ip addr show dev mac$device | grep "inet " | awk {'print $2'} | cut -d/ -f1`

      ip link set mac$device up

      echo $device mac$device >> /etc/iproute2/rt_tables

      ## Add IP based source routing
      ip rule add from $ADDRESS table $device
      ip route add default via $GATEWAY dev mac$device table mac$device

      MAC=`ip link show dev mac$device | grep -i ether | awk {'print $2'}`

      echo mac$device " : " $MAC " : " $ADDRESS
    done
    ;;
stop)
    echo "Stopping $(($END-$START)) devices"
    for device in $(seq $START $END); do
      ADDRESS=`ip addr show dev mac$device | grep "inet " | awk {'print $2'} | cut -d/ -f1`
      ip link del mac$device
      vconfig rem $PHY.$device
      ip rule del from $ADDRESS table $device
      ## Do something about dhclient processes
      pkill dhclient
      echo "mac$device deleted"
    done
    ## I hope /etc/iproute2/rt_tables isn't dear to you...
    cp rt_tables_original /etc/iproute2/rt_tables
    ;;
*)
    echo "Incorrect usage. Try, start, stop or status"
    exit 1
esac





