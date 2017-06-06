#!/bin/bash

function usage()
{
    echo "./`basename $0`"
    exit 0
}

function prompt_msg
{
    case "$2" in
        "RED")
            echo -e "\033[31m""$1""\033[0m";
        ;;
        "GREEN")
            echo -e "\033[32m""$1""\033[0m";
        ;;
        "YELLOW")
            echo -e "\033[33m""$1""\033[0m";
        ;;
        "BLUE")
            echo -e "\033[34m""$1""\033[0m";
        ;;
        *)
            echo -e "$1"
        ;;
        esac
}

function exit_status()
{
    if [ $? -ne 0 ];then
        prompt_msg "$1 [FAILURE]..." RED
        exit 1
    else
        prompt_msg "$1 [SUCCESS]..." GREEN
    fi
}

project_name=giveu_wallet
current_path=/var/www/http/giveu_wallet/current/
excludefiles=/usr/local/shell/giveu_tools/excludefiles

cd /var/www/http/giveu_wallet/current/


current_commit=`git log | head -1 | awk '{print $2}'`
exit_status "获取修改文件列表"

git checkout master
exit_status "切换至master分支"

git pull
exit_status "更新代码"


gulp build
exit_status "build正式代码"


ssh root@x.x.x.1 "cp -r /home/workspace/giveU-wallet /home/workspace/giveU-wallet_backup_`date +'%Y%m%d%H%M%S'`"
exit_status "备份生产环境代码"
sleep 2

rsync -zrt -e 'ssh' --exclude='.git' --exclude='*.org' \
    --exclude-from=${excludefiles} --delete ${current_path} root@x.x.x.1:/home/workspace/giveU-wallet/
exit_status "于`date +'%Y%m%d%H:%M:%S'`同步推送即有钱包生产环境"

