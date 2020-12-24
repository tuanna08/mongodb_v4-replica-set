#!/bin/bash
echo "<=========================== Program by Nguyễn Anh Tuấn========================>"
# backup mongodb
#0 11 * * * bash $HOME/xxxxxxxxxxxxx.sh

# SELECTCASE="restore_all"
SELECTCASE="restore_collections"

DATE_STR=$(date '+%d-%b-%Y')  #24-Dec-2020
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

if [ "$SELECTCASE" = "restore_collections" ];then
    for i in "${COLLECTION_NAME[@]}"
    do     
        mongorestore --db=$DB_NAME --port 27017 --collection=$i $HOME/backup_mongodb/$DATE_STR/$DB_NAME/$i.bson.gz --db=$DB_NAME --gzip --drop
    done
else
        mongorestore --port 27017 --db=$DB_NAME $HOME/backup_mongodb/$DATE_STR/$DB_NAME --gzip --drop

fi


echo "Backup dữ liệu mongodb "$DB_NAME" thành công: "$DATE_TIME_STR >> $HOME/backup_mongodb/log_backup.out
