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
    [4]install mysql-repos from official
    [5]Install basic utils, network utils and update system
    [6]Set timezone and NTP
    [7]Enable iptables and Disable firewalld
    [8]Set vi=vim
    [9]Set sysctl.conf
    [10]Disable ipv6
    [11]Disable selinux
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
    4)  d_mysql_repo
	;;
    5)  d_init
        ;;
    6)  d_ntp
        Echo_Green "Now the time is: "; date +%H:%M:%S
        ;;
    7)  d_iptables
        Echo_Green "The iptables rules: "; iptables -nvL
        ;;
    8)  d_vi
        ;;
    9)  d_sysctl
        ;;
    10) d_disable_ipv6
        ;;
    11) d_disable_selinux
        ;;
    0)  exit 0
        ;;
    *)  d_yum
        d_epel
	d_mysql_repo
        d_init
        d_ntp
        d_iptables
        d_vi
        d_sysctl
        d_disable_ipv6
	d_disable_selinux
        Echo_Green "Your repolist: "; yum repolist
        Echo_Green "Now the time is: "; date +%H:%M:%S
        Echo_Green "The iptables rules: "; iptables -nvL
        Echo_Green "Please reboot system!"
        ;;
esac

exit 0
