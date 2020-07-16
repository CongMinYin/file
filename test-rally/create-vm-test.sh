#!/bin/bash

# image: ubuntu-snapshot
# flavor: ubuntu
# tartget: test vm creation time

#date
openstack server delete ubuntu-test1
start=$(date +%s)
openstack server create --image ubuntu-snapshot --flavor ubuntu --network netflat ubuntu-test1

while true
do
    check_result=`openstack server list | grep ubuntu-test1 | awk '{print $6}'`
    echo $check_result
    if [[ $check_result =~ "ACTIVE" ]]
    then
        echo break
        break
    fi
done
active=$(date +%s)
ip=`openstack server list | grep ubuntu-test1 | awk '{print $8}'`
echo $ip
ip=${ip#*=}
echo $ip

# 进入隔离网络执行ping命令
# ip netns exec qdhcp-25bee494-8157-4d5f-b9c0-505be24881fc bash
while true
do
    #check_result=`openstack server list | grep ubuntu-test1 | awk '{print $6}'`
    #echo $check_result
    #if [[ $check_result =~ "ACTIVE" ]]
    if [[ `ip netns exec qdhcp-25bee494-8157-4d5f-b9c0-505be24881fc ping $ip -c 1` =~ "1 received" ]]
    then
        echo break
        break
    fi
done
#date
end=$(date +%s)
echo active: $(( $active - $start ))
echo active: $(( $end - $start ))
openstack server delete ubuntu-test1
