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

project_name=zodiac
current_path=/var/www/http/activity/current/${project_name}
remote_path=/usr/local/workspace/activities/${project_name}
excludefiles=/usr/local/shell/activity_tools/excludefiles
_VERSION=$(date +"%Y%m%d%H%M%S")


cd ${current_path}/


current_commit=`git log | head -1 | awk '{print $2}'`
exit_status "获取修改文件列表"

git checkout master
exit_status "切换至master分支"

git pull
exit_status "更新代码"


npm run build
exit_status "打包活动正式代码"


prompt_msg '替换域名和appid' GREEN
cd ${current_path}/dist/
#sed -i "s/\.min\.js.\"/\.min\.js\?v\=${_VERSION}\"/g" index.html
#sed -i "s/\.min\.js.\"/\.min\.js\?v\=${_VERSION}\"/g" timeover.html

sed -i "s/http:\/\/domain1/https:\/\/doamin2/g" index.html
sed -i "s/http:\/\/domain1/https:\/\/doamin2/g" timeover.html

sed -i "s/appidx1/appidx2/g" index.html
sed -i "s/appidx1/appidx2/g" timeover.html

sed -i "s/http:\/\/domain1/https:\/\/doamin2/g" js/app.min.js
sed -i "s/appidx1/appidx2/g" js/app.min.js

ssh root@x.x.x.x "cp -r ${remote_path} ${remote_path}_backup_`date +'%Y%m%d%H%M%S'`"
exit_status "备份抓小鸡活动正式代码"
sleep 2

rsync -zrt -e 'ssh' --exclude='.git' --exclude='*.org' \
    --exclude-from=${excludefiles} --delete ${current_path}/dist/ root@x.x.x.x:${remote_path}/
exit_status "于`date +'%Y%m%d%H:%M:%S'`同步推送抓小鸡活动至生产环境"
