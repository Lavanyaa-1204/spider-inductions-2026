#!/bin/bash
set -e
APP_DIR="/var/www/spider-app"
LOG_FILE="/var/log/spider/deploy.log"

echo "[*] deploy.sh started at $(date)" >> $LOG_FILE
git pull origin main
npm install
chmod 777 $APP_DIR
chmod 777 $APP_DIR/config
chmod 777 $APP_DIR/logs

export PATH=$PATH:/opt/spider-tools/bin:/tmp/tools/bin
sudo systemctl restart spider-app
sudo systemctl restart nginx
rm -rf /tmp/*
cp ./config/.env $APP_DIR/.env
chmod 777 $APP_DIR/.env
echo "[*] deploy.sh completed at $(date)" >> $LOG_FILE