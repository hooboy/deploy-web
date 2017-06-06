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
current_path=/var/www/http/activity/current/${activity_name}
excludefiles=/usr/local/shell/activity_tools/excludefiles
_VERSION=$(date +"%Y%m%d%H%M%S")


cd ${current_path}


current_commit=`git log | head -1 | awk '{print $2}'`
exit_status "获取修改文件列表"


git pull
exit_status "更新代码"


npm run dev
exit_status "打包微信抓小鸡活动"


rsync -a --exclude-from=${excludefiles} ${current_path}/ /usr/local/workspace/activities/${activity_name}/
exit_status "同步抓小鸡活动至开发环境"

cd /usr/local/workspace/activities/${activity_name}/
sed -i "s/\.min\.js/\.min\.js\?v\=${_VERSION}/g" index.html
sed -i "s/\.min\.js/\.min\.js\?v\=${_VERSION}/g" timeover.html
