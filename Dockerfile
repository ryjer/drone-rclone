# 模拟安装阶段
FROM alpine as install

WORKDIR /install

RUN apk add curl \
            bash \
    && curl https://rclone.org/install.sh | bash

# 包转移截断
FROM alpine

COPY --from=install /usr/local/bin/rclone /usr/local/bin/rclone
COPY rclone.sh /usr/local/

RUN apk --no-cache add ca-certificates fuse tzdata && \
  echo "user_allow_other" >> /etc/fuse.conf

RUN addgroup -g 1009 rclone && adduser -u 1009 -Ds /bin/sh -G rclone rclone && \
    chmod 755 /usr/local/rclone.sh

# 指定工作目录
WORKDIR /data

ENV XDG_CONFIG_HOME=/config

ENTRYPOINT ["/usr/local/rclone.sh"]