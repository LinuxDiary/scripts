#!/bin/bash

E_NOT_ROOT=65
E_BAD_PLATFORM=66
E_MYSQL_TAR_EXIST=67
E_NOT_IN_SRC_DIR=68
E_MYSQL_BASEDIR_EXIST=69
E_CMAKE_ERROR=70

Color_Text()
{
  echo -e " \e[0;$2m$1\e[0m"
}

Echo_Red()
{
  echo $(Color_Text "$1" "31")
}

Echo_Green()
{
  echo $(Color_Text "$1" "32")
}

Echo_Yellow()
{
  echo $(Color_Text "$1" "33")
}

Echo_Blue()
{
  echo $(Color_Text "$1" "34")
}

Check_root()
{
    if [[ `id -u` != "0" ]]; then
        echo "You must run this script as root!"
        exit $E_NOT_ROOT
    fi
}

#Check Distribustion
Check_Dist()
{
    if grep -Eq "CentOS" /etc/*-release || grep -Eqi "CentOS" /etc/issue; then
        DIST="CentOS"
    elif grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release || grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue; then
        DIST="RHEL"
    else
        DIST="unknown"
    fi
}

#Check Distribustion Version
Check_Dist_Ver()
{
    if [ -s /usr/bin/python3 ]; then
        eval ${DIST}_Version=`/usr/bin/python3 -c 'import platform; print(platform.linux_distribution()[1])'`
    elif [ -s /usr/bin/python2 ]; then
        eval ${DIST}_Version=`/usr/bin/python2 -c 'import platform; print platform.linux_distribution()[1]'`
    fi
    if [ $? -ne 0 ]; then
        yum -y install redhat-lsb
        eval ${DIST}_Version=`lsb_release -rs`
    fi
}

#Check arch
Check_Arch()
{   
    if [[ $(getconf WORD_BIT) = "32" && $(getconf LONG_BIT) = "64" ]]; then
        Is_x86_64="y"
    else
        Is_x86_64="n"
    fi
}

#Check Platform
Check_Platform()
{
    Check_Dist
    Check_Dist_Ver
    Check_Arch
    if [[ ${DIST} = "CentOS" || ${DIST} = "RHEL" ]]; then
        dist_version=$(eval echo \${${DIST}_Version} | awk -F '.' '{print $1}')
        if [[ $dist_version = "7" && ${Is_x86_64} = "y" ]]; then
            Echo_Yellow  "Platform is ok..."
        else
            Echo_Red "This script just for CentOS or RHEL 7 x86_64,quit..."
            exit $E_BAD_PLATFORM
        fi
    fi
}

Press_Start()
{
    echo ""
    Echo_Green "Press any key to start or Press Ctrl+C to quit"
    OLDSTTY=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDSTTY}
}

Press_Continue()
{
    echo ""
    Echo_Green "Press any key to continue or Press Ctrl+C to quit"
    OLDSTTY=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDSTTY}
}

t_yum()
{
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
    echo '
# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the
# remarked out baseurl= line instead.
#
#

[base]
name=CentOS-$releasever - Base
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/os/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#released updates
[updates]
name=CentOS-$releasever - Updates
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/updates/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/extras/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos/$releasever/centosplus/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
' > /etc/yum.repos.d/CentOS-Base.repo
    yum clean all
    rm -rf /var/cache/yum
    yum makecache
}

d_yum(){
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
    curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    sed -i '/aliyuncs/d' /etc/yum.repos.d/CentOS-Base.repo
    yum clean all
    rm -rf /var/cache/yum
    yum makecache
}

d_epel(){
    [ -e /etc/yum.repos.d/epel.repo ] && mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup
    [ -e /etc/yum.repos.d/epel-testing.repo ] && mv /etc/yum.repos.d/epel-testing.repo /etc/yum.repos.d/epel-testing.repo.backup
    curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
}

d_init(){
    yum remove -y dhclient dhcp-*
    yum -y install vim wget bash-completion gcc gcc-c++ lftp lrzsz screen unzip bzip2 git gdb net-tools bind-utils lsof yum-utils psmisc tree

    # yum update -y
}

d_ntp(){
    timedatectl set-timezone Asia/Shanghai
    yum -y install chrony
    systemctl start chronyd
}

d_iptables(){
    systemctl stop firewalld.service
    systemctl disable firewalld.service

    yum -y install iptables-services

    systemctl start iptables.service
    systemctl enable iptables.service

    systemctl stop ip6tables.service
    systemctl disable ip6tables.service
}

d_vi(){
        sed -i 's/\[ -n "$ID"/#\[ -n "$ID"/' /etc/profile.d/vim.sh
}

d_sysctl(){
    if [ ! -f "/etc/sysctl.conf.bak" ]; then
        cp /etc/sysctl.conf /etc/sysctl.conf.bak
    fi

    cat > /etc/sysctl.conf << EOF
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl =15
net.ipv4.tcp_retries1 = 3
net.ipv4.tcp_retries2 = 5
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_max_tw_buckets = 60000
net.ipv4.tcp_max_orphans = 32768
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_wmem = 4096 16384 13107200
net.ipv4.tcp_rmem = 4096 87380 17476000
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.route.gc_timeout = 100
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.nf_conntrack_max = 6553500
net.netfilter.nf_conntrack_max = 6553500
net.netfilter.nf_conntrack_tcp_timeout_established = 180
vm.overcommit_memory = 1
vm.swappiness = 1
EOF
 
/sbin/sysctl -p
sleep 1
}

d_disable_ipv6(){
    echo "NETWORKING_IPV6=no">/etc/sysconfig/network
    echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
    echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6
    echo "127.0.0.1   localhost   localhost.localdomain">/etc/hosts
    # sed -i 's/IPV6INIT=yes/IPV6INIT=no/g' /etc/sysconfig/network-scripts/ifcfg-enp0s8


    for line in $(ls -lh /etc/sysconfig/network-scripts/ifcfg-* | awk '{print $9}')  
    do
        if [ -f  $line ]; then
            sed -i 's/IPV6INIT=yes/IPV6INIT=no/g' $line
        fi
    done
}