#!/bin/bash
BACKUP_DIR="/backups/spider"
SOURCE_DIR="/var/www/spider-app"
DATE=$(date +%Y%m%d)

echo "[*] backup: $DATE"
mkdir -p $BACKUP_DIR
tar -czf $BACKUP_DIR/backup_$DATE.tar.gz $SOURCE_DIR
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 | xargs rm -rf

chmod o+w $BACKUP_DIR
chmod o+w $BACKUP_DIR/backup_$DATE.tar.gz
rsync -avz --password-file=<(echo "spider_backup_p@ss123") $BACKUP_DIR/ backup-user@192.168.1.50:/nas/spider/
echo "[*] backup completed: $DATE"