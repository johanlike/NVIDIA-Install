#!/bin/bash
echo -ne "${lightgreen}Today is:\t\t${red}" `date`; echo ""
echo -e "${lightgreen}Kernel Information: \t${red}" `uname -smr`
LOGO=`cat>L<<EOF
                          ____           _      __   __
                         |  _ \         | |     \ \ / /
                         | | | |     _  | |      \ V / 
                         | |_| |    | |_| |       | |  
                         |____/      \___/        |_|  
                                                       

EOF`
cat L&&rm -rf L
if [ "$(id -u)" == "0" ]
then
    echo -e "\033[31m 当前为root用户开始安装";
else
    echo  -e "\033[31m 请使用root用户登录，并重新执行此脚本"
    exit 0
fi
echo -e "\033[31m此脚本只能用于Xfce桌面环境，支持Paroots，Kali系统,开始安装前请到：https://www.nvidia.com/Download/index.aspx?lang=en-us下载相关的Nvidia驱动（Notebooks是笔记本驱动）放到脚本的同一个目录.\n请确保你的/etc/apt/sources.list里面的更新源可用!!!"
echo -e  "\033[31m你已经检查过上面所说的说明了吗? 如果已经检查过了请按任意键开始安装，并确保你已经联网。否则按Ctrl+C退出安装界面"
read  -s -n1 -p ""
if [[ `service lightdm status |grep -o Started` ]]; then
	echo -e "\033[31m你并未关闭图形化界面！！！请在在终端运行service lightdm stop 命令并按住Ctrl + Alt + F2进入命令行模式登录并运行安装脚本。安装时请确保你已经联网，否则内核头文件将安装不成功"
    exit 0
elif [[ `service  lightdm status |grep -o Stopped` ]]; then
	echo "lightdm 服务已关闭，开始安装中....... "
fi

apt update&&apt install linux-headers-$(uname -r) xinit xserver-xorg -y
chmod 777 *.run
./NVIDIA-Linux-*.run
cat>/etc/modprobe.d/nvidia-blacklists-nouveau.conf<<EOF
blacklist nouveau
blacklist lbm-nouveau
options nouveau modeset=0
alias nouveau off
alias lbm-nouveau off
EOF
update-initramfs -u
sed -i 's/ro  quiet/ro quiet nouveau.modeset=0/g' /boot/grub/grub.cfg
echo `rmmod nouveau`

echo -e "确认是否已卸载nouveau如无结果显示表明已经卸载\n\n(`lsmod | grep -i nouveau`)"
modprobe nvidia-drm
PCI=`nvidia-xconfig --query-gpu-info | grep 'BusID : ' | cut -d ' ' -f6`
echo  -e "查询电脑PCIID 并写入配置文件\n"$PCI
cat>/etc/X11/xorg.conf<<EOF
Section "Module"
    Load "modesetting"
EndSection

Section "Device"
    Identifier "nvidia"
    Driver "nvidia"
    BusID "PCI:1:0:0"
    Option "AllowEmptyInitialConfiguration"
    Option         "Interactive"        "False"
    Option      "AccelMethod"  "sna"
    Option      "Tiling" "True"
    Option "TearFree" "true"
EndSection
EOF
sed -i 's/PCI:1:0:0/'$PCI'/g' /etc/X11/xorg.conf
cat>/usr/local/bin/DJY.sh<<EOF
#!/bin/sh

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
EOF
chmod 777 /usr/local/bin/DJY.sh
sed -i "/[Seat:*]/a\\display-setup-script=/usr/local/bin/DJY.sh"  /etc/lightdm/lightdm.conf
update-initramfs -u -k $(uname -r)
read  -s -n1 -p "现在已经安装完成，输入任意字符即可重启完成更新，如果你觉得好用欢迎在我主页上给个Star:" 
reboot
exit 0
