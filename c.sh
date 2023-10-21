#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en_US.UTF-8
wpygV="23.5.4 V 0.9.9 "
[[ $EUID -ne 0 ]] && "请以root模式运行脚本" && exit
if [[ -f /etc/redhat-release ]]; then
release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
release="centos"
else
red "不支持你当前系统，请选择使用Ubuntu,Debian,Centos系统" && exit
fi
rm -rf /root/CFwarp.sh
bit=`uname -m`
if [[ $bit = aarch64 ]]; then
wget -O /root/CFwarp.sh https://gitlab.com/rwkgyg/CFwarp/-/raw/main/version/CFwarp.sh.a && chmod +x /root/CFwarp.sh
./CFwarp.sh
elif [[ $bit = x86_64 ]]; then
wget -O /root/CFwarp.sh https://gitlab.com/rwkgyg/CFwarp/-/raw/main/version/CFwarp.sh && chmod +x /root/CFwarp.sh
./CFwarp.sh
else
red "目前脚本不支持$bit架构" && exit
fi
