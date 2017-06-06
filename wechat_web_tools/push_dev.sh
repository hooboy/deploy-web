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


git pull
exit_status "更新代码"


gulp uat
exit_status "打包即有钱包开发代码"


rsync -a --exclude-from=${excludefiles} /var/www/http/giveu_wallet/current/dist/ /usr/local/GMD/giveU-wallet/dist/
exit_status "同步至即有钱包开发环境"


sleep 1

prompt_msg '替换域名wx.dafycredit.cn为idcwxtest.dafysz.cn,更新appid'
cd /usr/local/GMD/giveU-wallet/dist/
sed  -i "s/appid=x1/appid=x2/g" index.html
sed  -i "s/http:\/\/domain1/http:\/\/domain2/g" index.html

sleep 1
cd /usr/local/GMD/giveU-wallet/dist/static/
sed  -i "s/http:\/\/domain1/http:\/\/domain2/g"  app.js
sed  -i "s/https:\/\/domain1/https:\/\/domain2/g"  app.js
sed  -i "s/appid=x1/appid=x2/g"  app.js

sleep 1

exit_status "同步至即有钱包开发环境完成..."
