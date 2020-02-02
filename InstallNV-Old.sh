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
apt update&&apt install linux-headers-$(uname -r)&&apt install nvidia-xconfig ocl-icd-libopencl1 nvidia-cuda-toolkit nvidia-kernel-dkms
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
Section "ServerLayout"
    Identifier "layout"
    Screen 0 "nvidia"
    Inactive "intel"
EndSection

Section "Device"
    Identifier "nvidia"
    Driver "nvidia"
    # You may need to change the PCI value
    BusID "PCI:10:0:0"
EndSection

Section "Screen"
    Identifier "nvidia"
    Device "nvidia"
    Option "AllowEmptyInitialConfiguration"
EndSection

Section "Device"
    Identifier "intel"
    Driver "modesetting"
EndSection

Section "Screen"
    Identifier "intel"
    Device "intel"
EndSection
EOF
sed -i 's/PCI:10:0:0/'$PCI'/g' /etc/X11/xorg.conf
cat>/usr/share/gdm/greeter/autostart/optimus.desktop<<EOF
[Desktop Entry]
Type=Application
Name=Optimus
Exec=sh -c "xrandr --setprovideroutputsource modesetting NVIDIA-0; xrandr --auto"
NoDisplay=true
X-GNOME-Autostart-Phase=DisplayServer
EOF
cat>/etc/xdg/autostart/optimus.desktop<<EOF
[Desktop Entry]
Type=Application
Name=Optimus
Exec=sh -c "xrandr --setprovideroutputsource modesetting NVIDIA-0; xrandr --auto"
NoDisplay=true
X-GNOME-Autostart-Phase=DisplayServer
EOF
update-initramfs -u -k $(uname -r)
read  -s -n1 -p "现在已经安装完成，输入任意字符即可重启完成更新，如果开机无法正常使用请在开机时按住Ctrl + Alt + F2进入命令行模式bash unistallNV.sh即可卸载。如果你觉得好用欢迎在我主页上给个star:" 
reboot
exit 0

