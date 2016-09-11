###############################################################################
#                               Backup Tools                                  #
#                                                                             #
# https://github.com/vistoyn/backup_tools                                     #
# Copyright (c) 2016 Ildar Bikmamatov <vistoyn@gmail.com>                     #
# Licensed under the MIT License                                              #
# (https://github.com/vistoyn/backup_tools/blob/master/LICENSE)               #
#                                                                             #
###############################################################################

AMAZON_S3_BUCKET_NAME=""
AMAZON_S3_ACCESS_KEY_ID=""
AMAZON_S3_SECRET_ACCESS_KEY=""

sync_folder_exclude_amazon_s3 () {
	echo "$1/*" >> ${EXCLUDE_LIST}
	echo "exclude: $1 ">>${BACKUP_LOG}
	return 1
}

sync_folder_start_amazon_s3 () {
	if [ -z "$CURRENT_SRC_FOLDER" ]; then
		return 0
	fi

	if [ -z "$CURRENT_DEST_FOLDER" ]; then
		return 0
	fi

	CMD="s3cmd --acl-private --guess-mime-type --delete-removed --delete-after --no-encrypt --continue-put --recursive \
		--access_key=${AMAZON_S3_ACCESS_KEY_ID} --secret_key=${AMAZON_S3_SECRET_ACCESS_KEY} \
		--exclude-from=${EXCLUDE_LIST} --skip-existing \
		sync ${CURRENT_SRC_FOLDER}/ s3://${AMAZON_S3_BUCKET_NAME}${CURRENT_DEST_FOLDER}/ "
	
	#echo $CMD
	eval $CMD
	
	echo "[`date -R`] End dump folder $CURRENT_SRC_FOLDER ot $CURRENT_DEST_FOLDER ">>${BACKUP_LOG}
	return 1
}

push_folder_start_amazon_s3 () {
	if [ -z "$CURRENT_SRC_FOLDER" ]; then
		return 0
	fi

	if [ -z "$CURRENT_DEST_FOLDER" ]; then
		return 0
	fi

	CMD="s3cmd --acl-private --guess-mime-type --no-encrypt --continue-put --recursive \
		--access_key=${AMAZON_S3_ACCESS_KEY_ID} --secret_key=${AMAZON_S3_SECRET_ACCESS_KEY} \
		--exclude-from=${EXCLUDE_LIST} --skip-existing \
		sync ${CURRENT_SRC_FOLDER}/ s3://${AMAZON_S3_BUCKET_NAME}${CURRENT_DEST_FOLDER}/ "
	
	#echo $CMD
	eval $CMD
	
	echo "[`date -R`] End dump folder $CURRENT_SRC_FOLDER ot $CURRENT_DEST_FOLDER ">>${BACKUP_LOG}
	return 1
}

