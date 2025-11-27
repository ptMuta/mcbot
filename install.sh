#!/bin/bash
set -e

echo "=== Minecraft Discord Bot Installer ==="
echo ""

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 
   exit 1
fi

read -p "Service name [mcbot]: " SERVICE_NAME
SERVICE_NAME=${SERVICE_NAME:-mcbot}

SERVICE_FILE="${SERVICE_NAME,,}.service"
SERVICE_FILE="${SERVICE_FILE// /-}"

read -p "Installation directory [/opt/$SERVICE_NAME]: " INSTALL_DIR
INSTALL_DIR=${INSTALL_DIR:-/opt/$SERVICE_NAME}

echo ""
echo "=== Configuration ==="
echo "Service name: $SERVICE_NAME"
echo "Service file: $SERVICE_FILE"
echo "Installation directory: $INSTALL_DIR"
echo "Service user: $SERVICE_NAME"
echo ""

echo "[1/7] Collecting installation variables..."
echo ""
read -p "Discord bot token (required): " DISCORD_BOT_TOKEN
while [ -z "$DISCORD_BOT_TOKEN" ]; do
    echo "Error: Discord bot token is required"
    read -p "Discord bot token (required): " DISCORD_BOT_TOKEN
done

read -p "RCON host [localhost]: " RCON_HOST
RCON_HOST=${RCON_HOST:-localhost}

read -p "RCON port [25575]: " RCON_PORT
RCON_PORT=${RCON_PORT:-25575}

read -p "RCON password (required): " RCON_PASSWORD
while [ -z "$RCON_PASSWORD" ]; do
    echo "Error: RCON password is required"
    read -p "RCON password (required): " RCON_PASSWORD
done

echo ""

echo "[2/7] Creating service user..."
if id "$SERVICE_NAME" &>/dev/null; then
    echo "  User $SERVICE_NAME already exists"
else
    useradd -r -s /bin/false -d $INSTALL_DIR -M $SERVICE_NAME
    echo "  Created user $SERVICE_NAME"
fi

echo "[3/7] Creating installation directory..."
mkdir -p $INSTALL_DIR
cp -r main.py commands requirements.txt $INSTALL_DIR/
chown -R $SERVICE_NAME:$SERVICE_NAME $INSTALL_DIR
echo "  Files copied to $INSTALL_DIR"

echo "[4/7] Setting up Python virtual environment..."
python3 -m venv $INSTALL_DIR/venv
chown -R $SERVICE_NAME:$SERVICE_NAME $INSTALL_DIR/venv
echo "  Virtual environment created"

echo "[5/7] Installing Python dependencies..."
sudo -u $SERVICE_NAME $INSTALL_DIR/venv/bin/pip install --upgrade pip -q
sudo -u $SERVICE_NAME $INSTALL_DIR/venv/bin/pip install -r $INSTALL_DIR/requirements.txt -q
echo "  Dependencies installed"

echo "[6/7] Installing systemd service..."
cat > /etc/systemd/system/$SERVICE_FILE <<EOF
[Unit]
Description=Minecraft Discord Bot
After=network.target

[Service]
Type=simple
User=$SERVICE_NAME
Group=$SERVICE_NAME
WorkingDirectory=$INSTALL_DIR
Environment="DISCORD_BOT_TOKEN=$DISCORD_BOT_TOKEN"
Environment="RCON_HOST=$RCON_HOST"
Environment="RCON_PORT=$RCON_PORT"
Environment="RCON_PASSWORD=$RCON_PASSWORD"
ExecStart=$INSTALL_DIR/venv/bin/python main.py
Restart=always
RestartSec=10
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$INSTALL_DIR
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true

[Install]
WantedBy=multi-user.target
EOF

chmod 644 /etc/systemd/system/$SERVICE_FILE
systemctl daemon-reload
echo "  Service file installed"

echo "[7/7] Starting service..."
systemctl enable --now $SERVICE_FILE
echo "  Service started"

echo ""
echo "Installation complete. View logs: journalctl -u $SERVICE_FILE -f"
echo ""
