#!/bin/bash
echo "<=========================== Program by Nguyễn Anh Tuấn========================>"
# backup mongodb
#0 11 * * * bash $HOME/xxxxxxxxxxxxx.sh
# mongodump --host foodbookmongo3.lan -d IPOS --port 27017 --username foodbook --password "" --collection=ORDER_TAG --gzip --out $HOME/backup_mongodb/

# SELECTCASE="backup_all"
SELECTCASE="backup_collections"

DATE_STR=$(date '+%d-%b-%Y')
DATE_TIME_STR=$(date +"%d-%b-%YT%T")

# backup by collection
DB_HOST="foodbookmongo3.lan:27017"
DB_NAME="IPOS"
USERNAME="foodbook"
PASSWORD=""


# declare -a LISTCOLLECTIONS=("BOOKING_ONLINE_LOG" "CACHE_PARTNER_FUNCTION_INFO" "CHARGE_HISTORY" "FBGEOPOINT" "LOG_MEMBERSHIP_TYPE_CHANGE" "MEMBERSHIP_LOG" "MEMBER_ADDRESS_LIST" "MGCC_ACCOUNT" "MGCC_ACCOUNT_POS_RELATE" "MGCC_POS_PARENT_CONFIG" "MG_BROADCAST" "MG_CALLBACK_EVENT_SUBSCRIBER" "MG_CALLCENTER_DAILY_BILLING" "MG_CHANGE_POS_STATUS_LOG" "MG_COMMISSION" "MG_COMPANY_MEMBERSHIP" "MG_CRM_CONFIG" "MG_EVENT" "MG_ITEM_CHANGED" "MG_LOG_CONFIG_CALLCENTER" "MG_LOYALTY_CONFIG" "MG_MEMBERSHIP" "MG_MEMBERSHIP_LOG" "MG_MEMBERSHIP_TYPE" "MG_MEMBERSHIP_TYPE_EXTRA_RATE" "MG_MEMBER_FILTER" "MG_MIN_AMOUNT_ORDER_RELATE" "MG_MONITOR" "MG_MONITOR_PUSH_DATA" "MG_MONITOR_SCHEDULE" "MG_O2O_CONFIG" "MG_O2O_FEEDBACK" "MG_ORDER_INDEX" "MG_PARTNER" "MG_PARTNER_CUSTOM_FIELD" "MG_PARTNER_VOUCHER_CAMPAIGN" "MG_PAYMENT_MERCHANT_CONFIG" "MG_PROMOTION" "MG_PUSH_NOTIFICATION_CONFIG" "MG_SYNC_ITEM_TYPE" "MG_SYSTEM_READY" "MG_TRIGGER_EVENT" "MG_TRIGGER_EVENT_HISTORY" "MG_USER_TAG" "NORMAL_COMBO" "ORDER_ONLINE_LOG" "ORDER_ONLINE_LOG_PAYMENT" "ORDER_ONLINE_LOG_PENDING" "ORDER_RATE" "ORDER_TAG" "SPECIAL_COMBO")
declare -a LISTCOLLECTIONS=("MG_USER_TAG" "SPECIAL_COMBO")

# ignore: MG_IP_RESTRICT MG_SALE_MANAGER MG_PARTNER_REQUEST MG_SYNC_ITEM MG_PARTNER_HUB_DAILY_REPORT LOG_PUSH_NOTIFY LOG_ERROR MG_CHANGE_ITEM_STATUS_LOG totals



mkdir -p $HOME/backup_mongodb/$DATE_STR/
if [ "$SELECTCASE" = "backup_collections" ];then
    for i in "${LISTCOLLECTIONS[@]}"
    do
    echo "$i"
    mongodump --host $DB_HOST -d $DB_NAME --port 27017 --username $USERNAME --password "$PASSWORD" --collection=$i --gzip --out $HOME/backup_mongodb/$DATE_STR/
    done
else
    echo "backup full databases"
    # mongodump --host $DB_HOST -d $DB_NAME --port 27017 --username $USERNAME --password "$PASSWORD" --gzip --out $HOME/backup_mongodb/$DATE_STR/
fi


echo "Backup dữ liệu mongodb "$DB_NAME" thành công: "$DATE_TIME_STR >> $HOME/backup_mongodb/log_backup.out
