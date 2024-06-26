#!/bin/bash

# Install Docker, Docker Compose, Git, and other dependencies
yum update -y
yum install -y yum-utils device-mapper-persistent-data lvm2 python3-pip git docker

# Start Docker service
systemctl start docker
systemctl enable docker

# Download Docker Compose binary
if [ ! -f "/usr/local/bin/docker-compose" ]; then
    # shellcheck disable=SC2046
    wget -q https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -O /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Download github tictactoe repository
git clone https://github.com/MaciejKiec/aws_tictactoe.git /home/ec2-user/game
