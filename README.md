# drone-rclone
![buildx](https://github.com/ryjer/drone-rclone/workflows/buildx/badge.svg)
![buildx](https://github.com/ryjer/drone-rclone/workflows/build-conf/badge.svg)
[![Docker Stars](https://img.shields.io/docker/stars/ryjer/drone-rclone.svg)](https://hub.docker.com/r/ryjer/drone-rclone/)
[![Docker Pulls](https://img.shields.io/docker/pulls/ryjer/drone-rclone.svg)](https://hub.docker.com/r/ryjer/drone-rclone/)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

Drone plugin to upload, remove and sync filesystems and object storage by rclone. 

用于对文件系统和对象存储进行上传、删除和同步等操作的drone rclone插件

# 1. 通用参数版本

##  1.1 用法示例

本插件用于在 Drone CI 中使用 rclone 工具。你可以使用本插件将文件推送到远端的网盘、网络存储或对象存储（比如 AWS S3、Minio、阿里 OSS、腾讯 COS 等）中。

通常在 Drone 中使用这类存储插件往往是为了进行部署，即将本地文件推送到远端对象存储。因此，本插件暂时只支持rclone中用于向远端对象存储推送的使用方式。

如果你希望本插件支持更多的 子命令功能，可以提交 Issues。

### 1 sync 同步示例

以下示例用于将由 git 仓库中刚刚生成的 `/public/` 文件夹同步（`sync`）到远端的 minio 对象存储的 `website-107893044`存储桶根路径（`/`）下。

**注意：** 同步过程不会同步**空文件夹**，同时会**删除**目标路径下**不存在**于源路径中的文件。

**提示：** 在配置对象存储前，请确认已拥有对应存储桶的读写权限。否则会操作失败

```yaml
kind: pipeline
name: default

steps:
- name: rclone deploy
  image: ryjer/drone-rclone
  settings:
    subcommand: sync
    source: /public/
    name: remotestore
    type: s3
    provider: Minio
    access_key_id: minioadminid
    secret_access_key: minioadminkey
    endpoint: http://play.minio.io
    bucket: website-107893044
    target: /
```

其效果等同于下面的 docker 命令：

```dockerfile
docker run -it --rm \
  -e PLUGIN_SUBCOMMAND=sync \
  -e PLUGIN_NAME=remotestore \
  -e PLUGIN_TYPE=s3 \
  -e PLUGIN_PROVIDER=Minio \
  -e PLUGIN_ACCESS_KEY_ID=minioadminid \
  -e PLUGIN_SECRET_ACCESS_KEY=minioadminkey \
  -e PLUGIN_ENDPOINT=http://play.minio.io \
  -e PLUGIN_BUCKET=website-107893044 \
  -e PLUGIN_SOURCE=/public/ \
  -e PLUGIN_TARGET=/ \
  -v $PWD:$PWD \
  ryjer/drone-rclone
```

### 2 copy 复制示例

如果你不想使用 `sync`子命令删除目标存储中不同的文件，可以使用 `copy` 子命令仅进行复制操作，其结果类似于 `cp` 命令。示例如下：

```yaml
kind: pipeline
name: default

steps:
- name: rclone deploy
  image: ryjer/drone-rclone
  settings:
    subcommand: copy
    source: /public/
    name: remotestore
    type: s3
    provider: Minio
    access_key_id: minioadminid
    secret_access_key: minioadminkey
    endpoint: http://play.minio.io
    bucket: website-107893044
    target: /
```

### 3 使用密令（secret）示例

如果他人也有你的git仓库的访问权限，则使用上述明文 `access_key_id`、`secret_access_key` 和 `bucket` 信息是非常危险的。你需要使用 drone 提供的 `secret` 机制来保护这些信息不被他人看见。

secret 的具体使用方法请参考官方文档 [Per Repository | Drone Secret](https://docs.drone.io/secret/repository/)

```yaml
kind: pipeline
name: default

steps:
- name: rclone deploy
  image: ryjer/drone-rclone
  settings:
    subcommand: sync
    source: /public/
    name: remotestore
    type: s3
    provider: Minio
    access_key_id: 
      from_secret: rclone_access_key_id
    secret_access_key: 
      from_secret: rclone_secret_access_key
    endpoint: http://play.minio.io
    bucket: 
      from_secret: rclone_bucket
    target: /
```

## 1.2 参数解释

### 1 rclone 配置参数

以下参数来自 `rclone` 的配置文件，这里建议在本地 rclone 配置调试好后将配置文件（通常是 `~/.config/rclone/rclone.conf` 文件）内的一个配置填入drone.yml 设置中。

| 参数              | 解释                                                         |
| ----------------- | ------------------------------------------------------------ |
| name              | 一个远端存储的名称，可以用字母数字随意命名，但**不得为空**             |
| type              | 存储类型                                                     |
| provider          | 提供商                                                       |
| access_key_id     | 密钥ID，不同的厂商有不同的叫法                               |
| secret_access_key | 密钥Key，不同的厂商有不同的叫法                              |
| endpoint          | 接入点，远端存储的网址，通常与地域有关。如果不指定协议，默认为 `https`。 |

上方示例设置中的以上参数，对用于 rclone.conf 配置文件中的一个配置如下，请注意一一对应。

```bash
[remotestore]
type = s3
provider = Minio
access_key_id = minioadminid
secret_access_key = minioadminkey
endpoint = http://play.minio.io
```

### 2 其他配置参数

| 参数       | 解释                                                         |
| ---------- | ------------------------------------------------------------ |
| subcommand | rclone 的子命令，暂时只支持 `sync` 和 `copy`                 |
| source     | 源路径，会以 git 仓库目录作为根目录。**不能为空**（`/` 表示git仓库根目录） |
| bucket     | 指定接入点下的存储桶名，请登录存储服务商查询存储桶名         |
| target     | 目标路径，会以存储桶作为根目录，**不得为空**（`/` 表示存储桶根目录） |

## 1.3 腾讯云 COS 示例

这里以位于**成都**的腾讯云 cos 对象存储桶同步为例，将 git 根目录下 `/public/` 文件夹的内容同步到成都地区的 `website-100000088` 存储桶的根路径 `/` 下。其配置示例如下：

```yaml
kind: pipeline
name: default

steps:
- name: rclone deploy
  image: ryjer/drone-rclone
  settings:
    subcommand: sync
    source: /public/
    name: chengducos
    type: s3
    provider: TencentCOS
    access_key_id: KJi9ajksng89IIFSjnf98OJdf98u08
    secret_access_key: MIOF89yS*F(H&oYHF&(9rf0-fs-0))
    endpoint: cos.ap-chengdu.myqcloud.com
    bucket: website-100000088
    target: /
```



## 1.4 参数取值参照表

### 1 常见类型（type）取值

此表仅供参考，而且仅有部分，具体可用取值请参考 [rclone官方文档](https://rclone.org/docs/)

| 类型                                                         | 取值                 |
| ------------------------------------------------------------ | -------------------- |
| Amazon Drive                                                 | amazon cloud drive   |
| S3 协议对象存储（包括AWS S3、阿里、ceph、IBM cos、腾讯云cos和minio） | s3                   |
| Backblaze B2 对象存储                                        | b2                   |
| Box                                                          | box                  |
| Dropbox                                                      | dropbox              |
| FTP 连接                                                     | ftp                  |
| google cloud storage 云存储                                  | google cloud storage |
| Google Drive                                                 | drive                |
| Hadoop 分布式文件系统                                        | hdfs                 |
| Microsoft OneDrive                                           | onedrive             |
| OpenStack Swift                                              | swift                |
| 青云对象存储                                                 | qingstor             |
| SSH/SFTP Connection                                          | sftp                 |
| Webdav                                                       | webdav               |
| seafile                                                      | seafile              |

### 2 当上表取 S3 时，常见提供商（provider）取值

| 提供商                | 取值（注意大小写） |
| --------------------- | ------------------ |
| 亚马逊AWS             | AWS                |
| 阿里云 OSS            | Alibaba            |
| 腾讯云 COS            | TencentCOS         |
| IBM COS S3            | IBMCOS             |
| Minio 对象存储        | Minio              |
| Ceph 对象存储         | ceph               |
| 其他S3 兼容的对象存储 | Other              |

# 2. 聚合参数版本

以上版本需要通过多个参数详细给出 rclone 中的一个配置，虽然具有通用格式但是很繁琐。

所以，在此提供一个聚合参数的版本 `ryjer/drone-rclone:conf`。该版本对于类似如下的一条 rclone 配置

```bash
[remotestore]
type = s3
provider = Minio
access_key_id = minioadminid
secret_access_key = minioadminkey
endpoint = http://play.minio.io
```

不再需要 6个配置参数详细给出。而是只使用一个参数 `rclone_config` ，一次性将整个配置条目给出，从而简化配置过程。也就是说，`rclone_config`参数将包含如上 6行 参数信息。
更好的效果是，使用聚合参数的版本一次可以给出不止一个配置，而可以给出多个配置，比如像下面的两个配置。从而更自由地使用 rclone 

```bash
[remotestore]
type = s3
provider = Minio
access_key_id = minioadminid
secret_access_key = minioadminkey
endpoint = http://play.minio.io

[remotestore]
type = s3
provider = TencentCOS
access_key_id = 98q23yfhq23hgfuf8afh9u
secret_access_key = af83hfg7uqy3ufjiq09tg2
endpoint = cos.ap-huoxing.myqcloud.com
```

##  2.1 用法示例

通过参数聚合，只需要以下示例即可完成一次 rclone 操作。

```yaml
kind: pipeline
name: default

steps:
- name: rclone sync
  image: ryjer/drone-rclone:conf
  settings:
    rclone_config: 
      from_secret: rclone_config
    subcommand: sync
    source: /test
    bucket: test
    target: /
```

该示例使用了 `secret`，考虑到一条 rclone 配置中有大量的敏感信息，这里强烈建议使用 `secret`。这需要创建如下所示的包含整条 rclone 配置的多行（>= 6 行） secret。

![add rclone_conf Secret](https://raw.githubusercontent.com/ryjer/drone-rclone/main/images/20210718185028-drone-rclone-conf-secret.png)

