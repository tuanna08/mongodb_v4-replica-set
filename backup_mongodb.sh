#!/bin/bash
echo "<=========================== Program by Nguyễn Anh Tuấn========================>"
# backup mongodb
#0 11 * * * bash $HOME/xxxxxxxxxxxxx.sh

# SELECTCASE="backup_all"
SELECTCASE="backup_collections"

DATE_STR=$(date '+%d-%b-%Y')
DATE_TIME_STR=$(date +"%d-%b-%YT%T")

# backup by collection
DB_HOST="billing-replset/billing-mongo1.local:27017"
DB_NAME="billing"
USERNAME="mongo-admin"
PASSWORD=""

COLLECTION_NAME[0]="MgEmployee"
COLLECTION_NAME[1]="MgLead"

# printf "Select case: \n(1): backup by collections.\n(2): backup all db.\n"
# echo -n "Enter number:"
# read selectcase
mkdir -p $HOME/backup_mongodb/$DATE_STR/
if [ "$SELECTCASE" = "backup_collections" ];then
    for i in "${COLLECTION_NAME[@]}"
    do     
        mongodump --host=$DB_HOST --username $USERNAME --password $PASSWORD --authenticationDatabase admin --collection=$i --db=$DB_NAME --gzip --out=$HOME/backup_mongodb/$DATE_STR/
    done
else
    mongodump --host=$DB_HOST --username $USERNAME --password $PASSWORD --authenticationDatabase admin  --db=$DB_NAME --gzip --out=$HOME/backup_mongodb/$DATE_STR/
fi


echo "Backup dữ liệu mongodb "$DB_NAME" thành công: "$DATE_TIME_STR >> $HOME/backup_mongodb/log_backup.out
