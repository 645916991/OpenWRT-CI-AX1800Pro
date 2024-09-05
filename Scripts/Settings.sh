#!/bin/bash

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改默认WIFI名
sed -i "s/\.ssid=.*/\.ssid=$WRT_WIFI/g" $(find ./package/kernel/mac80211/ ./package/network/config/ -type f -name "mac80211.*")

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" $CFG_FILE
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" $CFG_FILE

if [[ $WRT_REPO == *"lede"* ]]; then
	LEDE_FILE=$(find ./package/lean/autocore/ -type f -name "index.htm")
	#修改默认时间格式
	sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S %A")/g' $LEDE_FILE
	#添加编译日期标识
	sed -i "s/(\(<%=pcdata(ver.luciversion)%>\))/\1 \/ $WRT_CI-$WRT_DATE/g" $LEDE_FILE
else
	#修改immortalwrt.lan关联IP
	sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
	#添加编译日期标识
	sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_CI-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")
fi

#配置文件修改
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo "$WRT_PACKAGE" >> ./.config
fi

#高通平台锁定512M内存 不添加的话默认就是1024M 不管但是实机编译不出来
if [[ $WRT_TARGET == *"IPQ"* ]]; then
	echo "CONFIG_IPQ_MEM_PROFILE_1024=n" >> ./.config
	echo "CONFIG_IPQ_MEM_PROFILE_512=y" >> ./.config
	echo "CONFIG_ATH11K_MEM_PROFILE_1G=n" >> ./.config
	echo "CONFIG_ATH11K_MEM_PROFILE_512M=y" >> ./.config
fi

#科学插件设置
if [[ $WRT_REPO == *"lede"* ]]; then
	echo "CONFIG_PACKAGE_luci-app-openclash=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-ssr-plus=y" >> ./.config
	# echo "CONFIG_PACKAGE_luci-app-turboacc=y" >> ./.config
else
	echo "CONFIG_PACKAGE_luci=y" >> ./.config
	echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-homeproxy=y" >> ./.config
fi

# 添加些自己需要的插件 无效 所以删除
# echo "CONFIG_PACKAGE_luci-app-turboacc=y" >> ./.config

# 添加luci-app-dockerman、docker-compose
echo "CONFIG_PACKAGE_luci-app-dockerman=y" >> ./.config
echo "CONFIG_PACKAGE_docker-compose=y" >> ./.config

# 添加openssh-sftp-server使得finalshell得以看见文件列表
echo "CONFIG_PACKAGE_openssh-sftp-server=y" >> ./.config

# 添加kiddin6源的部分软件包
# 图像化界面quickstart
# echo "CONFIG_PACKAGE_quickstart=y" >> ./.config
# echo "CONFIG_PACKAGE_luci-app-quickstart=y" >> ./.config

# 图形化流量监控
echo "CONFIG_PACKAGE_luci-app-wrtbwmon=y" >> ./.config

# 大鹅luci-app-daed
# echo "CONFIG_PACKAGE_luci-app-daed=y" >> ./.config
