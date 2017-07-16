###############################################################################
#                               Backup Tools                                  #
#                                                                             #
# https://github.com/vistoyn/backup-tools                                     #
# Copyright (c) 2016 Ildar Bikmamatov <vistoyn@gmail.com>                     #
# Licensed under the MIT License                                              #
# (https://github.com/vistoyn/backup-tools/blob/master/LICENSE)               #
#                                                                             #
###############################################################################


sync_folder_exclude_amazon_s3 () {
	get_backup_log_var
	echo "$1/*" >> ${EXCLUDE_LIST}
	echo "exclude: $1 ">>${BACKUP_LOG}
	return 1
}

sync_folder_start_amazon_s3 () {
	params=""
	
	if [ -z "$CURRENT_SRC_FOLDER" ]; then
		return 0
	fi

	if [ -z "$CURRENT_DEST_FOLDER" ]; then
		return 0
	fi
	
	if [ -z "$AMAZON_S3_BUCKET_NAME" ]; then
		return 0
	fi
	
	
	if [ "$AMAZON_NO_CHECK_MD5" == "1" ]; then
		params="${params} --no-check-md5"
	fi
	
	if [ "$VERBOSE" == "1" ]; then
		params="${params} --verbose --progress"
	fi
	
	get_backup_log_var
	
	if [ ! -z "$AMAZON_S3_ACCESS_KEY_ID" ] && [ ! -z "$AMAZON_S3_SECRET_ACCESS_KEY" ]; then
	
		CMD="s3cmd --acl-private --no-guess-mime-type --delete-removed --delete-after --no-encrypt --continue-put  \
			--access_key=${AMAZON_S3_ACCESS_KEY_ID} --secret_key=${AMAZON_S3_SECRET_ACCESS_KEY} \
			--exclude-from=${EXCLUDE_LIST} --skip-existing --recursive --force ${params} \
			sync ${CURRENT_SRC_FOLDER}/ s3://${AMAZON_S3_BUCKET_NAME}${CURRENT_DEST_FOLDER}/ "
		
	else
	
		CMD="s3cmd --acl-private --no-guess-mime-type --delete-removed --delete-after --no-encrypt --continue-put  \
			--exclude-from=${EXCLUDE_LIST} --skip-existing --recursive --force ${params} \
			sync ${CURRENT_SRC_FOLDER}/ s3://${AMAZON_S3_BUCKET_NAME}${CURRENT_DEST_FOLDER}/ "
		
	fi
	
	echo "Start sync folder $CURRENT_SRC_FOLDER to Amazon s3://${AMAZON_S3_BUCKET_NAME}${CURRENT_DEST_FOLDER}"
	echo "[`date -R`] Start sync folder $CURRENT_SRC_FOLDER to s3://${AMAZON_S3_BUCKET_NAME}${CURRENT_DEST_FOLDER} " >> $BACKUP_LOG
	
	if [ "$VERBOSE" == "1" ]; then
		echo $CMD
	fi
	
	eval $CMD >> ${BACKUP_LOG} 2>&1
	
	echo "[`date -R`] End   sync folder $CURRENT_SRC_FOLDER to s3://${AMAZON_S3_BUCKET_NAME}${CURRENT_DEST_FOLDER} ">>${BACKUP_LOG}
	return 1
}

push_folder_start_amazon_s3 () {
	params=""
	
	if [ -z "$CURRENT_SRC_FOLDER" ]; then
		return 0
	fi

	if [ -z "$CURRENT_DEST_FOLDER" ]; then
		return 0
	fi
	
	if [ -z "$AMAZON_S3_BUCKET_NAME" ]; then
		return 0
	fi
	
	if [ "$AMAZON_NO_CHECK_MD5" == "1" ]; then
		params="${params} --no-check-md5"
	fi
	
	if [ "$VERBOSE" == "1" ]; then
		params="${params} --verbose --progress"
	fi
	
	get_backup_log_var
	
	if [ ! -z "$AMAZON_S3_ACCESS_KEY_ID" ] && [ ! -z "$AMAZON_S3_SECRET_ACCESS_KEY" ]; then
		CMD="s3cmd --acl-private --guess-mime-type --no-encrypt --continue-put  \
			--access_key=${AMAZON_S3_ACCESS_KEY_ID} --secret_key=${AMAZON_S3_SECRET_ACCESS_KEY} \
			--exclude-from=${EXCLUDE_LIST} --skip-existing --recursive ${params} \
			sync ${CURRENT_SRC_FOLDER}/ s3://${AMAZON_S3_BUCKET_NAME}${CURRENT_DEST_FOLDER}/ "
	else
		CMD="s3cmd --acl-private --guess-mime-type --no-encrypt --continue-put  \
			--exclude-from=${EXCLUDE_LIST} --skip-existing --recursive ${params} \
			sync ${CURRENT_SRC_FOLDER}/ s3://${AMAZON_S3_BUCKET_NAME}${CURRENT_DEST_FOLDER}/ "
	fi
	
	echo "Start push folder $CURRENT_SRC_FOLDER to Amazon s3://${AMAZON_S3_BUCKET_NAME}${CURRENT_DEST_FOLDER}"
	echo "[`date -R`] Start push folder $CURRENT_SRC_FOLDER to s3://${AMAZON_S3_BUCKET_NAME}${CURRENT_DEST_FOLDER} " >> $BACKUP_LOG
	
	if [ "$VERBOSE" == "1" ]; then
		echo $CMD
	fi
	
	eval $CMD >> ${BACKUP_LOG} 2>&1
	
	echo "[`date -R`] End   push folder $CURRENT_SRC_FOLDER to s3://${AMAZON_S3_BUCKET_NAME}${CURRENT_DEST_FOLDER} ">>${BACKUP_LOG} 
	return 1
}
