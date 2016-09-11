###############################################################################
#                               Backup Tools                                  #
#                                                                             #
# https://github.com/vistoyn/backup_tools                                     #
# Copyright (c) 2016 Ildar Bikmamatov <vistoyn@gmail.com>                     #
# Licensed under the MIT License                                              #
# (https://github.com/vistoyn/backup_tools/blob/master/LICENSE)               #
#                                                                             #
###############################################################################


sync_folder_exclude_rsync () {
	echo "$1/*" >> ${EXCLUDE_LIST}
	echo "exclude: $1 ">>${BACKUP_LOG}
	return 1
}

sync_folder_start_rsync () {
	if [ -z "$CURRENT_SRC_FOLDER" ]; then
		return 0
	fi

	if [ -z "$CURRENT_DEST_FOLDER" ]; then
		return 0
	fi
	
	echo "Start rsync"
	echo "[`date -R`] Start rsync folder $CURRENT_SRC_FOLDER ot $CURRENT_DEST_FOLDER ">>${BACKUP_LOG}
	
	CMD="rsync -azh --progress --delete-after --force $CURRENT_SRC_FOLDER  $CURRENT_DEST_FOLDER"
	echo $CMD >> ${BACKUP_LOG}
	#echo $CMD
	
	eval $CMD
	
	echo "[`date -R`] End   rsync folder $CURRENT_SRC_FOLDER ot $CURRENT_DEST_FOLDER ">>${BACKUP_LOG}
	return 1
}

push_folder_start_rsync () {
	if [ -z "$CURRENT_SRC_FOLDER" ]; then
		return 0
	fi

	if [ -z "$CURRENT_DEST_FOLDER" ]; then
		return 0
	fi
	
	echo "Start rsync"
	echo "[`date -R`] Start rsync folder $CURRENT_SRC_FOLDER ot $CURRENT_DEST_FOLDER ">>${BACKUP_LOG}
	
	CMD="rsync -azh --progress --force $CURRENT_SRC_FOLDER  $CURRENT_DEST_FOLDER"
	echo $CMD >> ${BACKUP_LOG}
	#echo $CMD
	
	eval $CMD
	
	echo "[`date -R`] End   rsync folder $CURRENT_SRC_FOLDER ot $CURRENT_DEST_FOLDER ">>${BACKUP_LOG}
	return 1
}

