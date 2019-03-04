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
apt-get remove --purge nvidia * 
rm /etc/X11/xorg.conf 
rm /usr/share/gdm/greeter/autostart/optimus.desktop 
rm /etc/xdg/autostart/optimus.desktop 
read  -s -n1 -p "现在已经卸载安装完成，输入任意字符即可重启完成卸载，如果你觉得好用欢迎在我主页上给个star" 
reboot
