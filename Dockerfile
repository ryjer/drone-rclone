# 选取官方镜像
FROM rclone/rclone:1.52.3 as install

# 包转移截断
FROM alpine:latest

COPY --from=install /usr/local/bin/rclone /usr/local/bin/rclone
COPY rclone.sh /usr/local/

RUN apk --no-cache add ca-certificates fuse tzdata && \
  echo "user_allow_other" >> /etc/fuse.conf

# XDG目录规范
ENV XDG_CONFIG_HOME=/config

RUN addgroup -g 1009 rclone && \
    adduser -u 1009 -Ds /bin/sh -G rclone rclone && \
    chmod 755 /usr/local/rclone.sh && \
    mkdir ${XDG_CONFIG_HOME}

# 指定工作目录
WORKDIR /data

ENTRYPOINT ["/usr/local/rclone.sh"]
