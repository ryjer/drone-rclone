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
# 调试信息
echo "环境变量抽取信息"、
echo "subcommand = ${subcommand}"
echo "name = ${name}"
echo "type= ${type}"
echo "provider = ${provider}"
echo "access_key_id = ${access_key_id}"
echo "secret_access_key = ${secret_access_key}"
echo "endpoint = ${endpoint}"
echo "bucket = ${bucket}"
echo "source = ${source}"
echo "target = ${target}"

#向配置文件中注入配置
echo "环境变量 XDG_CONFIG_HOME=${XDG_CONFIG_HOME}"
ls -a /
touch ${config_file}
echo "创建配置目录后："
ls ${XDG_CONFIG_HOME}
echo "[${name}]" > ${config_file}
echo "type = ${type}" >> ${config_file}
echo "provider = ${provider}" >> ${config_file}
echo "access_key_id = ${access_key_id}" >> ${config_file}
echo "secret_access_key = ${secret_access_key}" >> ${config_file}
echo "endpoint = ${endpoint}" >> ${config_file}
# 调试信息
echo "配置文件信息："
cat ${config_file}

# 执行 rclone 命令
echo "rclone 命令执行"
echo "rclone --config ${config_file} ${subcommand} ${source} ${name}:${bucket}${target} -P"
rclone --config ${config_file} ${subcommand} \
   ${PWD}${source}    ${name}:${bucket}${target} -P
