#!/bin/bash
# This script will be set up tinyvpn
# by fw867
# 注意将serverip改成成你vps的地址，使用ifconfig查看，有些vps网卡上是没有公网ip的，比如谷歌云，虽然能申请固定公网ip,但是网卡是内网ip,你就必须设置成内网的ip,直接设置成固定外网ip会导致无法访问外网

export serverip=ifconfig eth0 | grep "inet" | sed 's/^.*addr://g' | sed s/Bcast.*$//
export tinyvpn_port=4031
export udp2raw_port=4032
export local_addr=172.16.0.0
export password=131415

add_firewall(){
	sysctl -w net.ipv4.ip_forward=1
	if !(iptables-save -t nat | grep -q "tinyFecVPN"); then
		iptables -t nat -A POSTROUTING -s $local_addr/16 -m comment --comment "tinyFecVPN" -j SNAT --to-source $serverip
	fi
}

del_firewall(){
	iptables -t nat -D POSTROUTING -s $local_addr/16 -m comment --comment "tinyFecVPN" -j SNAT --to-source $serverip >/dev/null 2>&1
}

start_udp2raw(){
	udp2raw -s -l0.0.0.0:$udp2raw_port -r 127.0.0.1:8855 --raw-mode faketcp -a -k "$password" --log-level 2& >/dev/null 2>&1
}

start_tinyvpn(){
	tinyvpn -s -l 127.0.0.1:8855 --sub-net $local_addr -k "$password" --log-level 2& >/dev/null 2>&1
}

start_tinyvpn_ony(){
	tinyvpn -s -l 0.0.0.0:$tinyvpn_port --sub-net $local_addr -k "$password" --log-level 2& >/dev/null 2>&1
}

stop_all(){
  echo begin stop!
	del_firewall
	local tinyvpn=`pidof tinyvpn`
	local udp2raw=`pidof udp2raw`
	[ -n "$tinyvpn" ] && killall tinyvpn
	[ -n "$udp2raw" ] && killall udp2raw
	sleep 3
	echo all vpn is stop!
}

start_all(){
	start_udp2raw
	start_tinyvpn
	add_firewall
	echo all vpn is running!
}

case $1 in
start)
	start_all
	;;
stop)
	stop_all
	;;
one)
	start_tinyvpn_ony
	add_firewall
	echo tinyvpn is running!
	;;
*)
	stop_all
	start_all
	;;
esac
