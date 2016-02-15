#!/bin/bash

docker run -d --restart=always \
    --hostname=gitlab.xendebian.local \
    -p 2234:22 -p 8091:80 -p 4431:443 \
    -v /etc/gitlab:/etc/gitlab \
    -v /var/opt/gitlab:/var/opt/gitlab \
    -v /var/log/gitlab:/var/log/gitlab \
    --name gitlab_server gitlab/gitlab-ce
