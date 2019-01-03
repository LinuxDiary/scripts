#!/bin/bash

## 本地和远程双备份，备份保留30天

# Common config
DATE=$(date +%Y-%m-%d)
TIME=$(date +"%Y-%m-%d %H:%m:%S")
OLDDATE=$(date +%Y-%m-%d -d '-30 days')
ORIGINDIR=/www/web/escst_com/public_html/upload
BACKUPDIR=/root/upload_backup
BACKUPTYPE=upload
LOGFILE=/root/logs/file.backup.${DATE}.log

# FTP Server config
HOST=192.168.1.13
PORT=2121
FTP_USERNAME=upload_user
FTP_PASSWORD="PASSWORD"


PackBackup()
{
    echo
    echo "---------------------------------"
    echo "Start packing..."
    echo "---------------------------------"
    [ -e ${BACKUPDIR}/${DATE}/${BACKUPTYPE}_${DATE}.tar.gz ] && mv ${BACKUPDIR}/${DATE}/${BACKUPTYPE}_${DATE}.tar.gz ${BACKUPDIR}/${DATE}/${BACKUPTYPE}_${DATE}.tar.gz.${TIME}
    tar zcvf ${BACKUPDIR}/${DATE}/upload_${DATE}.tar.gz ${ORIGINDIR##*/}
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

    [ -d  ${BACKUPDIR}/${DATE} ] || /bin/mkdir -p ${BACKUPDIR}/${DATE}
    cd ${ORIGINDIR%/*}
    PackBackup

    sleep 2

    cd ${BACKUPDIR}/${DATE}
    SaveToFTP

    [ -d ${BACKUPDIR}/${OLDDATE} ] && DeleteLocalAndRemote

    echo "Backup completed!"
    exit 0
}


[ -d ${ORIGINDIR} ] && main >> ${LOGFILE} 2>&1
