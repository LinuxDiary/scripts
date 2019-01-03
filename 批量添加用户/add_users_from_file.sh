#!/bin/bash

## file:
## user1  123456
## user2  654321
## user3  abcdef
## ...


while read line; do
    user=$(echo $line | awk '{print $1}')
    password=$(echo $line | awk '{print $2}')
    useradd $user
    echo $password | passwd --stdin $user
done < file