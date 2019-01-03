#!/usr/bin/env python3

# 局域网内在线主机统计
# 需要安装 python-nmap 

import nmap


HOSTS = '192.168.10.0/24'
ARGUMENTS = '-n -sP -PE'

nm = nmap.PortScanner()
nm.scan(hosts=HOSTS, arguments=ARGUMENTS, sudo=True)
print("=============================\n"
+ str(len(nm.all_hosts())) + " Hosts alived!\n"
+ "=============================\n"
)

for ip in nm.all_hosts():
    print(ip + ' : ' + nm[ip].state())

```