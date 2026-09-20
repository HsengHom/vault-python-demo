#!/usr/bin/env bash
set -e

# 1. Download and extract application
curl -LO https://github.com/HsengHom/vault-python-demo/releases/download/v1.0.4/vault-python-app_linux_amd64.tar.gz
tar -xzf vault-python-app_linux_amd64.tar.gz

# 2. Copy files to /opt/vault-python-app
sudo mkdir -p /opt/vault-python-app
sudo cp -r vault-python-app/* /opt/vault-python-app/

# 3. Create system user and set ownership
id -u vaultapp >/dev/null 2>&1 || sudo useradd --system --no-create-home --shell /usr/sbin/nologin vaultapp
sudo chown -R vaultapp:vaultapp /opt/vault-python-app

# 4. Set up Python virtual environment
sudo rm -rf /opt/vault-python-app/venv
sudo -u vaultapp python3 -m venv /opt/vault-python-app/venv
sudo -u vaultapp /opt/vault-python-app/venv/bin/pip install -r /opt/vault-python-app/requirements.txt

# 5. Create environment file
sudo tee /etc/vault-python-app.env > /dev/null <<'EOF'
VAULT_ADDR="https://uptake-freebie-hypnotist.ngrok-free.dev"
VAULT_TOKEN="hvs.b8fEJ47KHnoNt16zTzMA2jgA"
VAULT_ROLE_ID=1b16e12e-3123-09c5-cbd9-611afcaa2e12
VAULT_SECRET_ID=cdbe599c-7fed-8cec-4695-0d2a9548eaff

EOF

sudo chown root:vaultapp /etc/vault-python-app.env
sudo chmod 640 /etc/vault-python-app.env


# 6. Create systemd service file for app1 and app

sudo tee /etc/systemd/system/vault-python-app.service > /dev/null <<'EOF'
[Unit]
Description=Vault Python Application
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=vaultapp
Group=vaultapp
WorkingDirectory=/opt/vault-python-app
EnvironmentFile=/etc/vault-python-app.env
ExecStart=/opt/vault-python-app/venv/bin/python /opt/vault-python-app/app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 7. Reload and start systemd service
sudo systemctl daemon-reload
sudo systemctl enable vault-python-app
sudo systemctl restart vault-python-app
sudo systemctl status vault-python-app --no-pager

# 8. Create systemd service file for app1 and app2 

sudo tee /etc/systemd/system/vault-python-app2.service > /dev/null <<'EOF'
[Unit]
Description=Vault Python Application
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=vaultapp
Group=vaultapp
WorkingDirectory=/opt/vault-python-app
EnvironmentFile=/etc/vault-python-app.env
ExecStart=/opt/vault-python-app/venv/bin/python /opt/vault-python-app/app2.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 9. Reload and start systemd service
sudo systemctl daemon-reload
sudo systemctl enable vault-python-app2
sudo systemctl restart vault-python-app2
sudo systemctl status vault-python-app2 --no-pager

