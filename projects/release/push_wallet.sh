#!/bin/bash
project_name=giveu_wallet
current_path=/var/www/http/giveu_wallet/current/
excludefiles=/usr/local/shell/dafycredit/excludefiles
list_file=/usr/local/shell/dafycredit/list


function usage()
{
    echo "./`basename $0` list，当有参数list存在时间，仅推送部分文件"
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


if [ $# -gt 1 ];then
    usage
elif [ $# -eq 1 ];then
    echo "Fuck"
elif [ $# -eq 0 ];then
    cat /dev/null > $list_file
    prompt_msg "以下是被忽略的文件/文件夹" BLUE
    cat $excludefiles > $list_file 2>/dev/null
    cat $list_file
    echo ""
    echo -n "是否继续(yes/no): "
    read ans
    while [[ "x"$ans != "xyes" && "x"$ans != "xno" && "x"$ans != "xy" && "x"$ans != "xn" ]]
    do
        echo -n "是否继续(yes/no): "
        read ans
    done

    if [ $ans = 'yes' -o $ans = 'y' ];then
        cd /var/www/http/giveu_wallet/current/

        current_commit=`git log | head -1 | awk '{print $2}'`
        exit_status "获取修改文件列表"

        git checkout master
        exit_status "切换至master分支"

        git pull
        exit_status "更新代码"

        gulp build
        exit_status "打包生成正式代码"

        ssh root@x.x.x.1 "cp -r /home/workspace/giveU-wallet /home/workspace/giveU-wallet_backup_`date +'%Y%m%d%H%M%S'`"
        exit_status "备份生产环境46即有钱包代码"


        ssh root@x.x.x.2 "cp -r /home/workspace/giveU-wallet /home/workspace/giveU-wallet_backup_`date +'%Y%m%d%H%M%S'`"
        exit_status "备份生产环境147即有钱包代码"

        sleep 2

        rsync -zrt -e 'ssh' --exclude='.git' --exclude='*.org' \
            --exclude-from=${excludefiles} --delete ${current_path} root@x.x.x.1:/home/workspace/giveU-wallet/
        exit_status "于`date +'%Y%m%d%H:%M:%S'`同步推送即有钱包至46生产环境"

        rsync -zrt -e 'ssh' --exclude='.git' --exclude='*.org' \
            --exclude-from=${excludefiles} --delete ${current_path} root@x.x.x.2:/home/workspace/giveU-wallet/
        exit_status "于`date +'%Y%m%d%H:%M:%S'`同步推送即有钱包至147生产环境"
    fi
fi
