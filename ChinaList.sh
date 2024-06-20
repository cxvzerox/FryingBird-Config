#!/usr/bin/bash
# Writen by ATP on Jan 25, 2024
# Website: https://atpx.com

agh_path="/root/adguardhome" # AdGuard Home 项目路径
cnip_dns="https://223.5.5.5/dns-query https://120.53.53.53/dns-query" # 国内 DNS 服务器，多个用空格隔开
global_dns="https://vad.ocam.tk/dnsenv/e61ce6b1-557b-48a2-b087-65852e5b65d4" # 海外 DNS 服务器

# dnsmasq-china-list 规则文件，无法下载的话可以找 CDN 或自建反代
apple_domains="https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/apple.china.conf"
accelerated_domains="https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf"

# 下载文件并合并
wget -O "$agh_path/cn-apple.conf" $apple_domains
wget -O "$agh_path/cn-domains.conf" $accelerated_domains
cat "$agh_path/cn-apple.conf" >> "$agh_path/cn-domains.conf"

# 转换为 AdGuard Home 格式
awk -v cnip_dns="$cnip_dns" -F/ '/server=/{print "[/"$2"/]"cnip_dns}' "$agh_path/cn-domains.conf" > "$agh_path/china_dns.txt"

# 添加默认海外 DNS
sed -i "1i\\$global_dns" "$agh_path/china_dns.txt"

# 移动文件到 AdGuardHome 目录
mv "$agh_path/china_dns.txt" "$agh_path/work/data/"

# 清理临时文件
rm "$agh_path/cn-domains.conf"
rm "$agh_path/cn-apple.conf"

echo "规则转换完成"

# 重启 AdGuard Home
cd $agh_path
docker compose restart

# chmod +x /root/ChinaList.sh
# crontab -e
# 5 5 */7 * * /root/ChinaList.sh > /dev/null 2>&1
# 
#
# cd /root/AdguardCache/
# wget https://api.vvcc.me/git/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf -O ChinaList.conf -q
# sed -i -e 's/server=/[/g' -e 's/114.114.114.114/]https:\/\/doh.pub\/dns-query/g' ChinaList.conf
# echo "https://app.vvcc.me/dns-query"   >> ChinaList.conf
# echo "https://api.vvcc.me/g/dns-query" >> ChinaList.conf
# mv ChinaList.conf ChinaList.txt
# /root/adguardhome/AdGuardHome -s restart
# 
