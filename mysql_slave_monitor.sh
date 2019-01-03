#!/bin/bash

# MySQL从库状态监控,需要配置邮件发送服务
## */5 * * * * /bin/bash /home/mysql/mysql_slave_monitor.sh

export PATH=/home/mysql/u01/mysql/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin

USER='root'
PASSWORD='PASSWORD'
HOST=
PORT=
SOCKET='/home/mysql/u01/mysql-multi/3306/run/mysql.sock'
TMP='/home/mysql/tmp'
TMPFILE='ruv6GKje2q'
EMAIL='sendmail@163.com'


[[ -d $TMP ]] || mkdir -p $TMP

mysql_check=$(mysqladmin -u$USER -p$PASSWORD --socket=$SOCKET ping 2> /dev/null)
slave_check=$(mysql -u$USER -p$PASSWORD --socket=$SOCKET -e 'show slave status\G' 2> /dev/null)

io_status=$(echo "$slave_check" | grep "Slave_IO_Running:" | awk '{ print $2 }')
sql_status=$(echo "$slave_check" | grep "Slave_SQL_Running:" | awk '{ print $2 }')
seconds_behind_master=$(echo "$slave_check" | grep "Seconds_Behind_Master" | awk '{ print $2 }')

if [[ $mysql_check != "mysqld is alive" ]]; then
    echo "
================================================================================
= MySQL is not alive, please check the server !!! 
================================================================================
`date`
" > $TMP/$TMPFILE
    cat $TMP/$TMPFILE
    # mail -s 'MySQL is not alive' $email < $TMP/$TMPFILE
    exit 1
fi


if [[ $io_status != "Yes" || $sql_status != "Yes" ]]; then
    echo "
================================================================================
= Slave is down, please check the slave server !!! 
================================================================================
`date`
" > $TMP/$TMPFILE
    echo "$slave_check" >> $TMP/$TMPFILE
    cat $TMP/$TMPFILE
    # mail -s 'Slave is down' $email < $TMP/$TMPFILE
elif [[ $seconds_behind_master -gt 60 ]]; then
    echo "
================================================================================
= Slave is working, but the slave is $seconds_behind_master seconds behind the master !!! 
================================================================================
`date`
" > $TMP/$TMPFILE
    echo "$slave_check" >> $TMP/$TMPFILE
    cat $TMP/$TMPFILE
    # mail -s 'Slave is behind master' $email < $TMP/$TMPFILE
fi
