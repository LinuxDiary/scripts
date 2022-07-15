#!/bin/bash
#set -x
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

. functions.sh

Check_root
Check_Platform

Press_Start

cat << EOF
    [1]Set yum-repos to tsinghua
    [2]Set epel-repo to tsinghua
    [3]install mysql-repos from official
    [4]Install basic utils, network utils and update system
    [5]Set timezone and NTP
    [6]Enable firewalld
    [7]Set vi=vim
    [8]Set sysctl.conf
    [9]Disable ipv6
    [10]Disable selinux
    [a]Do all things(default)
    [0]Exit

$(Echo_Yellow "Note: Don't run this script twice!")

EOF

read -p "Choose what you want to do: " index

case "$index" in
    1)  d_yum
        Echo_Green "Your repolist: "; yum repolist
        ;;
    2)  d_epel
        ;;
    3)  d_mysql_repo
	;;
    4)  d_docker
        ;;
    5)  d_init
        ;;
    6)  d_ntp
        Echo_Green "Now the time is: "; date +%H:%M:%S
        ;;
    7)  d_firewalld
        Echo_Green "The firewalld rules: "; firewall-cmd --list-all
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
	d_docker
        d_init
        d_ntp
        d_firewalld
        d_vi
        d_sysctl
        d_disable_ipv6
	d_disable_selinux
        Echo_Green "Your repolist: "; yum repolist
        Echo_Green "Now the time is: "; date +%H:%M:%S
        Echo_Green "The firewall rules: "; firewall-cmd --list-all
        Echo_Green "Please reboot system!"
        ;;
esac

exit 0
