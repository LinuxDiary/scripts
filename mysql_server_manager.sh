#!/bin/bash

# MySQL服务启动关闭脚本
## 安全起见，平滑关闭 MySQL 服务，关闭时时需要手动输入 root 密码

. /etc/init.d/functions

MYSQL_USER=root
PORT=3306
MYSQL_BIN_PATH="/home/mysql/u01/mysql/bin"
MYSQL_SOCKET="/home/mysql/u01/mysql/run/mysql.sock"

start_mysql()
{
    if [ -e $MYSQL_SOCKET ]; then
        echo "MySQL Server is running..."
        exit
    else
        $MYSQL_BIN_PATH/mysqld_safe --defaults-file=/home/mysql/u01/mysql/etc/my.cnf > /dev/null &
        if [[ $? = 0 ]];then
            sleep 2
            action "Start MySQL" /bin/true
        else
            action "Start MySQL" /bin/false
        fi
    fi
}

stop_mysql()
{
    if [ -e $MYSQL_SOCKET ]; then
        $MYSQL_BIN_PATH/mysqladmin -u$MYSQL_USER -p --socket=$MYSQL_SOCKET shutdown > /dev/null
        if [[ $? = 0 ]];then
            #sleep 2
            action "Stop MySQL" /bin/true
        else
            action "Stop MySQL" /bin/false
        fi
    else
        echo "MySQL Server is stopped..."
        exit
    fi
}

restart_mysql()
{
    stop_mysql
    start_mysql
}

case $1 in
    start   )
        start_mysql
        ;;
    stop    )
        stop_mysql
        ;;
    restart )
        restart_mysql
        ;;
    *   )
        echo -e "Usage: $MYSQL_BIN_PATH/mysqld_ss {start|stop|restart}\n"
        ;;
esac

exit 0
