#!/bin/bash

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

# Update package list and install dependencies
echo "Updating package list and installing dependencies..."
apt update && apt install -y python3-pip shadowsocks-libev curl

# Generate the Shadowsocks configuration file
echo "Creating Shadowsocks configuration..."
CONFIG_PATH="/etc/shadowsocks-libev/config.json"
cat > $CONFIG_PATH <<EOL
{
    "server": "0.0.0.0",
    "server_port": 8388,
    "timeout": 600,
    "method": "aes-256-gcm",
    "password": "ibrahim"
}
EOL

echo "Configuration created at $CONFIG_PATH"


# Download ngrok if not already installed
NGROK_PATH="/usr/local/bin/ngrok"
if [ ! -f "$NGROK_PATH" ]; then
    echo "Downloading and installing ngrok..."
    wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
    tar xvzf ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin
fi

# Prompt for ngrok auth token
read -p "Enter your ngrok auth token: " NGROK_TOKEN
$NGROK_PATH authtoken $NGROK_TOKEN

# Start Shadowsocks
echo "Starting Shadowsocks server..."
ss-server -c $CONFIG_PATH &

# Start ngrok with Shadowsocks server
echo "Starting ngrok for port $SERVER_PORT..."
$NGROK_PATH tcp $SERVER_PORT
