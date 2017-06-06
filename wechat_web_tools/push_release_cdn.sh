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
CDN_URL=https://x.cdn.com/

# ftp信息
ftp_host=x.x.x.1
ftp_port=21
ftp_user=admin
ftp_pass=admin


cd /var/www/http/giveu_wallet/current/


current_commit=`git log | head -1 | awk '{print $2}'`
exit_status "获取修改文件列表"


git pull
exit_status "更新代码"


gulp build --cdn
exit_status "build正式代码"

lftp -u ${ftp_user},${ftp_pass} -p ${ftp_port} ${ftp_host} -e "set ftp:list-options -a && mirror -v -c --delete --exclude=^\.git/ --exclude '.html' --exclude=^\.ftp_ignore -R /var/www/http/giveu_wallet/current/dist /giveu_wallet/. && wait all && exit" 2>&1
exit_status "上传静态资源到cdn"


cd /var/www/http/giveu_wallet/current/dist/
sed -i "s/\.\/static/https:\/\/my-server-879.b0.upaiyun.com\/giveu_wallet\/static/g" index.html
sed -i "s/\"static\/css/\"https:\/\/my-server-879.b0.upaiyun.com\/giveu_wallet\/static\/css/g" index.html
sed -i "s/\"app.css/\"https:\/\/my-server-879.b0.upaiyun.com\/giveu_wallet\/app.css/g" index.html
exit_status "添加cdn"


ssh root@x.x.x.1 "cp -r /home/workspace/giveU-wallet/dist /home/workspace/giveU-wallet/dist_backup_`date +'%Y%m%d%H%M%S'`"
exit_status "备份生产环境代码"
sleep 1

rsync -zrt -e 'ssh' --exclude='.git' --exclude='*.org' \
    --exclude-from=${excludefiles} --delete ${current_path} root@x.x.x.1:/home/workspace/giveU-wallet/
exit_status "${SUDO_USER}于`date +'%H:%M:%S'`同步推送即有钱包生产环境"

