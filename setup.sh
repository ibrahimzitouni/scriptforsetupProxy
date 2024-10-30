#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

apt update && apt install -y python3-pip shadowsocks-libev curl

cat > /etc/shadowsocks-libev/config.json <<EOL
{
    "server": "0.0.0.0",
    "server_port": 8388,
    "timeout": 600,
    "method": "aes-256-gcm",
    "password": "ibrahim"
}
EOL

NGROK_PATH="/usr/local/bin/ngrok"
if [ ! -f "$NGROK_PATH" ]; then
    echo "Downloading and installing ngrok..."
    wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
    tar xvzf ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin
fi
echo "visit this website : https://dashboard.ngrok.com/get-started/your-authtoken"
read -p "Enter your ngrok auth token: " NGROK_TOKEN
$NGROK_PATH authtoken $NGROK_TOKEN

ss-server -c /etc/shadowsocks-libev/config.json &
ngrok tcp 8388
