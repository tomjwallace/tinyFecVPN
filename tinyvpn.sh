#!/bin/bash
# This script will be set up tinyvpn
# by fw867
# 注意将serverip改成成你vps的地址，使用ifconfig查看，有些vps网卡上是没有公网ip的，比如谷歌云，虽然能申请固定公网ip,但是网卡是内网ip,你就必须设置成内网的ip,直接设置成固定外网ip会导致无法访问外网

export serverip=$(ifconfig eth0 | grep "inet" | sed 's/^.*addr://g' | sed s/Bcast.*$//)
export tinyvpn_port=4031
export udp2raw_port=4032
export local_addr=172.16.0.0
export password=131415


sysctl -w net.ipv4.ip_forward=1

iptables -t nat -A POSTROUTING -s $local_addr/16 -m comment --comment "tinyFecVPN" -j SNAT --to-source $serverip

#udp2raw -s -l0.0.0.0:$udp2raw_port -r 127.0.0.1:8855 --raw-mode faketcp -a -k "$password"  &
tinyvpn -s -l 127.0.0.1:8855 --sub-net $local_addr -k "$password" &





	


