#!/bin/bash
#set -x
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

. functions.sh

Check_root
Check_Platform

Press_Start

cat << EOF
    [1]Set yum-repos to aliyun
    [2]Set yum-repos to tsinghua
    [3]Install epel-repos from aliyun
    [4]Install basic utils, network utils and update system
    [5]Set timezone and NTP
    [6]Enable iptables and Disable firewalld
    [7]Set vi=vim
    [8]Set sysctl.conf
    [9]Disable ipv6
    [a]Do all things(default)
    [0]Exit

$(Echo_Yellow "Note: Don't run this script twice!")

EOF

read -p "Choose what you want to do: " index

case "$index" in
    1)  d_yum
        Echo_Green "Your repolist: "; yum repolist
        ;;
    2)  t_yum
        Echo_Green "Your repolist: "; yum repolist
        ;;
    3)  d_epel
        ;;
    4)  d_init
        ;;
    5)  d_ntp
        Echo_Green "Now the time is: "; date +%H:%M:%S
        ;;
    6)  d_iptables
        Echo_Green "The iptables rules: "; iptables -nvL
        ;;
    7)  d_vi
        ;;
    8)  d_sysctl
        ;;
    9)  d_disable_ipv6
        ;;
    0)  exit 0
        ;;
    *)  d_epel
        t_yum
        d_init
        d_ntp
        d_iptables
        d_vi
        d_sysctl
        d_disable_ipv6
        Echo_Green "Your repolist: "; yum repolist
        Echo_Green "Now the time is: "; date +%H:%M:%S
        Echo_Green "The iptables rules: "; iptables -nvL
        Echo_Green "Please reboot system!"
        ;;
esac

exit 0