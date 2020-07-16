#!/bin/bash

# image: ubuntu-snapshot
# flavor: ubuntu
# tartget: test vm creation time

#date
createAndDeleteVm(){
# 如果存在则删除，不存在则无事发生
openstack server delete $1
start=$(date +%s)
#openstack server create --image ubuntu-snapshot --flavor ubuntu --network netflat $1
openstack server create --image windows-snapshot --flavor windows --network netflat $1

# ACTIVE状态之后才会出现ip
while true
do
    check_result=`openstack server list | grep $1 | awk '{print $6}'`
    #echo $check_result
    if [[ $check_result =~ "ACTIVE" ]]
    then
        #echo break
        break
    fi
done
active=$(date +%s)

# 获取IP
ip=`openstack server list | grep $1 | awk '{print $8}'`
#echo $ip
ip=${ip#*=}
echo $ip

# 进入隔离网络执行ping命令
# ip netns exec qdhcp-25bee494-8157-4d5f-b9c0-505be24881fc bash
while true
do
    #check_result=`openstack server list | grep $1 | awk '{print $6}'`
    #echo $check_result
    #if [[ $check_result =~ "ACTIVE" ]]
    if [[ `ip netns exec qdhcp-25bee494-8157-4d5f-b9c0-505be24881fc ping $ip -c 1` =~ "1 received" ]]
    then
        #echo break
        break
    fi
done
#date
end=$(date +%s)
echo $1 active: $(( $active - $start ))s >> result.txt
echo $1 total: $(( $end - $start ))s >> result.txt
openstack server delete $1
}

#echo  >> result.txt
echo "***** test start *****" >> result.txt
date >> result.txt 
echo serial create 2 vms test >> result.txt 
createAndDeleteVm test1
createAndDeleteVm test2

echo parallel create 2 vms test >> result.txt 
parallel_start=$(date +%s)
createAndDeleteVm test3 &
createAndDeleteVm test4 &
wait
parallel_end=$(date +%s)
echo 2 vms paralle time: $(( $parallel_end - $parallel_start ))s >> result.txt

echo parallel create 4 vms test >> result.txt 
parallel_start=$(date +%s)
createAndDeleteVm test5 &
createAndDeleteVm test6 &
createAndDeleteVm test7 &
createAndDeleteVm test8 &
wait
parallel_end=$(date +%s)
echo 4 vms paralle time: $(( $parallel_end - $parallel_start ))s >> result.txt
