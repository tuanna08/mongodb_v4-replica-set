#!/bin/bash
echo "<=========================== Program by Nguyễn Anh Tuấn========================>"
# backup mongodb
#0 11 * * * bash $HOME/xxxxxxxxxxxxx.sh

DATE_STR=$(date '+%d-%b-%Y')
DATE_TIME_STR=$(date +"%d-%b-%YT%T")

# backup by collection
DB_HOST="billing-replset/billing-mongo1.local:27017"
DB_NAME="billing"
USERNAME="mongo-admin"
PASSWORD=""

COLLECTION_NAME[0]="MgEmployee"
COLLECTION_NAME[1]="MgLead"


mkdir -p $HOME/backup_mongodb/$DATE_STR/
for i in "${COLLECTION_NAME[@]}"
do     
    mongodump --host=$DB_HOST --username $USERNAME --password $PASSWORD --authenticationDatabase admin --collection=$i --db=$DB_NAME --out=$HOME/backup_mongodb/$DATE_STR/
done

echo "Backup dữ liệu mongodb "$DB_NAME" thành công: "$DATE_TIME_STR >> $HOME/backup_mongodb/log_backup.out
