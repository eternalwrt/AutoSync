#!/bin/bash
function git_sparse_clone() {
branch="$1" rurl="$2" localdir="$3" && shift 3
git clone -b $branch --depth 1 --filter=blob:none --sparse $rurl $localdir
cd $localdir
git sparse-checkout init --cone
git sparse-checkout set $@
mv -n $@ ../
cd ..
rm -rf $localdir
}

function mvdir() {
mv -n `find $1/* -maxdepth 0 -type d` ./
rm -rf $1
}

git clone --depth 1 -b v5 https://github.com/sbwml/luci-app-mosdns openwrt-mosdns && mv -n openwrt-mosdns/{v2dat,mosdns,luci-app-mosdns} ./ && rm -rf openwrt-mosdns
git clone --depth 1 -b v5 https://github.com/sbwml/openwrt_helloworld openwrt-helloworld && mv -n openwrt-helloworld/{daed,pdnsd,vmlinux-btf,luci-app-daed} ./ && rm -rf openwrt-helloworld
git clone --depth 1 -b master https://github.com/vernesong/OpenClash openwrt-openclash && mv -n openwrt-openclash/luci-app-openclash ./; rm -rf openwrt-openclash
git clone --depth 1 -b main https://github.com/Openwrt-Passwall/openwrt-passwall passwall1 && mv -n passwall1/luci-app-passwall  ./; rm -rf passwall1
git clone --depth 1 -b main https://github.com/Openwrt-Passwall/openwrt-passwall2 passwall2 && mv -n passwall2/luci-app-passwall2 ./;rm -rf passwall2
git clone --depth 1 -b main https://github.com/Openwrt-Passwall/openwrt-passwall-packages passwall-packages && mv -n passwall-packages/{chinadns-ng,dns2socks,geoview,hysteria,ipt2socks,microsocks,naiveproxy,shadow-tls,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,sing-box,tcping,trojan-plus,tuic-client,v2ray-geodata,v2ray-plugin,xray-core,xray-plugin} ./;rm -rf passwall-packages
git clone --depth 1 -b dev https://github.com/fw876/helloworld openwrt-helloworld && mv -n openwrt-helloworld/{dns2socks-rust,dns2tcp,dnsproxy,gn,lua-neturl,mihomo,redsocks2,v2ray-core,v2raya,luci-app-ssr-plus} ./ ; rm -rf openwrt-helloworld
git clone --depth 1 -b master https://github.com/immortalwrt/homeproxy luci-app-homeproxy

sed -i \
-e 's?include \.\./\.\./\(lang\|devel\)?include $(TOPDIR)/feeds/packages/\1?' \
-e 's?\.\./\.\./luci.mk?$(TOPDIR)/feeds/luci/luci.mk?' \
*/Makefile
sed -i 's/+libcap /+libcap +libcap-bin /' luci-app-openclash/Makefile

# ── 提前保存各包的上游最新 commit 信息（在删除 .git 之前）──
echo "保存上游 commit 信息..."
: > /tmp/upstream_commit_msgs.txt
for dir in */; do
    pkg="${dir%/}"
    [ -d "$pkg/.git" ] || continue
    msg=$(git -C "$pkg" log -1 --pretty=format:'%s' 2>/dev/null)
    [ -n "$msg" ] && printf '%s|%s\n' "$pkg" "$msg" >> /tmp/upstream_commit_msgs.txt
done
echo "已保存 $(wc -l < /tmp/upstream_commit_msgs.txt) 个包的 commit 信息"

rm -rf ./*/.git ./*/.gitattributes ./*/.svn ./*/.github ./*/.gitignore
exit 0
