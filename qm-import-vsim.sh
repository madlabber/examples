#!/bin/bash

vmid=$1
vmname=$2
vsimova=$3
storage=$4
bridge=$5  #e0a/e0b
bridge2=$6 #e0c/e0d

if [ "$1" == "" ];then
  echo "usage:"
  echo "qm-import-vsim.sh <vmid> <vmname> <path-to-ova> <storage> <bridge1 - e0a/b> <bridge2 - e0c/d>"
  echo
  echo "example:"
  echo "./qm-import-vsim.sh 135 vsim135 /var/lib/vz/import/vsim-netapp-DOT9.14.1-cm_nodar.ova local-lvm vmbr1 vmbr0"
  echo
  exit
fi

dirname="${vsimova%.*}"
mkdir $dirname
tar -xvf $vsimova -C $dirname

#create the vm
qm create $vmid \
    --name $vmname \
    --cpu cputype=host \
    --cores 1 \
    --sockets 2 \
    --memory 8192 \
    --net0 bridge=$bridge,e1000 \
    --net1 bridge=$bridge,e1000 \
    --net2 bridge=$bridge2,e1000 \
    --net3 bridge=$bridge2,e1000 \
    --serial0 socket \
    --serial1 socket

#import disks
qm disk import $vmid $dirname/vsim-NetAppDOT-simulate-disk1.vmdk $storage --format raw
qm disk import $vmid $dirname/vsim-NetAppDOT-simulate-disk2.vmdk $storage --format raw
qm disk import $vmid $dirname/vsim-NetAppDOT-simulate-disk3.vmdk $storage --format raw
qm disk import $vmid $dirname/vsim-NetAppDOT-simulate-disk4.vmdk $storage --format raw

#attach disks
qm set $vmid --ide0 file=$storage:vm-$vmid-disk-0
qm set $vmid --ide1 file=$storage:vm-$vmid-disk-1
qm set $vmid --ide2 file=$storage:vm-$vmid-disk-2
qm set $vmid --ide3 file=$storage:vm-$vmid-disk-3

#configure boot order
qm set $vmid --bootdisk ide0 --boot order=ide0


