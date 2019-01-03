#!/bin/bash
# set -x

# MySQL全量备份

# Common config
DATE=$(date +%Y-%m-%d)
TIME=$(date +"%Y-%m-%d %H:%m:%S")
OLDDATE=$(date +%Y-%m-%d -d '-30 days')
ORIGINDIR=/home/mysql56/master_backup/${DATE}
BACKUPDIR=/home/mysql56/mysql_backup
BACKUPTYPE=mysql
LOGFILE=/home/mysql56/logs/mysql.backup.${DATE}.log

# MySQL config
DEFAULTS_FILE=/home/mysql56/u01/mysql/etc/my.cnf
MYSQL_USER=backup
MYSQL_PASSWORD="PASSWORD"

# FTP Server config
HOST=192.168.1.13
PORT=2121
FTP_USERNAME=mysql_user
FTP_PASSWORD="PASSWORD"


MySQLBackup()
{
    innobackupex --defaults-file=${DEFAULTS_FILE} \
        --no-timestamp \
        --use-memory=1G \
        --parallel=4 \
        --user=${MYSQL_USER} \
        --password=${MYSQL_PASSWORD} ./ >> ${LOGFILE} 2>&1
}


PackBackup()
{
    echo
    echo "---------------------------------"
    echo "Start packing..."
    echo "---------------------------------"
    [ -e ${BACKUPDIR}/${DATE}/${BACKUPTYPE}_${DATE}.tar.gz ] && mv ${BACKUPDIR}/${DATE}/${BACKUPTYPE}_${DATE}.tar.gz ${BACKUPDIR}/${DATE}/${BACKUPTYPE}_${DATE}.tar.gz.${TIME}
    tar zcvf ${BACKUPDIR}/${DATE}/${BACKUPTYPE}_${DATE}.tar.gz ${ORIGINDIR##*/}
    echo "---------------------------------"
    echo "Packing completed!"
    echo "---------------------------------"
    echo
}


SaveToFTP()
{
    ftp -inv << EOF
open ${HOST} ${PORT}
user ${FTP_USERNAME} ${FTP_PASSWORD}
bin
cd dir
mkdir ${DATE}
cd ${DATE}
mput *
bye
EOF
}


DeleteLocalAndRemote()
{
    rm -rf ${BACKUPDIR}/${OLDDATE}
    ftp -inv << EOF
open ${HOST} ${PORT}
user ${FTP_USERNAME} ${FTP_PASSWORD}
bin
cd dir/${OLDDATE}
mdelete *
cd ..
rmdir ${OLDDATE}
bye
EOF
}


main()
{
    echo
    echo "================================="
    date +"%Y-%m-%d %H:%m:%S"
    echo "Backup Starting..."
    echo "================================="
    echo

    # Start backup
    [ -d ${ORIGINDIR} ] || mkdir -p ${ORIGINDIR}
    cd ${ORIGINDIR} && rm -rf *
    MySQLBackup

    # Start packing
    if [ $? == 0 ]; then
        [ -d ${BACKUPDIR}/${DATE} ] || mkdir -p ${BACKUPDIR}/${DATE}
        cd ${ORIGINDIR%/*}
        PackBackup
    else
        echo "Backup failed!"
        exit 1
    fi

    # Upload to FTP
    cd ${BACKUPDIR}/${DATE}
    SaveToFTP
    [ $? == 0 ] && rm -rf ${ORIGINDIR}

    # Delete Old
    [ -d ${BACKUPDIR}/${OLDDATE} ] && DeleteLocalAndRemote

    echo "Backup completed!"
    exit 0
}


main >> ${LOGFILE} 2>&1
