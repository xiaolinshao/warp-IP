#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en_US.UTF-8
red='\033[0;31m'
bblue='\033[0;34m'
plain='\033[0m'
red(){ echo -e "\033[31m\033[01m$1\033[0m";}
green(){ echo -e "\033[32m\033[01m$1\033[0m";}
yellow(){ echo -e "\033[33m\033[01m$1\033[0m";}
blue(){ echo -e "\033[36m\033[01m$1\033[0m";}
white(){ echo -e "\033[37m\033[01m$1\033[0m";}
bblue(){ echo -e "\033[34m\033[01m$1\033[0m";}
rred(){ echo -e "\033[35m\033[01m$1\033[0m";}
readtp(){ read -t5 -n26 -p "$(yellow "$1")" $2;}
readp(){ read -p "$(yellow "$1")" $2;}
[[ $EUID -ne 0 ]] && yellow "请以root模式运行脚本" && exit 1

start(){
yellow " 请稍等3秒……正在扫描vps类型及参数中……"
if [[ -f /etc/redhat-release ]]; then
release="Centos"
elif cat /etc/issue | grep -q -E -i "debian"; then
release="Debian"
elif cat /etc/issue | grep -q -E -i "ubuntu"; then
release="Ubuntu"
elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
release="Centos"
elif cat /proc/version | grep -q -E -i "debian"; then
release="Debian"
elif cat /proc/version | grep -q -E -i "ubuntu"; then
release="Ubuntu"
elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
release="Centos"
else 
red "不支持你当前系统，请选择使用Ubuntu,Debian,Centos系统。" && rm -f CFwarp.sh && exit 1
fi
vsid=`grep -i version_id /etc/os-release | cut -d \" -f2 | cut -d . -f1`
sys(){
[ -f /etc/os-release ] && grep -i pretty_name /etc/os-release | cut -d \" -f2 && return
[ -f /etc/lsb-release ] && grep -i description /etc/lsb-release | cut -d \" -f2 && return
[ -f /etc/redhat-release ] && awk '{print $0}' /etc/redhat-release && return;}
op=`sys`
version=`uname -r | awk -F "-" '{print $1}'`
main=`uname  -r | awk -F . '{print $1}'`
minor=`uname -r | awk -F . '{print $2}'`
bit=`uname -m`
[[ $bit = x86_64 ]] && cpu=AMD64
[[ $bit = aarch64 ]] && cpu=ARM64
vi=`systemd-detect-virt`
if [[ -n $(sysctl net.ipv4.tcp_congestion_control 2>/dev/null | awk -F ' ' '{print $3}') ]]; then
bbr=`sysctl net.ipv4.tcp_congestion_control | awk -F ' ' '{print $3}'`
elif [[ -n $(ping 10.0.0.2 -c 2 | grep ttl) ]]; then
bbr="openvz版bbr-plus"
else
bbr="暂不支持显示"
fi
if [[ $vi = openvz ]]; then
TUN=$(cat /dev/net/tun 2>&1)
if [[ ! $TUN =~ 'in bad state' ]] && [[ ! $TUN =~ '处于错误状态' ]] && [[ ! $TUN =~ 'Die Dateizugriffsnummer ist in schlechter Verfassung' ]]; then 
red "检测到未开启TUN，现尝试添加TUN支持" && sleep 4
cd /dev
mkdir net
mknod net/tun c 10 200
chmod 0666 net/tun
TUN=$(cat /dev/net/tun 2>&1)
if [[ ! $TUN =~ 'in bad state' ]] && [[ ! $TUN =~ '处于错误状态' ]] && [[ ! $TUN =~ 'Die Dateizugriffsnummer ist in schlechter Verfassung' ]]; then 
green "添加TUN支持失败，建议与VPS厂商沟通或后台设置开启" && exit 0
else
green "恭喜，添加TUN支持成功，现添加防止重启VPS后TUN失效的TUN守护功能" && sleep 4
cat>/root/tun.sh<<-\EOF
#!/bin/bash
cd /dev
mkdir net
mknod net/tun c 10 200
chmod 0666 net/tun
EOF
chmod +x /root/tun.sh
grep -qE "^ *@reboot root bash /root/tun.sh >/dev/null 2>&1" /etc/crontab || echo "@reboot root bash /root/tun.sh >/dev/null 2>&1" >> /etc/crontab
green "TUN守护功能已启动"
fi
fi
fi
[[ $(type -P yum) ]] && yumapt='yum -y' || yumapt='apt -y'
[[ $(type -P wget) ]] || (yellow "检测到wget未安装，升级安装中" && $yumapt update;$yumapt install wget)
[[ $(type -P curl) ]] || (yellow "检测到curl未安装，升级安装中" && $yumapt update;$yumapt install curl)
[[ ! $(type -P python3) ]] && (yellow "检测到python3未安装，升级安装中" && $yumapt update;$yumapt install python3)
[[ ! $(type -P screen) ]] && (yellow "检测到screen未安装，升级安装中" && $yumapt update;$yumapt install screen)
}

ud4='sed -i "7 s/^/PostUp = ip -4 rule add from $(ip route get 162.159.192.1 | grep -oP '"'src \K\S+') lookup main\n/"'" /etc/wireguard/wgcf.conf && sed -i "7 s/^/PostDown = ip -4 rule delete from $(ip route get 162.159.192.1 | grep -oP '"'src \K\S+') lookup main\n/"'" /etc/wireguard/wgcf.conf'
ud6='sed -i "7 s/^/PostUp = ip -6 rule add from $(ip route get 2606:4700:d0::a29f:c001 | grep -oP '"'src \K\S+') lookup main\n/"'" /etc/wireguard/wgcf.conf && sed -i "7 s/^/PostDown = ip -6 rule delete from $(ip route get 2606:4700:d0::a29f:c001 | grep -oP '"'src \K\S+') lookup main\n/"'" /etc/wireguard/wgcf.conf'
ud4ud6='sed -i "7 s/^/PostUp = ip -4 rule add from $(ip route get 162.159.192.1 | grep -oP '"'src \K\S+') lookup main\n/"'" /etc/wireguard/wgcf.conf && sed -i "7 s/^/PostDown = ip -4 rule delete from $(ip route get 162.159.192.1 | grep -oP '"'src \K\S+') lookup main\n/"'" /etc/wireguard/wgcf.conf && sed -i "7 s/^/PostUp = ip -6 rule add from $(ip route get 2606:4700:d0::a29f:c001 | grep -oP '"'src \K\S+') lookup main\n/"'" /etc/wireguard/wgcf.conf && sed -i "7 s/^/PostDown = ip -6 rule delete from $(ip route get 2606:4700:d0::a29f:c001 | grep -oP '"'src \K\S+') lookup main\n/"'" /etc/wireguard/wgcf.conf'
c1="sed -i '/0\.0\.0\.0\/0/d' /etc/wireguard/wgcf.conf"
c2="sed -i '/\:\:\/0/d' /etc/wireguard/wgcf.conf"
c3="sed -i 's/engage.cloudflareclient.com/162.159.193.10/g' /etc/wireguard/wgcf.conf"
c4="sed -i 's/engage.cloudflareclient.com/2606:4700:d0::a29f:c001/g' /etc/wireguard/wgcf.conf"
c5="sed -i 's/1.1.1.1/8.8.8.8,2001:4860:4860::8888/g' /etc/wireguard/wgcf.conf"
c6="sed -i 's/1.1.1.1/2001:4860:4860::8888,8.8.8.8/g' /etc/wireguard/wgcf.conf"

ShowWGCF(){
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"
v6=$(curl -s6m10 https://ip.gs -k)
v4=$(curl -s4m10 https://ip.gs -k)
isp4=`curl -s --user-agent "${UA_Browser}" https://api.ip.sb/geoip/$v4 -k | awk -F "isp" '{print $2}' | awk -F "offset" '{print $1}' | sed "s/[,\":]//g"`
isp6=`curl -s --user-agent "${UA_Browser}" https://api.ip.sb/geoip/$v6 -k | awk -F "isp" '{print $2}' | awk -F "offset" '{print $1}' | sed "s/[,\":]//g"`
[[ -e /etc/wireguard/wgcf+p.log ]] && cfplus="WARP+普通账户(有限WARP+流量)，设备名称：$(grep -s 'Device name' /etc/wireguard/wgcf+p.log | awk '{ print $NF }')" || cfplus="WARP+Teams账户(无限WARP+流量)"
AE="阿联酋（United Arab Emirates）";AU="澳大利亚（Australia）";BG="保加利亚（Bulgaria）";BR="巴西（Brazil）";CA="加拿大（Canada）";CH="瑞士（Switzerland）";CL="智利（Chile)";CN="中国（China）";CO="哥伦比亚（Colombia）";DE="德国（Germany)";ES="西班牙（Spain)";FI="芬兰（Finland）";FR="法国（France）";GB="英国（United Kingdom）";HK="香港（Hong Kong）";ID="印度尼西亚（Indonesia）";IE="爱尔兰（Ireland）";IL="以色列（Israel）";IN="印度（India）";IT="意大利（Italy）";JP="日本（Japan）";KR="韩国（South Korea）";LU="卢森堡（Luxembourg）";MX="墨西哥（Mexico）";MY="马来西亚（Malaysia）";NL="荷兰（Netherlands）";NZ="新西兰（New Zealand）";PH="菲律宾（Philippines）";RO="罗马尼亚（Romania）";RU="俄罗斯（Russian）";SA="沙特（Saudi Arabia）";SE="瑞典（Sweden）";SG="新加坡（Singapore）";TW="台湾（Taiwan）";US="美国（United States）";VN="越南（Vietnam）";ZA="南非（South Africa）"
if [[ -n $v4 ]]; then
result4=$(curl -4 --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/81215567" 2>&1)
[[ "$result4" == "404" ]] && NF="遗憾哦，当前IP仅解锁奈飞Netflix自制剧..."
[[ "$result4" == "403" ]] && NF="死心了，当前IP不支持解锁奈飞Netflix....."
[[ "$result4" == "000" ]] && NF="检测到网络有问题，再次进入脚本可能就好了.."
[[ "$result4" == "200" ]] && NF="恭喜呀，当前IP可解锁奈飞Netflix流媒体..."
g4=$(eval echo \$$(curl -s --user-agent "${UA_Browser}" https://api.ip.sb/geoip/$v4 -k | awk -F "country_code" '{print $2}' | awk -F "region_code" '{print $1}' | sed "s/[,\":}]//g"))
wgcfv4=$(curl -s4 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
case ${wgcfv4} in 
plus) 
WARPIPv4Status=$(white "IPV4 WARP+状态：\c" ; rred "运行中，$cfplus" ; white " [ Cloudflare服务商 ]获取IPV4：\c" ; rred "$v4" ; white " IPV4 奈飞NF解锁情况：\c" ; rred "$NF  \c"; white " IPV4 所在地区：\c" ; rred "$g4");;  
on) 
WARPIPv4Status=$(white "IPV4 WARP状态：\c" ; green "运行中，WARP普通账户(无限WARP流量)" ; white " [ Cloudflare服务商 ]获取IPV4：\c" ; green "$v4" ; white " IPV4 奈飞NF解锁情况：\c" ; green "$NF  \c"; white " IPV4 所在地区：\c" ; green "$g4");;
off) 
WARPIPv4Status=$(white "IPV4 WARP状态：\c" ; yellow "关闭中" ; white " [ $isp4服务商 ]获取IPV4：\c" ; yellow "$v4" ; white " IPV4 奈飞NF解锁情况：\c" ; yellow "$NF  \c"; white " IPV4 所在地区：\c" ; yellow "$g4");; 
esac 
else
WARPIPv4Status=$(white "IPV4 状态：\c" ; red "不存在IPV4地址 ")
fi 
if [[ -n $v6 ]]; then
result6=$(curl -6 --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/81215567" 2>&1)
[[ "$result6" == "404" ]] && NF="遗憾哦，当前IP仅解锁奈飞Netflix自制剧..."
[[ "$result6" == "403" ]] && NF="死心了，当前IP不支持解锁奈飞Netflix....."
[[ "$result6" == "000" ]] && NF="检测到网络有问题，再次进入脚本可能就好了.."
[[ "$result6" == "200" ]] && NF="恭喜呀，当前IP可解锁奈飞Netflix流媒体..."
g6=$(eval echo \$$(curl -s --user-agent "${UA_Browser}" https://api.ip.sb/geoip/$v6 -k | awk -F "country_code" '{print $2}' | awk -F "region_code" '{print $1}' | sed "s/[,\":}]//g"))
wgcfv6=$(curl -s6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
case ${wgcfv6} in 
plus) 
WARPIPv6Status=$(white "IPV6 WARP+状态：\c" ; rred "运行中，$cfplus" ; white " [ Cloudflare服务商 ]获取IPV6：\c" ; rred "$v6" ; white " IPV6 奈飞NF解锁情况：\c" ; rred "$NF  \c"; white " IPV6 所在地区：\c" ; rred "$g6");;  
on) 
WARPIPv6Status=$(white "IPV6 WARP状态：\c" ; green "运行中，WARP普通账户(无限WARP流量)" ; white " [ Cloudflare服务商 ]获取IPV6：\c" ; green "$v6" ; white " IPV6 奈飞NF解锁情况：\c" ; green "$NF  \c"; white " IPV6 所在地区：\c" ; green "$g6");;
off) 
WARPIPv6Status=$(white "IPV6 WARP状态：\c" ; yellow "关闭中" ; white " [ $isp6服务商 ]获取IPV6：\c" ; yellow "$v6" ; white " IPV6 奈飞NF解锁情况：\c" ; yellow "$NF  \c"; white " IPV6 所在地区：\c" ; yellow "$g6");;
esac 
else
WARPIPv6Status=$(white "IPV6 状态：\c" ; red "不存在IPV6地址 ")
fi 
}

ShowSOCKS5(){
if [[ $(systemctl is-active warp-svc) = active ]]; then
mport=`warp-cli --accept-tos settings 2>/dev/null | grep 'WarpProxy on port' | awk -F "port " '{print $2}'`
AE="阿联酋（United Arab Emirates）";AU="澳大利亚（Australia）";BG="保加利亚（Bulgaria）";BR="巴西（Brazil）";CA="加拿大（Canada）";CH="瑞士（Switzerland）";CL="智利（Chile)";CN="中国（China）";CO="哥伦比亚（Colombia）";DE="德国（Germany)";ES="西班牙（Spain)";FI="芬兰（Finland）";FR="法国（France）";GB="英国（United Kingdom）";HK="香港（Hong Kong）";ID="印度尼西亚（Indonesia）";IE="爱尔兰（Ireland）";IL="以色列（Israel）";IN="印度（India）";IT="意大利（Italy）";JP="日本（Japan）";KR="韩国（South Korea）";LU="卢森堡（Luxembourg）";MX="墨西哥（Mexico）";MY="马来西亚（Malaysia）";NL="荷兰（Netherlands）";NZ="新西兰（New Zealand）";PH="菲律宾（Philippines）";RO="罗马尼亚（Romania）";RU="俄罗斯（Russian）";SA="沙特（Saudi Arabia）";SE="瑞典（Sweden）";SG="新加坡（Singapore）";TW="台湾（Taiwan）";US="美国（United States）";VN="越南（Vietnam）";ZA="南非（South Africa）"
result=$(curl -sx socks5h://localhost:$mport -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/81215567" 2>&1)
[[ "$result" == "404" ]] && NF="遗憾哦，当前IP仅解锁奈飞Netflix自制剧..."
[[ "$result" == "403" ]] && NF="死心了，当前IP不支持解锁奈飞Netflix....."
[[ "$result" == "000" ]] && NF="检测到网络有问题，再次进入脚本可能就好了.."
[[ "$result" == "200" ]] && NF="恭喜呀，当前IP可解锁奈飞Netflix流媒体..."
socks5=$(curl -sx socks5h://localhost:$mport www.cloudflare.com/cdn-cgi/trace -k --connect-timeout 2 | grep warp | cut -d= -f2) 
s5ip=`curl -sx socks5h://localhost:$mport ip.gs -k`
s5gj=$(eval echo \$$(curl -s -A "Mozilla" https://api.ip.sb/geoip/$S5ip -k | awk -F "country_code" '{print $2}' | awk -F "region_code" '{print $1}' | sed "s/[,\":}]//g"))
case ${socks5} in 
plus) 
S5Status=$(white "Socks5 WARP+状态：\c" ; rred "运行中，WARP+普通账户(剩余WARP+流量:$((`warp-cli --accept-tos account | grep Quota | awk '{ print $(NF) }'`/1000000000))GiB)" ; white " Socks5 端口：\c" ; rred "$mport" ; white " [ Cloudflare服务商 ]获取IPV4：\c" ; rred "$s5ip" ; white " IPV4 奈飞NF解锁情况：\c" ; rred "$NF  \c" ; white " IPV4 所在地区：\c" ; rred "$s5gj");;  
on) 
S5Status=$(white "Socks5 WARP状态：\c" ; green "运行中，WARP普通账户(无限WARP流量)" ; white " Socks5 端口：\c" ; green "$mport" ; white " [ Cloudflare服务商 ]获取IPV4：\c" ; green "$s5ip" ; white " IPV4 奈飞NF解锁情况：\c" ; green "$NF  \c"; white " IPV4 所在地区：\c" ; green "$s5gj");;  
*) 
S5Status=$(white "Socks5 WARP状态：\c" ; yellow "已安装Socks5-WARP客户端，但端口处于关闭状态")
esac 
else
S5Status=$(white "Socks5 WARP状态：\c" ; red "未安装Socks5-WARP客户端")
fi
}

docker(){
if [[ -n $(ip a | grep docker) ]]; then
red "检测到VPS已安装docker，如继续安装Wgcf-WARP，docker会失效"
sleep 3s
yellow "6秒后继续安装，退出安装请按Ctrl+c"
sleep 6s
fi
}

STOPwgcf(){
if [[ $(type -P warp-cli) ]]; then
red "已安装Socks5-WARP(+)，不支持当前选择的Wgcf-WARP(+)安装方案" 
systemctl restart wg-quick@wgcf ; bash CFwarp.sh
fi
}
v4v6(){
v6=$(curl -s6m10 https://ip.gs -k)
v4=$(curl -s4m10 https://ip.gs -k)
}

ABC(){
echo $ABC1 | sh
echo $ABC2 | sh
echo $ABC3 | sh
echo $ABC4 | sh
echo $ABC5 | sh
}
conf(){
rm -rf /etc/wireguard/wgcf.conf
cp -f /etc/wireguard/wgcf-profile.conf /etc/wireguard/wgcf.conf >/dev/null 2>&1
}

first4(){
checkwgcf
if [[ $wgcfv4 =~ on|plus && -z $wgcfv6 ]]; then
[[ -n /etc/gai.conf ]] && grep -qE '^ *precedence ::ffff:0:0/96  100' /etc/gai.conf || echo 'precedence ::ffff:0:0/96  100' >> /etc/gai.conf
sed -i '/^label 2002::\/16   2/d' /etc/gai.conf
else
sed -i '/^precedence ::ffff:0:0\/96  100/d;/^label 2002::\/16   2/d' /etc/gai.conf
fi
}

nat4(){
[[ -n $(ip route get 162.159.192.1 | grep -oP 'src \K\S+') ]] && ABC4=$ud4 || ABC4=echo
}

WGCFv4(){
yellow "稍等3秒，检测VPS内warp环境"
docker && checkwgcf
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "当前原生v4+v6双栈vps首次安装wgcf-warp\n现添加IPV4单栈wgcf-warp模式" && sleep 2
ABC1=$c5 && ABC2=$c2 && ABC3=$ud4 && WGCFins
fi
if [[ -n $v6 && -z $v4 ]]; then
green "当前原生v6单栈vps首次安装wgcf-warp\n现添加IPV4单栈wgcf-warp模式" && sleep 2
ABC1=$c5 && ABC2=$c4 && ABC3=$c2 && nat4 && WGCFins
fi
if [[ -z $v6 && -n $v4 ]]; then
green "当前原生v4单栈vps首次安装wgcf-warp\n现添加IPV4单栈wgcf-warp模式" && sleep 2
STOPwgcf ; ABC1=$c5 && ABC2=$c2 && ABC3=$c3 && ABC4=$ud4 && WGCFins
fi
first4
else
wg-quick down wgcf >/dev/null 2>&1
sleep 1 && v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "当前原生v4+v6双栈vps已安装wgcf-warp\n现快速切换IPV4单栈wgcf-warp模式" && sleep 2
conf && ABC1=$c5 && ABC2=$c2 && ABC3=$ud4 && ABC
fi
if [[ -n $v6 && -z $v4 ]]; then
green "当前原生v6单栈vps已安装wgcf-warp\n现快速切换IPV4单栈wgcf-warp模式" && sleep 2
conf && ABC1=$c5 && ABC2=$c4 && ABC3=$c2 && nat4 && ABC
fi
if [[ -z $v6 && -n $v4 ]]; then
green "当前原生v4单栈vps已安装wgcf-warp\n现快速切换IPV4单栈wgcf-warp模式" && sleep 2
STOPwgcf ; conf && ABC1=$c5 && ABC2=$c2 && ABC3=$c3 && ABC4=$ud4 && ABC
fi
CheckWARP && first4 && ShowWGCF && WGCFmenu
fi
}

WGCFv6(){
yellow "稍等3秒，检测VPS内warp环境"
docker && checkwgcf
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "当前原生v4+v6双栈vps首次安装wgcf-warp\n现添加IPV6单栈wgcf-warp模式" && sleep 2
ABC1=$c5 && ABC2=$c1 && ABC3=$ud6 && WGCFins
fi
if [[ -n $v6 && -z $v4 ]]; then
green "当前原生v6单栈vps首次安装wgcf-warp\n现添加IPV6单栈wgcf-warp模式(无IPV4！！！)" && sleep 2
ABC1=$c6 && ABC2=$c1 && ABC3=$c4 && nat4 && ABC5=$ud6 && WGCFins
fi
if [[ -z $v6 && -n $v4 ]]; then
green "当前原生v4单栈vps首次安装wgcf-warp\n现添加IPV6单栈wgcf-warp模式" && sleep 2
ABC1=$c5 && ABC2=$c3 && ABC3=$c1 && WGCFins
fi
else
wg-quick down wgcf >/dev/null 2>&1
sleep 1 && v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "当前原生v4+v6双栈vps已安装wgcf-warp\n现快速切换IPV6单栈wgcf-warp模式" && sleep 2
conf && ABC1=$c5 && ABC2=$c1 && ABC3=$ud6 && ABC
fi
if [[ -n $v6 && -z $v4 ]]; then
green "当前原生v6单栈vps已安装wgcf-warp\n现快速切换IPV6单栈wgcf-warp模式(无IPV4！！！)" && sleep 2
conf && ABC1=$c6 && ABC2=$c1 && ABC3=$c4 && nat4 && ABC5=$ud6 && ABC
fi
if [[ -z $v6 && -n $v4 ]]; then
green "当前原生v4单栈vps已安装wgcf-warp\n现快速切换IPV6单栈wgcf-warp模式" && sleep 2
conf && ABC1=$c5 && ABC2=$c3 && ABC3=$c1 && ABC
fi
CheckWARP && ShowWGCF && WGCFmenu
fi
}

WGCFv4v6(){
yellow "稍等3秒，检测VPS内warp环境"
docker && checkwgcf
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "当前原生v4+v6双栈vps首次安装wgcf-warp\n现添加IPV4+IPV6双栈wgcf-warp模式" && sleep 2
STOPwgcf ; ABC1=$c5 && ABC2=$ud4ud6 && WGCFins
fi
if [[ -n $v6 && -z $v4 ]]; then
green "当前原生v6单栈vps首次安装wgcf-warp\n现添加IPV4+IPV6双栈wgcf-warp模式" && sleep 2
STOPwgcf ; ABC1=$c5 && ABC2=$c4 && ABC3=$ud6 && nat4 && WGCFins
fi
if [[ -z $v6 && -n $v4 ]]; then
green "当前原生v4单栈vps首次安装wgcf-warp\n现添加IPV4+IPV6双栈wgcf-warp模式" && sleep 2
STOPwgcf ; ABC1=$c5 && ABC2=$c3 && ABC3=$ud4 && WGCFins
fi
else
wg-quick down wgcf >/dev/null 2>&1
sleep 1 && v4v6
if [[ -n $v4 && -n $v6 ]]; then
green "当前原生v4+v6双栈vps已安装wgcf-warp\n现快速切换IPV4+IPV6双栈wgcf-warp模式" && sleep 2
STOPwgcf ; conf && ABC1=$c5 && ABC2=$ud4ud6 && ABC
fi
if [[ -n $v6 && -z $v4 ]]; then
green "当前原生v6单栈vps已安装wgcf-warp\n现快速切换IPV4+IPV6双栈wgcf-warp模式" && sleep 2
STOPwgcf ; conf && ABC1=$c5 && ABC2=$c4 && ABC3=$ud6 && nat4 && ABC
fi
if [[ -z $v6 && -n $v4 ]]; then
green "当前原生v4单栈vps已安装wgcf-warp\n现快速切换IPV4+IPV6双栈wgcf-warp模式" && sleep 2
STOPwgcf ; conf && ABC1=$c5 && ABC2=$c3 && ABC3=$ud4 && ABC
fi
CheckWARP && ShowWGCF && WGCFmenu
fi
}

WGCFmenu(){
white "------------------------------------------------------------------------------------------------"
white " 当前VPS IPV4接管出站流量情况如下 "
blue " ${WARPIPv4Status}"
white "------------------------------------------------------------------------------------------------"
white " 当前VPS IPV6接管出站流量情况如下"
blue " ${WARPIPv6Status}"
white "------------------------------------------------------------------------------------------------"
}
S5menu(){
white "------------------------------------------------------------------------------------------------"
white " 当前Socks5-WARP客户端本地代理127.0.0.1情况如下"
blue " ${S5Status}"
white "------------------------------------------------------------------------------------------------"
}
back(){
white "------------------------------------------------------------------------------------------------"
white " 回主菜单，请按任意键"
white " 退出脚本，请按Ctrl+C"
get_char && bash CFwarp.sh
}

IP_Status_menu(){
white "------------------------------------------------------------------------------------------------"
WGCFmenu;S5menu 
}

menu(){
green "rwkgyg-CFwarp脚本快捷键使用指南"
green "注意：进入实时显示Screen状态后，退出当前Screen界面：Ctrl+a+d  终止当前Screen运行：Ctrl+c "
yellow "------------------------------------------"
blue "cf wd     : Wgcf-warp临时关闭"
blue "cf wu     : Wgcf-warp开启"
blue "cf wr     : Wgcf-warp重新启动"
blue "cf 5d     : Socks5-warp临时关闭"
blue "cf 5u     : Socks5-warp开启"
blue "cf sup    : 实时显示Screen运行状态：Wgcf-warp进程守护"          
blue "cf saw    : 实时显示Screen运行状态：刷Netflix奈飞及区域的warp"   
blue "cf scr    : 实时显示Screen运行状态：刷指定区域的warp"            
blue "cf scp    : 实时显示Screen运行状态：刷指定IP段的warp"          
blue "cf        : 显示CFwarp主菜单"
blue "cf h      : 显示CFwarp快捷键使用指南"
yellow "------------------------------------------"
}

lncf(){
if [[ $(type -P wg-quick) || $(type -P warp-cli) ]]; then
chmod +x /root/CFwarp.sh 
ln -sf /root/CFwarp.sh /usr/bin/cf
fi
}
checkwgcf(){
wgcfv6=$(curl -s6m6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
wgcfv4=$(curl -s4m6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
}
CheckWARP(){
i=0
wg-quick down wgcf >/dev/null 2>&1
systemctl start wg-quick@wgcf >/dev/null 2>&1
while [ $i -le 4 ]; do let i++
yellow "共执行5次，第$i次获取WARP的IP中……"
systemctl restart wg-quick@wgcf >/dev/null 2>&1
checkwgcf
[[ $wgcfv4 =~ on|plus || $wgcfv6 =~ on|plus ]] && green "恭喜！WARP的IP获取成功！" && break || red "遗憾！WARP的IP获取失败"
done
checkwgcf
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
yellow "安装WARP失败，还原VPS，卸载Wgcf-WARP组件中……"
cwg
green "卸载Wgcf-WARP组件完成"
green "失败建议如下："
[[ $release = Centos && ${vsid} -lt 7 ]] && yellow "当前系统版本号：Centos $vsid \n建议使用 Centos 7 以上系统 " 
[[ $release = Ubuntu && ${vsid} -lt 18 ]] && yellow "当前系统版本号：Ubuntu $vsid \n建议使用 Ubuntu 18 以上系统 " 
[[ $release = Debian && ${vsid} -lt 10 ]] && yellow "当前系统版本号：Debian $vsid \n建议使用 Debian 10 以上系统 "
yellow "1、强烈建议使用官方源升级系统及内核加速！如已使用第三方源及内核加速，请务必更新到最新版，或重置为官方源"
yellow "2、部分VPS系统极度精简，相关依赖需自行安装后再尝试"
yellow "3、查看https://www.cloudflarestatus.com/,你当前VPS就近区域可能处于黄色的【Re-routed】状态"
exit 0
else 
screen -d >/dev/null 2>&1
[[ -e /root/check.sh ]] && screen -S aw -X quit ; screen -UdmS aw bash -c '/bin/bash /root/check.sh'
[[ -e /root/WARP-CR.sh ]] && screen -S cr -X quit ; screen -UdmS cr bash -c '/bin/bash /root/WARP-CR.sh'
[[ -e /root/WARP-CP.sh ]] && screen -S cp -X quit ; screen -UdmS cp bash -c '/bin/bash /root/WARP-CP.sh'
if [[ -e /root/WARP-UP.sh ]]; then
screen -S up -X quit ; screen -UdmS up bash -c '/bin/bash /root/WARP-UP.sh'
else
readtp "是否安装WARP在线监测守护进程（Y/y）？(5秒后默认为N，不安装):" warpup
echo 
if [[ $warpup = [Yy] ]]; then
cat>/root/WARP-UP.sh<<-\EOF
#!/bin/bash
red(){ echo -e "\033[31m\033[01m$1\033[0m";}
green(){ echo -e "\033[32m\033[01m$1\033[0m";}
checkwgcf(){
wgcfv6=$(curl -s6m6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
wgcfv4=$(curl -s4m6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
}
warpclose(){
wg-quick down wgcf >/dev/null 2>&1 ; systemctl stop wg-quick@wgcf >/dev/null 2>&1 ; systemctl disable wg-quick@wgcf >/dev/null 2>&1
}
warpopen(){
wg-quick down wgcf >/dev/null 2>&1 ; systemctl enable wg-quick@wgcf >/dev/null 2>&1 ; systemctl start wg-quick@wgcf >/dev/null 2>&1 ; systemctl restart wg-quick@wgcf >/dev/null 2>&1
}
warpre(){
i=0
while [ $i -le 4 ]; do let i++
warpopen
checkwgcf
[[ $wgcfv4 =~ on|plus || $wgcfv6 =~ on|plus ]] && green "中断后的WARP尝试获取IP成功！" && break || red "中断后的WARP尝试获取IP失败！"
done
checkwgcf
if [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
warpclose
red "由于5次尝试获取WARP的IP失败，现执行停止并关闭WARP，VPS恢复原IP状态"
fi
}
while true; do
green "检测WARP是否启动中…………"
checkwgcf
[[ $wgcfv4 =~ on|plus || $wgcfv6 =~ on|plus ]] && green "恭喜！WARP状态为运行中！下轮检测将在你设置的60秒后自动执行" && sleep 60s || (warpre ; green "下轮检测将在你设置的50秒后自动执行" ; sleep 50s)
done
EOF
readp "WARP状态为运行时，重新检测WARP状态间隔时间（回车默认60秒）,请输入间隔时间（例：50秒，输入50）:" stop
[[ -n $stop ]] && sed -i "s/60s/${stop}s/g;s/60秒/${stop}秒/g" /root/WARP-UP.sh || green "默认间隔60秒"
readp "WARP状态为中断时(连续5次失败自动关闭WARP)，继续检测WARP状态间隔时间（回车默认50秒）,请输入间隔时间（例：50秒，输入50）:" goon
[[ -n $goon ]] && sed -i "s/50s/${goon}s/g;s/50秒/${goon}秒/g" /root/WARP-UP.sh || green "默认间隔50秒"
[[ -e /root/WARP-UP.sh ]] && screen -S up -X quit ; screen -UdmS up bash -c '/bin/bash /root/WARP-UP.sh'
green "设置screen窗口名称'up'，离线后台WARP在线守护进程" && sleep 2
grep -qE "^ *@reboot root screen -UdmS up bash -c '/bin/bash /root/WARP-UP.sh' >/dev/null 2>&1" /etc/crontab || echo "@reboot root screen -UdmS up bash -c '/bin/bash /root/WARP-UP.sh' >/dev/null 2>&1" >> /etc/crontab
green "添加WARP在线守护进程功能，重启VPS也会自动生效"
fi
fi
fi
}

dns(){
if [[ -n $v6 && -z $v4 ]]; then
echo -e "nameserver 2001:4860:4860::8888\nnameserver 8.8.8.8" > /etc/resolv.conf
else
echo -e "nameserver 8.8.8.8\nnameserver 2001:4860:4860::8888" > /etc/resolv.conf
fi
}
dig9(){
if [[ -n $(grep 'DiG 9' /etc/hosts) ]]; then
echo -e "search blue.kundencontroller.de\noptions rotate\nnameserver 2a02:180:6:5::1c\nnameserver 2a02:180:6:5::4\nnameserver 2a02:180:6:5::1e\nnameserver 2a02:180:6:5::1d" > /etc/resolv.conf
fi
}

get_char(){
SAVEDSTTY=`stty -g`
stty -echo
stty cbreak
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}

WGCFins(){
rm -rf /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /etc/wireguard/wgcf-profile.conf /etc/wireguard/wgcf-account.toml /etc/wireguard/wgcf+p.log /etc/wireguard/ID /usr/bin/wireguard-go wgcf-account.toml wgcf-profile.conf
ShowWGCF
if [[ $release = Centos ]]; then
if [[ ${vsid} =~ 8 ]]; then
cd /etc/yum.repos.d/ && mkdir backup && mv *repo backup/ 
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo
sed -i -e "s|mirrors.cloud.aliyuncs.com|mirrors.aliyun.com|g " /etc/yum.repos.d/CentOS-*
sed -i -e "s|releasever|releasever-stream|g" /etc/yum.repos.d/CentOS-*
yum clean all && yum makecache
fi
yum install epel-release -y || yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-${vsid}.noarch.rpm -y
yum install iproute iptables wireguard-tools -y
elif [[ $release = Debian ]]; then
apt install lsb-release -y
echo "deb http://deb.debian.org/debian $(lsb_release -sc)-backports main" | tee /etc/apt/sources.list.d/backports.list
apt update -y;apt install iproute2 openresolv dnsutils iptables -y;apt install wireguard-tools --no-install-recommends -y      		
elif [[ $release = Ubuntu ]]; then
apt update -y;apt install iproute2 openresolv dnsutils iptables -y;apt install wireguard-tools --no-install-recommends -y			
fi
[[ $cpu = AMD64 ]] && wget -N https://gitlab.com/rwkgyg/cfwarp/raw/main/wgcf_2.2.15_amd64 -O /usr/local/bin/wgcf && chmod +x /usr/local/bin/wgcf         
[[ $cpu = ARM64 ]] && wget -N https://gitlab.com/rwkgyg/cfwarp/raw/main/wgcf_2.2.15_arm64 -O /usr/local/bin/wgcf && chmod +x /usr/local/bin/wgcf
if [[ $main -lt 5 || $minor -lt 6 ]] || [[ $vi =~ lxc|openvz ]]; then
[[ -e /usr/bin/wireguard-go ]] || wget -N https://gitlab.com/rwkgyg/cfwarp/raw/main/wireguard-go -O /usr/bin/wireguard-go && chmod +x /usr/bin/wireguard-go
fi
echo | wgcf register
until [[ -e wgcf-account.toml ]]
do
yellow "申请WARP普通账户过程中可能会多次提示：429 Too Many Requests，请等待30秒" && sleep 1
echo | wgcf register --accept-tos
done
wgcf generate
yellow "开始自动设置WARP的MTU最佳网络吞吐量值，以优化WARP网络！"
MTUy=1500
MTUc=10
if [[ -n $v6 && -z $v4 ]]; then
ping='ping6'
IP1='2606:4700:4700::1111'
IP2='2001:4860:4860::8888'
else
ping='ping'
IP1='1.1.1.1'
IP2='8.8.8.8'
fi
while true; do
if ${ping} -c1 -W1 -s$((${MTUy} - 28)) -Mdo ${IP1} >/dev/null 2>&1 || ${ping} -c1 -W1 -s$((${MTUy} - 28)) -Mdo ${IP2} >/dev/null 2>&1; then
MTUc=1
MTUy=$((${MTUy} + ${MTUc}))
else
MTUy=$((${MTUy} - ${MTUc}))
[[ ${MTUc} = 1 ]] && break
fi
[[ ${MTUy} -le 1360 ]] && MTUy='1360' && break
done
MTU=$((${MTUy} - 80))
green "MTU最佳网络吞吐量值= $MTU 已设置完毕"
sed -i "s/MTU.*/MTU = $MTU/g" wgcf-profile.conf
cp -f wgcf-profile.conf /etc/wireguard/wgcf.conf >/dev/null 2>&1
echo $ABC1 | sh
echo $ABC2 | sh
echo $ABC3 | sh
echo $ABC4 | sh
echo $ABC5 | sh
mv -f wgcf-profile.conf /etc/wireguard >/dev/null 2>&1
mv -f wgcf-account.toml /etc/wireguard >/dev/null 2>&1
systemctl enable wg-quick@wgcf >/dev/null 2>&1
CheckWARP && first4
ShowWGCF && WGCFmenu && lncf && menu
}

SOCKS5ins(){
yellow "检测Socks5-WARP安装环境中……"
if [[ $release = Centos ]]; then
[[ ! ${vsid} =~ 8 ]] && yellow "当前系统版本号：Centos $vsid \nSocks5-WARP仅支持Centos 8 " && bash CFwarp.sh 
elif [[ $release = Ubuntu ]]; then
[[ ! ${vsid} =~ 16|18|20 ]] && yellow "当前系统版本号：Ubuntu $vsid \nSocks5-WARP仅支持 Ubuntu 16.04/18.04/20.04系统 " && bash CFwarp.sh 
elif [[ $release = Debian ]]; then
[[ ! ${vsid} =~ 9|10|11 ]] && yellow "当前系统版本号：Debian $vsid \nSocks5-WARP仅支持 Debian 9/10/11系统 " && bash CFwarp.sh 
fi
[[ $(warp-cli --accept-tos status 2>/dev/null) =~ 'Connected' ]] && red "当前Socks5-WARP已经在运行中" && bash CFwarp.sh

systemctl stop wg-quick@wgcf >/dev/null 2>&1
v4v6
if [[ -n $v6 && -z $v4 ]]; then
systemctl start wg-quick@wgcf >/dev/null 2>&1
red "纯IPV6的VPS目前不支持安装Socks5-WARP" && bash CFwarp.sh
elif [[ -n $v4 && -z $v6 ]]; then
systemctl start wg-quick@wgcf >/dev/null 2>&1
checkwgcf
[[ $wgcfv4 =~ on|plus ]] && red "纯IPV4的VPS已安装Wgcf-WARP-IPV4(选项1或者选项3)，不支持安装Socks5-WARP" && bash CFwarp.sh
elif [[ -n $v4 && -n $v6 ]]; then
systemctl start wg-quick@wgcf >/dev/null 2>&1
checkwgcf
[[ $wgcfv4 =~ on|plus || $wgcfv6 =~ on|plus ]] && red "原生双栈VPS已安装Wgcf-WARP-IPV4/IPV6(选项1或选项2)，请先卸载。然后安装Socks5-WARP，最后安装Wgcf-WARP-IPV4/IPV6" && bash CFwarp.sh
fi
systemctl start wg-quick@wgcf >/dev/null 2>&1
checkwgcf
if [[ $wgcfv4 =~ on|plus && $wgcfv6 =~ on|plus ]]; then
red "已安装Wgcf-WARP-IPV4+IPV6(选项3)，不支持安装Socks5-WARP" && bash CFwarp.sh
fi

if [[ $release = Centos ]]; then 
if [[ ${vsid} =~ 8 ]]; then
cd /etc/yum.repos.d/ && mkdir backup && mv *repo backup/ 
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo
sed -i -e "s|mirrors.cloud.aliyuncs.com|mirrors.aliyun.com|g " /etc/yum.repos.d/CentOS-*
sed -i -e "s|releasever|releasever-stream|g" /etc/yum.repos.d/CentOS-*
yum clean all && yum makecache
fi
yum -y install epel-release && yum -y install net-tools
rpm -ivh https://pkg.cloudflareclient.com/cloudflare-release-el8.rpm
yum -y install cloudflare-warp
fi
if [[ $release = Debian ]]; then
[[ ! $(type -P gpg) ]] && apt update && apt install gnupg -y
[[ ! $(apt list 2>/dev/null | grep apt-transport-https | grep installed) ]] && apt update && apt install apt-transport-https -y
fi
if [[ $release != Centos ]]; then 
apt install net-tools -y
curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] http://pkg.cloudflareclient.com/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/cloudflare-client.list
apt update;apt install cloudflare-warp -y
fi
warp-cli --accept-tos register >/dev/null 2>&1 && sleep 2
warp-cli --accept-tos set-mode proxy >/dev/null 2>&1
warp-cli --accept-tos enable-always-on >/dev/null 2>&1
sleep 2 && ShowSOCKS5
[[ -e /root/check.sh ]] && screen -S aw -X quit ; screen -UdmS aw bash -c '/bin/bash /root/check.sh'
[[ -e /root/WARP-CR.sh ]] && screen -S cr -X quit ; screen -UdmS cr bash -c '/bin/bash /root/WARP-CR.sh'
[[ -e /root/WARP-CP.sh ]] && screen -S cp -X quit ; screen -UdmS cp bash -c '/bin/bash /root/WARP-CP.sh'
S5menu && lncf && menu
}

WARPup(){
ab="1.升级Wgcf-WARP+账户\n2.升级Socks5-WARP+账户\n3.更换Socks5端口\n0.返回上一层\n 请选择："
readp "$ab" cd
case "$cd" in 
1 )
[[ ! $(type -P wg-quick) ]] && red "未安装Wgcf-WARP，无法升级到Wgcf-WARP+账户" && bash CFwarp.sh
ShowWGCF
[[ $wgcfv4 = plus || $wgcfv6 = plus ]] && red "当前已是Wgcf-WARP+账户，无须再升级" && bash CFwarp.sh 
cd /etc/wireguard
readp "按键许可证秘钥(26个字符):" ID
[[ -n $ID ]] && sed -i "s/license_key.*/license_key = \"$ID\"/g" wgcf-account.toml && readp "设备名称重命名(直接回车随机命名)：" sbmc || (red "未输入按键许可证秘钥(26个字符)" && bash CFwarp.sh)
[[ -n $sbmc ]] && SBID="--name $(echo $sbmc | sed s/[[:space:]]/_/g)"
wgcf update $SBID > /etc/wireguard/wgcf+p.log 2>&1
wgcf generate
sed -i "2s#.*#$(sed -ne 2p wgcf-profile.conf)#;4s#.*#$(sed -ne 4p wgcf-profile.conf)#" wgcf.conf
checkwgcf
[[ $wgcfv4 = plus || $wgcfv6 = plus ]] && green "已升级为Wgcf-WARP+账户\nWgcf-WARP+账户设备名称：$(grep -s 'Device name' /etc/wireguard/wgcf+p.log | awk '{ print $NF }')\nWgcf-WARP+账户剩余流量：$(grep -s Quota /etc/wireguard/wgcf+p.log | awk '{ print $(NF-1), $NF }')"
ShowWGCF && WGCFmenu && back;;
2 )
[[ ! $(type -P warp-cli) ]] && red "未安装Socks5-WARP，无法升级到Socks5-WARP+账户" && bash CFwarp.sh
[[ $(warp-cli --accept-tos account) =~ 'Limited' ]] && red "当前已是Socks5-WARP+账户，无须再升级" && bash CFwarp.sh
mkdir -p /etc/wireguard/ >/dev/null 2>&1
readp "按键许可证秘钥(26个字符):" ID
[[ -n $ID ]] && warp-cli --accept-tos set-license $ID >/dev/null 2>&1 || (red "未输入按键许可证秘钥(26个字符)" && bash CFwarp.sh)
yellow "如提示Error: Too many devices.说明超过了最多绑定4台设备限制"
[[ $(warp-cli --accept-tos account) =~ 'Limited' ]] && green "已升级为Socks5-WARP+账户\nSocks5-WARP+账户剩余流量：$((`warp-cli --accept-tos account | grep Quota | awk '{ print $(NF) }'`/1000000000))GB" && echo $ID >/etc/wireguard/ID
ShowSOCKS5 && S5menu && back;;
3 )
[[ ! $(type -P warp-cli) ]] && red "未安装Socks5-WARP(+)，无法更改端口" && bash CFwarp.sh
if readp "请输入自定义socks5端口(1024～65535):" port ; then
if [[ -n $(netstat -ntlp | grep "$port") ]]; then
until [[ -z $(netstat -ntlp | grep "$port") ]]
do
[[ -n $(netstat -ntlp | grep "$port") ]] && yellow "\n端口被占用，请重新输入端口" && readp "自定义Socks5端口:" port
done
fi
fi
[[ -n $port ]] && warp-cli --accept-tos set-proxy-port $port >/dev/null 2>&1
ShowSOCKS5 && S5menu && back;;
0 ) WARPupre
esac
}

WARPupre(){
ab="1.Wgcf-WARP(+)账户升级到Teams账户\n2.Wgcf-WARP升级到WARP+账户、Wgcf-Socks5升级到WARP+账户、更换Socks5端口\n3.在线前台刷WARP+普通账户流量\n4.离线后台刷WARP+普通账户流量\n5.screen管理设置\n0.返回上一层\n 请选择："
readp "$ab" cd
case "$cd" in 
1 )
[[ ! -e /etc/wireguard/wgcf.conf ]] && red "无法找到Wgcf-WARP(+)配置文件，建议重装Wgcf-WARP(+)" && bash CFwarp.sh
readp "请复制privateKey(44个字符）：" Key
readp "请复制IPV6的Address：" Add
if [[ -n $Key && -n $Add ]]; then
sed -i "s#PrivateKey.*#PrivateKey = $Key#g;s#Address.*128#Address = $Add/128#g" /etc/wireguard/wgcf.conf
systemctl restart wg-quick@wgcf >/dev/null 2>&1
checkwgcf
if [[ $wgcfv4 = plus || $wgcfv6 = plus ]]; then
rm -rf /etc/wireguard/wgcf+p.log && green "Wgcf-WARP+Teams账户已生效" && ShowWGCF && WGCFmenu && back
else
red "开启Wgcf-WARP+Teams账户失败，恢复使用WARP普通账户" && cp -f /etc/wireguard/wgcf-profile.conf /etc/wireguard/wgcf.conf >/dev/null 2>&1 && systemctl restart wg-quick@wgcf && ShowWGCF && WGCFmenu && back
fi
else 
red "未复制privateKey或Address，恢复使用WARP普通账户" && cp -f /etc/wireguard/wgcf-profile.conf /etc/wireguard/wgcf.conf >/dev/null 2>&1 && systemctl restart wg-quick@wgcf && ShowWGCF && WGCFmenu && back
fi;;
2 ) WARPup;;
3 ) wget -N --no-check-certificate https://cdn.jsdelivr.net/gh/ALIILAPRO/warp-plus-cloudflare/wp-plus.py && python3 wp-plus.py;;
4 )
wget -N --no-check-certificate https://cdn.jsdelivr.net/gh/ALIILAPRO/warp-plus-cloudflare/wp-plus.py
sed -i "27 s/[(][^)]*[)]//g" wp-plus.py
readp "客户端配置ID(36个字符)：" ID
sed -i "27 s/input/'$ID'/" wp-plus.py
readp "设置screen窗口名称，回车默认名称为'wp'：" wpp
[[ -z $wpp ]] && wpp='wp'
screen -UdmS $wpp bash -c '/usr/bin/python3 /root/wp-plus.py' && back;;
5 ) wget -N https://gitlab.com/rwkgyg/screen-script/raw/main/screen.sh && bash screen.sh && back;;
0 ) bash CFwarp.sh
esac
}

ReIP(){
ab="1.手动刷新Wgcf-WARP(+)奈飞IP\n2.手动刷新Socks5-WARP(+)奈飞IP\n0.返回上一层\n 请选择："
readp "$ab" cd
case "$cd" in 
1 )
[[ ! $(type -P wg-quick) ]] && red "未安装Wgcf-WARP(+)，无法刷新IP" && bash CFwarp.sh
ShowWGCF
ab="1.刷新IPV4的奈飞IP\n2.刷新IPV6的奈飞IP\n0.返回上一层\n 请选择："
readp "$ab" cd
case "$cd" in 
1 )
[[ $wgcfv4 = plus || $wgcfv4 = on ]] || (yellow "未开启Wgcf-WARP(+)-IPV4" && bash CFwarp.sh)
i=0
yellow "共刷新10次IP"
while [ $i -le 9 ]; do let i++
ShowWGCF
[[ "$result4" == "200" ]] && yellow "第$i次刷新IP \c" && green "恭喜，此IP：$v4 支持奈飞" && break || (yellow "第$i次刷新IP \c" && CheckWARP && red "当前IP：$v4 $NF" && sleep 3)
done
ShowWGCF && WGCFmenu && back;;
2 )
[[ $wgcfv6 = plus || $wgcfv6 = on ]] || (yellow "未开启Wgcf-WARP(+)-IPV6" && bash CFwarp.sh)
i=0
yellow "共刷新10次IP"
while [ $i -le 9 ]; do let i++
ShowWGCF
[[ "$result6" == "200" ]] && yellow "第$i次刷新IP \c" && green "恭喜，此IP：$v6 支持奈飞" && break || (yellow "第$i次刷新IP \c" && CheckWARP && red "当前IP：$v6 $NF" && sleep 3)
done
ShowWGCF && WGCFmenu && back;;
0 ) ReIP
esac;;
2 )
[[ ! $(type -P warp-cli) ]] && red "未安装Socks5-WARP(+)，无法刷新IP" && bash CFwarp.sh
s5c(){
warp-cli --accept-tos register >/dev/null 2>&1 && sleep 2
[[ -e /etc/wireguard/ID ]] && warp-cli --accept-tos set-license $(cat /etc/wireguard/ID) >/dev/null 2>&1
}
i=0
yellow "共刷新10次IP"
while [ $i -le 9 ]; do let i++
ShowSOCKS5
[[ "$result" == "200" ]] && yellow "第$i次刷新IP \c" && green "恭喜，此IP：$s5ip 支持奈飞" && break || (yellow "第$i次刷新IP \c" && s5c && red "当前IP：$s5i $NF" && sleep 3)
done
ShowSOCKS5 && S5menu && back;;
0 ) REnfwarp
esac
}

Rewarp(){
ab="1.启用：离线后台+重启VPS后screen后台自动刷NF功能\n2.启用：离线后台+重启VPS后screen后台自动刷区域IP功能\n3.启用：离线后台+重启VPS后screen后台自动刷Wgcf-IPV4的IP段功能\n4.关闭：重启VPS自动刷奈飞IP或区域IP功能\n（离线Screen窗口请在Screen管理设置中删除）\n0.返回上一层\n 请选择："
readp "$ab" cd
case "$cd" in  
1 )
[[ -e /root/WARP-CR.sh || -e /root/WARP-CP.sh ]] && yellow "经检测，你正在使用其他刷IP功能，请关闭它后再执行" && REnfwarp
screen -d >/dev/null 2>&1
wget -N --no-check-certificate https://gitlab.com/rwkgyg/cfwarp/raw/main/check.sh
readp "输入国家区域简称（例：新加坡，输入大写SG;美国，输入大写US）:" gj
[[ -n $gj ]] && sed -i "s/dd/$gj/g" check.sh || (sed -i "s/dd/\$region/g" check.sh && green "当前设置WARP默认随机分配的国家区域: $g4 ")
readp "已是奈飞IP或者指定IP区域时，重新检测间隔时间（回车默认45秒）,请输入间隔时间（例：50秒，输入50）:" stop
[[ -n $stop ]] && sed -i "s/45s/${stop}s/g;s/45秒/${stop}秒/g" check.sh || green "默认间隔45秒"
readp "非奈飞IP或者非指定IP区域时，继续检测间隔时间（回车默认30秒）,请输入间隔时间（例：50秒，输入50）:" goon
[[ -n $goon ]] && sed -i "s/30s/${goon}s/g;s/30秒/${goon}秒/g" check.sh || green "默认间隔30秒"
[[ -e /root/check.sh ]] && screen -S aw -X quit ; screen -UdmS aw bash -c '/bin/bash /root/check.sh'
green "设置screen窗口名称'aw'，离线后台自动刷奈飞IP" && sleep 2
grep -qE "^ *@reboot root screen -UdmS aw bash -c '/bin/bash /root/check.sh' >/dev/null 2>&1" /etc/crontab || echo "@reboot root screen -UdmS aw bash -c '/bin/bash /root/check.sh' >/dev/null 2>&1" >> /etc/crontab
green "添加VPS重启后screen后台自动刷奈飞IP功能，重启VPS后自动生效"
back;;
2 )
[[ -e /root/WARP-CP.sh || -e /root/check.sh ]] && yellow "经检测，你正在使用其他刷IP功能，请关闭它后再执行" && REnfwarp
screen -d >/dev/null 2>&1
wget -N --no-check-certificate https://gitlab.com/rwkgyg/cfwarp/raw/main/WARP-CR.sh
readp "输入国家区域简称（例：新加坡，输入大写SG;美国，输入大写US）:" gj
[[ -n $gj ]] && sed -i "s/dd4/$gj/g" WARP-CR.sh || (sed -i "s/dd4/\$eg4/g" WARP-CR.sh && green "IPV4当前设置WARP默认分配的国家区域: $g4 ")
[[ -n $gj ]] && sed -i "s/dd6/$gj/g" WARP-CR.sh || (sed -i "s/dd6/\$eg6/g" WARP-CR.sh && green "IPV6当前设置WARP默认分配的国家区域: $g6 ")
[[ -n $gj ]] && sed -i "s/ddj/$gj/g" WARP-CR.sh || (sed -i "s/ddj/\$egj/g" WARP-CR.sh && green "Socks5当前设置WARP默认分配的国家区域: $s5gj ")
readp "已是指定IP区域时，重新检测间隔时间（回车默认60秒）,请输入间隔时间（例：50秒，输入50）:" stop
[[ -n $stop ]] && sed -i "s/60s/${stop}s/g;s/60秒/${stop}秒/g" WARP-CR.sh || green "默认间隔60秒"
readp "非指定IP区域时，重新检测间隔时间（回车默认30秒）,请输入间隔时间（例：50秒，输入50）:" goon
[[ -n $goon ]] && sed -i "s/30s/${goon}s/g;s/30秒/${goon}秒/g" WARP-CR.sh || green "默认间隔30秒"
[[ -e /root/WARP-CR.sh ]] && screen -S cr -X quit ; screen -UdmS cr bash -c '/bin/bash /root/WARP-CR.sh'
green "设置screen窗口名称'cr'，离线后台自动刷WARP指定区域IP" && sleep 2
grep -qE "^ *@reboot root screen -UdmS cr bash -c '/bin/bash /root/WARP-CR.sh' >/dev/null 2>&1" /etc/crontab || echo "@reboot root screen -UdmS cr bash -c '/bin/bash /root/WARP-CR.sh' >/dev/null 2>&1" >> /etc/crontab
green "添加VPS重启后screen后台自动刷IP功能，重启VPS后自动生效"
back;;
3 )
[[ -e /root/WARP-CR.sh || -e /root/check.sh ]] && yellow "经检测，你正在使用其他刷IP功能，请关闭它后再执行" && REnfwarp
wgcfv4=$(curl -s4m6 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2) 
[[ ! $wgcfv4 =~ on|plus ]] && yellow "当前Wgcf-IPV4未开启" && bash CFwarp.sh
screen -d >/dev/null 2>&1
wget -N --no-check-certificate https://gitlab.com/rwkgyg/cfwarp/raw/main/WARP-CP.sh
readp "输入WARP-IPV4的第二段.第三段的IP段（例：8.45.46.123 ， 输入 45.46 ）:" gj
[[ -n $gj ]] && sed -i "s/ipd/$gj/g" WARP-CP.sh || (sed -i "s/ipd/\$v4d/g" WARP-CP.sh && green "未输入，使用当前WARP默认IP段$(curl -s4m3 https://ip.gs -k | awk -F '.' '{print $2"."$3}')")
readp "已刷到设置的IP段时，重新检测间隔时间（回车默认60秒）,请输入间隔时间（例：50秒，输入50）:" stop
[[ -n $stop ]] && sed -i "s/60s/${stop}s/g;s/60秒/${stop}秒/g" WARP-CP.sh || green "默认间隔60秒"
readp "未刷到设置的IP段时，继续检测间隔时间（回车默认20秒）,请输入间隔时间（例：50秒，输入50）:" goon
[[ -n $goon ]] && sed -i "s/20s/${goon}s/g;s/20秒/${goon}秒/g" WARP-CP.sh || green "默认间隔20秒"
[[ -e /root/WARP-CP.sh ]] && screen -S cp -X quit ; screen -UdmS cp bash -c '/bin/bash /root/WARP-CP.sh'
green "设置screen窗口名称'cp'，离线后台自动WARP的IP段" && sleep 2
grep -qE "^ *@reboot root screen -UdmS cp bash -c '/bin/bash /root/WARP-CP.sh' >/dev/null 2>&1" /etc/crontab || echo "@reboot root screen -UdmS cp bash -c '/bin/bash /root/WARP-CP.sh' >/dev/null 2>&1" >> /etc/crontab
green "添加VPS重启后screen后台自动刷WARP的IP段功能，重启VPS后自动生效"
back;;
4 )
sed -i '/check.sh/d' /etc/crontab ; sed -i '/WARP-CR.sh/d' /etc/crontab ; sed -i '/WARP-CP.sh/d' /etc/crontab
rm -rf check.sh WARP-CR.sh WARP-CP.sh
green "卸载完成";;
0 ) REnfwarp
esac
}

REnfwarp(){
ab="1.在线前台临时刷奈飞NF\n2.离线后台+重启VPS后screen后台自动刷奈飞NF、WARP区域、Wgcf-IPV4的IP段三大功能\n3.screen管理设置\n0.返回上一层\n 请选择："
readp "$ab" cd
case "$cd" in
1 ) ReIP;;
2 ) Rewarp;;
3 ) wget -N https://gitlab.com/rwkgyg/screen-script/raw/main/screen.sh && bash screen.sh && back;;
0 ) bash CFwarp.sh
esac
}

WARPonoff(){
ab="1.开启或者完全关闭Wgcf-WARP(+)\n2.开启或完全关闭Socks5-WARP(+)\n0.返回上一层\n 请选择："
readp "$ab" cd
case "$cd" in  
1 )
[[ ! $(type -P wg-quick) ]] && red "Wgcf-WARP(+)未安装，无法启动或关闭，建议重新安装Wgcf-WARP(+)" && bash CFwarp.sh
checkwgcf
if [[ $wgcfv4 =~ on|plus || $wgcfv6 =~ on|plus ]]; then
yellow "当前Wgcf-WARP(+)状态：已运行中，现执行:完全关闭……"
rm -rf WARP-UP.sh
sed -i '/WARP-UP.sh/d' /etc/crontab >/dev/null 2>&1
wg-quick down wgcf >/dev/null 2>&1
systemctl disable wg-quick@wgcf >/dev/null 2>&1
checkwgcf
[[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]] && green "关闭Wgcf-WARP(+)成功" || red "关闭Wgcf-WARP(+)失败"
elif [[ ! $wgcfv4 =~ on|plus && ! $wgcfv6 =~ on|plus ]]; then
yellow "当前Wgcf-WARP(+)为完全关闭状态，现执行:恢复运行……"
systemctl enable wg-quick@wgcf >/dev/null 2>&1
CheckWARP
fi
ShowWGCF && WGCFmenu && back;;
2 )
[[ ! $(type -P warp-cli) ]] && red "Socks5-WARP(+)未安装，无法启动或关闭，建议重新安装Socks5-WARP(+)" && bash CFwarp.sh
if [[ $(warp-cli --accept-tos status) =~ 'Connected' ]]; then
yellow "当前Socks5-WARP(+)状态：已运行中，现执行：完全关闭……" && sleep 1
warp-cli --accept-tos disable-always-on >/dev/null 2>&1
[[ -e /root/check.sh ]] && screen -S aw -X quit ; screen -UdmS aw bash -c '/bin/bash /root/check.sh'
[[ -e /root/WARP-CR.sh ]] && screen -S cr -X quit ; screen -UdmS cr bash -c '/bin/bash /root/WARP-CR.sh'
[[ -e /root/WARP-CP.sh ]] && screen -S cp -X quit ; screen -UdmS cp bash -c '/bin/bash /root/WARP-CP.sh'
[[ $(warp-cli --accept-tos status) =~ 'Disconnected' ]] && green "临时关闭WARP(+)成功" || red "临时关闭WARP(+)失败"
elif [[ $(warp-cli --accept-tos status) =~ 'Disconnected' ]]; then
yellow "当前Socks5-WARP(+)为完全关闭状态，现执行：恢复运行……" && sleep 1
warp-cli --accept-tos enable-always-on >/dev/null 2>&1
[[ -e /root/check.sh ]] && screen -S aw -X quit ; screen -UdmS aw bash -c '/bin/bash /root/check.sh'
[[ -e /root/WARP-CR.sh ]] && screen -S cr -X quit ; screen -UdmS cr bash -c '/bin/bash /root/WARP-CR.sh'
[[ -e /root/WARP-CP.sh ]] && screen -S cp -X quit ; screen -UdmS cp bash -c '/bin/bash /root/WARP-CP.sh'
fi
ShowSOCKS5 && S5menu && back;;
0 ) WARPOC
esac
}

cwg(){
wg-quick down wgcf >/dev/null 2>&1
systemctl disable wg-quick@wgcf >/dev/null 2>&1
$yumapt autoremove wireguard-tools
screen -S up -X quit ; rm -rf WARP-UP.sh ; sed -i '/WARP-UP.sh/d' /etc/crontab
dig9
}
cso(){
warp-cli --accept-tos disconnect >/dev/null 2>&1
warp-cli --accept-tos disable-always-on >/dev/null 2>&1
warp-cli --accept-tos delete >/dev/null 2>&1
[[ $release = Centos ]] && (yum autoremove cloudflare-warp -y) || (apt purge cloudflare-warp -y && rm -f /etc/apt/sources.list.d/cloudflare-client.list /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg)
}

WARPun(){
wj="rm -rf /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /etc/wireguard/wgcf-profile.conf /etc/wireguard/wgcf-account.toml /etc/wireguard/wgcf+p.log /etc/wireguard/ID /usr/bin/wireguard-go wgcf-account.toml wgcf-profile.conf"
cron1="rm -rf CFwarp.sh screen.sh check.sh WARP-CR.sh WARP-CP.sh WARP-UP.sh /usr/bin/cf"
cron2(){
sed -i '/check.sh/d' /etc/crontab ; sed -i '/WARP-CR.sh/d' /etc/crontab ; sed -i '/WARP-CP.sh/d' /etc/crontab ; sed -i '/WARP-UP.sh/d' /etc/crontab
}
cron3(){
screen -S up -X quit;screen -S aw -X quit;screen -S cr -X quit;screen -S cp -X quit
}
ab="1.卸载Wgcf-WARP(+)\n2.卸载Socks5-WARP(+)\n3.彻底卸载并清除WARP脚本及相关进程文件\n0.返回上一层\n 请选择："
readp "$ab" cd
case "$cd" in     
1 ) [[ $(type -P wg-quick) ]] && (cwg ; $wj ; green "Wgcf-WARP(+)卸载完成" && ShowWGCF && WGCFmenu && back) || (yellow "并未安装Wgcf-WARP(+)，无法卸载" && bash CFwarp.sh);;
2 ) [[ $(type -P warp-cli) ]] && (cso ; green "Socks5-WARP(+)卸载完成" && ShowSOCKS5 && S5menu && back) || (yellow "并未安装Socks5-WARP(+)，无法卸载" && bash CFwarp.sh);;
3 ) [[ ! $(type -P wg-quick) && ! $(type -P warp-cli) ]] && (red "并没有安装任何的WARP功能，无法卸载" && CFwarp.sh) || (cwg ; cso ; $wj ; $cron1 ; cron2 ; cron3 ; green "WARP已全部卸载完成" && ShowSOCKS5 && ShowWGCF && WGCFmenu && S5menu && exit);;
0 ) WARPOC
esac
}

WARPOC(){
ab="1.完全关闭与启用WARP(+)功能\n2.卸载WARP(+)功能\n0.返回上一层\n 请选择："
readp "$ab" cd
case "$cd" in
1 ) WARPonoff;;
2 ) WARPun;;
0 ) bash CFwarp.sh
esac
}

start_menu(){
ShowWGCF;ShowSOCKS5
clear
green "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"           
echo -e "${bblue} ░██     ░██      ░██ ██ ██         ░█${plain}█   ░██     ░██   ░██     ░█${red}█   ░██${plain}  "
echo -e "${bblue}  ░██   ░██      ░██    ░░██${plain}        ░██  ░██      ░██  ░██${red}      ░██  ░██${plain}   "
echo -e "${bblue}   ░██ ░██      ░██ ${plain}                ░██ ██        ░██ █${red}█        ░██ ██  ${plain}   "
echo -e "${bblue}     ░██        ░${plain}██    ░██ ██       ░██ ██        ░█${red}█ ██        ░██ ██  ${plain}  "
echo -e "${bblue}     ░██ ${plain}        ░██    ░░██        ░██ ░██       ░${red}██ ░██       ░██ ░██ ${plain}  "
echo -e "${bblue}     ░█${plain}█          ░██ ██ ██         ░██  ░░${red}██     ░██  ░░██     ░██  ░░██ ${plain}  "
green "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" 
white "甬哥Gitlab项目  ：gitlab.com/rwkgyg"
white "甬哥blogger博客 ：ygkkk.blogspot.com"
white "甬哥YouTube频道 ：www.youtube.com/c/甬哥侃侃侃kkkyg"
yellow "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
bblue " WARP-WGCF/SOCKS5安装脚本：2022.3.24更新 Beta 8 版本"  
echo
echo
red " 为方便小白朋友，本脚本将在2022.9月第一周重置更新，功能方面会由 大众化 到 折腾化 慢慢过渡，每次大更新将同步更新油管教程，各位做好心理准备"
echo
echo
white " ========================================================================================"
green "  1. 安装Wgcf-WARP:虚拟IPV4"      
green "  2. 安装Wgcf-WARP:虚拟IPV6"      
green "  3. 安装Wgcf-WARP:虚拟IPV4+IPV6" 
[[ $cpu != AMD64 ]] && red "  4. 提示：当前VPS的CPU并非AMD64架构，目前不支持安装Socks5-WARP(+)" || green "  4. 安装Socks5-WARP：IPV4本地Socks5代理"
white " -------------------------------------------------------------------------------------------"    
green "  5. WARP账户升级：WARP+账户与WARP+Teams账户"
green "  6. WARPR解锁NF奈飞：自动识别WARP配置环境" 
green "  7. WARP开启、停止、卸载"
green "  0. 退出脚本 "
red "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
white " VPS系统信息如下："
white " VPS操作系统: $(blue "$op") \c" && white " 内核版本: $(blue "$version") \c" && white " CPU架构 : $(blue "$cpu") \c" && white " 虚拟化类型: $(blue "$vi") \c" && white " TCP算法: $(blue "$bbr")"
IP_Status_menu
echo
readp "请输入数字:" Input
case "$Input" in     
 1 ) WGCFv4;;
 2 ) WGCFv6;;
 3 ) WGCFv4v6;;
 4 ) [[ $cpu = AMD64 ]] && SOCKS5ins || bash CFwarp.sh;; 
 5 ) WARPupre;;
 6 ) REnfwarp;;	
 7 ) WARPOC;;
 * ) exit 
esac
}
if [ $# == 0 ]; then
start
start_menu
fi
screenup(){
screen -Ur up
}
screenaw(){
screen -Ur aw
}
screencr(){
screen -Ur cr
}
screencp(){
screen -Ur cp
}
wgcfup(){
wg-quick up wgcf
ShowWGCF && WGCFmenu
}
wgcfdn(){
wg-quick down wgcf
ShowWGCF && WGCFmenu
}
wgcfre(){
systemctl restart wg-quick@wgcf
ShowWGCF && WGCFmenu
}
s5up(){
warp-cli --accept-tos enable-always-on >/dev/null 2>&1
ShowSOCKS5 && S5menu
}
s5dn(){
warp-cli --accept-tos disable-always-on >/dev/null 2>&1
ShowSOCKS5 && S5menu
}

if [[ $# > 0 ]]; then
case $1 in
wd ) wgcfdn 0;;
wu ) wgcfup 0;;
wr ) wgcfre 0;;
5d ) s5dn 0;;
5u ) s5up 0;;
sup ) screenup 0;;
saw ) screenaw 0;;
scr ) screencr 0;;
scp ) screencp 0;;
h ) menu;;
esac
fi
