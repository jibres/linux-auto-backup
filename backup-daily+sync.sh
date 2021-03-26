#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")"
#define backup type
BACKUP_FOLDER="daily"
# call backup script
source start-backup-from-all-databases.sh
# sync backup
source sync-changes.sh
# done.