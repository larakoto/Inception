#!/bin/bash
wordpressFolder="/home/larakoto/data/wordpress"
mariadbFolder="/home/larakoto/data/mariadb"
secretFolder="./secrets"
if [  -d "$mariadbFolder" ]; then    
    sudo rm -rf $mariadbFolder 
fi

if [  -d "$wordpressFolder" ]; then
    sudo rm -rf $wordpressFolder
fi

if [  -d "$secretFolder" ]; then
    sudo rm -rf $secretFolder
fi

if [ -f "srcs/.env" ];then
    sudo rm -f "srcs/.env"
fi