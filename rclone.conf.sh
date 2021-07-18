#!/bin/ash
set -e

# 全局配置
config_file='/config/rclone.conf'

# 抽取参数
subcommand=${PLUGIN_SUBCOMMAND}
rclone_config=${PLUGIN_RCLONE_CONFIG}
source=${PLUGIN_SOURCE}
bucket=${PLUGIN_BUCKET}
target=${PLUGIN_TARGET}
#调试打印
#echo "变量信息："
#echo "subcommand = ${PLUGIN_SUBCOMMAND}"
#echo "rclone_config = ${PLUGIN_RCLONE_CONFIG}"
#echo "source = ${PLUGIN_SOURCE}"
#echo "target = ${PLUGIN_TARGET}"

# 将配置参数注入配置文件
echo "${rclone_config}" > ${config_file}
#调试打印
#cat ${config_file}

# 抽取 配置文件第一行的 name
name=$(sed -n '1s/\[//; 1s/\]//; 1p' ${config_file})

# 执行 rclone 命令，以当前工作目录为根目录
echo "======== ======== rclone 开始 ======== ========"
rclone --config ${config_file} ${subcommand} \
    ${PWD}${source}    ${name}:${bucket}${target} -P

