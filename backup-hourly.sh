#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")"
#define backup type
BACKUP_FOLDER="hourly"
# call backup script
source start-backup-from-all-databases.sh
# done.