#!/bin/ash
set -e

# 全局配置
config_file='/config/rclone.conf'

# 抽取参数，转换为本地参数名
subcommand=${PLUGIN_SUBCOMMAND}
name=${PLUGIN_NAME}
type=${PLUGIN_TYPE}
provider=${PLUGIN_PROVIDER}
access_key_id=${PLUGIN_ACCESS_KEY_ID}
secret_access_key=${PLUGIN_SECRET_ACCESS_KEY}
endpoint=${PLUGIN_ENDPOINT}
bucket=${PLUGIN_BUCKET}
source=${PLUGIN_SOURCE}
target=${PLUGIN_TARGET}

# 执行 rclone 命令
rclone --config ${config_file} ${subcommand} \
   ${PWD}${source}    ${name}:${bucket}${target} -P
