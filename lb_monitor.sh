#!/bin/bash

# Nginx+Keepalived状态监控

while True; do
    nginx_pid_counts=$(ps -C nginx --no-header | wc -l)
    if [ $nginx_pid_counts -eq 0 ]; then
        /usr/local/bin/nginx
        sleep 5
        if [ $nginx_pid_counts -eq 0 ]; then
            systemctl stop keepalived
        fi
    fi
    sleep 5
done
