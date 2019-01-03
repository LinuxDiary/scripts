#!/bin/bash

# 批量添加相同密码的用户

NAMEPREFIX=name
USERCOUNTS=5
PASSWORD="PASSWORD"


for i in `seq 1 ${USERCOUNTS}`; do
    useradd ${NAMEPREFIX}${USERCOUNTS}
    echo ${PASSWORD} | passwd --stdin ${NAMEPREFIX}${USERCOUNTS}
done
