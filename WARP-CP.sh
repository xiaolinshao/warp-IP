#!/bin/bash
sleep 5
green(){ echo -e "\033[32m\033[01m$1\033[0m";}
yellow(){ echo -e "\033[33m\033[01m$1\033[0m";}

info(){
v4=$(curl -s4m3 https://ip.gs -k)
v4d=$(curl -s4m3 https://ip.gs -k | awk -F '.' '{print $1}')
}

BEndpoint(){
grep Endpoint /etc/wireguard/wgcf.conf
if [[ -n $(grep -w 2606:4700:d0::a29f:c001 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/2606:4700:d0::a29f:c001/2606:4700:d0::a29f:c002/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 2606:4700:d0::a29f:c002 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/2606:4700:d0::a29f:c002/2606:4700:d0::a29f:c003/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 2606:4700:d0::a29f:c003 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/2606:4700:d0::a29f:c003/2606:4700:d0::a29f:c004/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 2606:4700:d0::a29f:c004 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/2606:4700:d0::a29f:c004/2606:4700:d0::a29f:c005/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 2606:4700:d0::a29f:c005 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/2606:4700:d0::a29f:c005/2606:4700:d0::a29f:c006/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 2606:4700:d0::a29f:c006 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/2606:4700:d0::a29f:c006/2606:4700:d0::a29f:c007/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 2606:4700:d0::a29f:c007 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/2606:4700:d0::a29f:c007/2606:4700:d0::a29f:c008/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 2606:4700:d0::a29f:c008 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/2606:4700:d0::a29f:c008/2606:4700:d0::a29f:c009/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 2606:4700:d0::a29f:c009 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/2606:4700:d0::a29f:c009/2606:4700:d0::a29f:c001/g" /etc/wireguard/wgcf.conf
fi
if [[ -n $(grep -w 2606:4700:d0::a29f:c101 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/2606:4700:d0::a29f:c101/2606:4700:d0::a29f:c102/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 2606:4700:d0::a29f:c102 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/2606:4700:d0::a29f:c102/2606:4700:d0::a29f:c103/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 2606:4700:d0::a29f:c103 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/2606:4700:d0::a29f:c103/2606:4700:d0::a29f:c104/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 2606:4700:d0::a29f:c104 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/2606:4700:d0::a29f:c104/2606:4700:d0::a29f:c105/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 2606:4700:d0::a29f:c105 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/2606:4700:d0::a29f:c105/2606:4700:d0::a29f:c106/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 2606:4700:d0::a29f:c106 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/2606:4700:d0::a29f:c106/2606:4700:d0::a29f:c107/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 2606:4700:d0::a29f:c107 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/2606:4700:d0::a29f:c107/2606:4700:d0::a29f:c108/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 2606:4700:d0::a29f:c108 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/2606:4700:d0::a29f:c108/2606:4700:d0::a29f:c109/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 2606:4700:d0::a29f:c109 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/2606:4700:d0::a29f:c109/2606:4700:d0::a29f:c101/g" /etc/wireguard/wgcf.conf
fi
if [[ -n $(grep -w 162.159.192.1 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/162.159.192.1/162.159.192.2/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 162.159.192.2 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/162.159.192.2/162.159.192.3/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 162.159.192.3 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/162.159.192.3/162.159.192.4/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 162.159.192.4 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/162.159.192.4/162.159.192.5/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 162.159.192.5 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/162.159.192.5/162.159.192.6/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 162.159.192.6 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/162.159.192.6/162.159.192.7/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 162.159.192.7 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/162.159.192.7/162.159.192.8/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 162.159.192.8 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/162.159.192.8/162.159.192.9/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 162.159.192.9 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/162.159.192.9/162.159.193.10/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 162.159.193.10 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/162.159.193.10/162.159.192.1/g" /etc/wireguard/wgcf.conf
fi
if [[ -n $(grep -w 162.159.193.1 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/162.159.193.1/162.159.193.2/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 162.159.193.2 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/162.159.193.2/162.159.193.3/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 162.159.193.3 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/162.159.193.3/162.159.193.4/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 162.159.193.4 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/162.159.193.4/162.159.193.5/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 162.159.193.5 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/162.159.193.5/162.159.193.6/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 162.159.193.6 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/162.159.193.6/162.159.193.7/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 162.159.193.7 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/162.159.193.7/162.159.193.8/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 162.159.193.8 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/162.159.193.8/162.159.193.9/g" /etc/wireguard/wgcf.conf
elif [[ -n $(grep -w 162.159.193.9 /etc/wireguard/wgcf.conf) ]]; then
sed -i "s/162.159.193.9/162.159.193.1/g" /etc/wireguard/wgcf.conf
fi
wg-quick down wgcf >/dev/null 2>&1
sleep 1
wg-quick up wgcf >/dev/null 2>&1
}

WGCFV4(){
while true; do
info
[[ "$v4d" = "ipd" ]] && green "恭喜！目前wgcf-ipv4的IP为($v4)，设置的IP段为ipd，下轮检测将在你设置的60秒后自动执行" && sleep 60s || (BEndpoint && yellow "遗憾！目前wgcf-ipv4的IP($v4)，设置的IP段为ipd，下轮检测将在你设置的20秒后自动执行" && sleep 20s)
done
}
green "开始刷wgcf-ipv4的IP，你设置的IP段为ipd" && WGCFV4
