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
    echo -e "\033[31m Installation is currently started for the root user";
else
    echo  -e "\033[31m Please log in as root and re-execute this script"
    exit 0
fi
echo -e "\033[31mThis script can only be used in the Xfce desktop environment and supports Paroots and Kali systems. Before starting the installation, please visit: https://www.nvidia.com/cn/download/index.aspx?lang=zh-cn to download the relevant Nvidia driver (notebook (notebook driver)) to the same script as Directory.\nPlease make sure the update sources in /etc/apt/sources.list are available!!!"
echo -e  "\033[31mHave you checked the instructions above? If you have already checked, press any key to start the installation and make sure you are connected to the Internet. Otherwise press Ctrl + C to exit the installation interface"
read  -s -n1 -p ""
if [[ `service lightdm status |grep -o Started` ]]; then
	echo -e "\033[31mYou have not closed the graphical interface! !! !! Please run service lightdm stop command in terminal, then press Ctrl + Alt + F2 to enter command line mode to log in and run the installation script. Make sure you are connected to the Internet during the installation process, otherwise the kernel headers will fail to install successfully"
    exit 0
elif [[ `service  lightdm status |grep -o Stopped` ]]; then
	echo "lightdm service is down and installation is starting....... "
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

echo -e "Check if nouveau is uninstalled. If no results are displayed, it is uninstalled.\n\n(`lsmod | grep -i nouveau`)"
modprobe nvidia-drm
PCI=`nvidia-xconfig --query-gpu-info | grep 'BusID : ' | cut -d ' ' -f6`
echo  -e "Query the computer's PCIID and write the configuration file\n"$PCI
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
read  -s -n1 -p "Now that it's installed, enter any character to restart and complete the update. If you find it useful, please give me a Star on my homepage:" 
reboot
exit 0
