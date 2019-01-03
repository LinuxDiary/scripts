#!/bin/bash

# Common config
LOGFILE="/home/nginx/u01/nginx/logs/access.log"
LOGFILES="/home/nginx/u01/nginx/logs/*access*.log"
RESULTFILE="/home/nginx/result/output.txt"
RESPONSE_CODE="200"


# functions
filters()
{
    awk -v code="${RESPONSE_CODE}" '$9==code' | egrep -v "/rss/|robots.txt|.css|.js|.png|.jpg|.gif|.ico"
}


filters_404()
{
    grep "404"
}


request_ips()
{
    awk '{print $1}'
}


request_method()
{
    awk '{print $6}' | cut -d'"' -f2
}


request_pages()
{
    awk '{print $7}'
}


wordcount()
{
    sort | uniq -c
}


sort_desc()
{
    sort -nr
}


return_kv()
{
    awk '{print $1, $2}' OFS="\t"
}


request_pages()
{
    awk '{print $7}'
}


return_top_ten()
{
    head -10
}


## actions
get_request_ips()
{
    echo ""
    echo "Top 10 Request IP's:"
    echo "===================="

    cat $LOGFILE \
    | filters \
    | request_ips \
    | wordcount \
    | sort_desc \
    | return_kv \
    | return_top_ten
    echo ""
}


get_request_methods()
{
    echo "Top Request Methods:"
    echo "===================="

    cat $LOGFILE \
    | filters \
    | request_method \
    | wordcount \
    | return_kv
    echo ""
}


get_request_pages_404()
{
    echo "Top 10: 404 Page Responses:"
    echo "==========================="

    cat $LOGFILE \
    | filters_404 \
    | request_pages \
    | wordcount \
    | sort_desc \
    | return_kv \
    | return_top_ten
    echo ""
}


get_request_pages()
{
    echo "Top 10 Request Pages:"
    echo "====================="

    cat $LOGFILE \
    | filters \
    | request_pages \
    | wordcount \
    | sort_desc \
    | return_kv \
    | return_top_ten
    echo ""
}


get_request_pages_all()
{
    echo "Top 10 Request Pages from All Logs:"
    echo "==================================="

    cat $LOGFILES \
    | filters \
    | request_pages \
    | wordcount \
    | sort_desc \
    | return_kv \
    | return_top_ten
    echo ""
}


main()
{
    get_request_ips
    get_most_request_time
    get_request_methods
    get_request_pages
    get_request_pages_all
    get_request_pages_404
}


[ -d ${RESULTFILE%/*} ] || mkdir -p ${RESULTFILE%/*}
main >> ${RESULTFILE}

exit 0
