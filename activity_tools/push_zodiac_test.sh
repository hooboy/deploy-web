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

activity_name=zodiac
current_dir=/home/local/workspace/activity/
current_path=${current_dir}${activity_name}
remote_path=/var/www/http/activity/current/zodiac
excludefiles=/root/activity_tools/excludefiles
_VERSION=$(date +"%Y%m%d%H%M%S")


prompt_msg '开始推送活动代码' YELLOW


cp -r ${current_path} ${current_dir}zodiac_backup_`date +'%Y%m%d%H%M%S'`
exit_status "备份测试环境活动代码"


rsync -avr -p --exclude-from=${excludefiles} -e ssh --delete  root@x.x.x.x:${remote_path}/ ${current_path}/
exit_status "同步抓小鸡活动至测试环境"


prompt_msg '替换域名和appid' GREEN
cd ${current_path}/
sed -i "s/\.min\.js/\.min\.js\?v\=${_VERSION}/g" index.html
sed -i "s/\.min\.js/\.min\.js\?v\=${_VERSION}/g" timeover.html

sed -i "s/http:\/\/domain1/http:\/\/domain2/g" index.html
sed -i "s/http:\/\/domain1/http:\/\/domain2/g" timeover.html

sed -i "s/appid\=x1/appid\=x2/g" index.html
sed -i "s/appid\=x1/appid\=x2/g" timeover.html


sed -i "s/http:\/\/domain1/http:\/\/domain2/g" js/app.min.js
sed -i "s/appid\=x1/appid\=x2/g" js/app.min.js
