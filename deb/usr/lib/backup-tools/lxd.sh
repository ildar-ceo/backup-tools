###############################################################################
#                               Backup Tools                                  #
#                                                                             #
# https://github.com/vistoyn/backup-tools                                     #
# Copyright (c) 2016 Ildar Bikmamatov <vistoyn@gmail.com>                     #
# Licensed under the MIT License                                              #
# (https://github.com/vistoyn/backup-tools/blob/master/LICENSE)               #
#                                                                             #
###############################################################################

lxd_check_snapshot (){
	LXD_NAME="$1"
	LXD_SNAPSHOT_MASTER="$2"
	
	if [ -z "$LXD_NAME" ]; then
		return 0
	fi
	
	if [ -z "$LXD_SNAPSHOT_MASTER" ]; then
		return 0
	fi
	
	CMD="zfs list -t all | awk '{print \$1}' | \
			grep  "^${LXD_ZPOOL_NAME}/containers/${LXD_NAME}@${LXD_SNAPSHOT_MASTER}\$" | wc -l"
	
	eval $CMD
}

dump_lxd () {
	LXD_NAME="$1"
	DATE=`date -I`
	DATE2=`date "+%Y-%m"`
	LXD_PATH="/var/lib/lxd/containers/$LXD_NAME"
	LXD_SNAPSHOT="snap-$LXD_NAME-$DATE"
	LXD_BACKUP="$BACKUP_DIR_LXD/$LXD_NAME/$DATE2"
	
	if [ -z "$LXD_NAME" ]; then
		return 0
	fi
	
	if [ ! -d $LXD_PATH ]; then
		return 0
	fi
	
	get_backup_log_var
	
	echo -e "Backup containter to ${c_Green}'$LXD_BACKUP/$LXD_SNAPSHOT.tar.gz'${c_NC} "
	mkdir -p $LXD_BACKUP
	
	pushd /var/lib/lxd/containers/$LXD_NAME > /dev/null
	lxc config show $LXD_NAME > ./config
	
	CMD="tar --exclude='rootfs/dev/*' \
			--exclude='rootfs/proc/*' \
			--exclude='rootfs/sys/*' \
			--exclude='rootfs/tmp/*' "

	if [ -f "./exclude.list" ]; then
		CMD="$CMD --exclude-from='./exclude.list' "
	fi
	
	echo "[`date -R`] Start backup " > $LXD_BACKUP/$LXD_SNAPSHOT.log
	echo "[`date -R`] Start backup lxd container $LXD_NAME " >> $BACKUP_LOG 2>&1
	
	CMD="$CMD -czvf $LXD_BACKUP/$LXD_SNAPSHOT.tar.gz * >> $LXD_BACKUP/$LXD_SNAPSHOT.log 2>&1"
	
	#echo $CMD 
	eval $CMD

	pushd $LXD_BACKUP > /dev/null
	gzip -f $LXD_SNAPSHOT.log
	
	echo "[`date -R`] End backup lxd container $LXD_NAME " >> $BACKUP_LOG 2>&1
	
	popd > /dev/null
	
	return 1
}

dump_lxd_master () {
	LXD_NAME="$1"
	DATE2=`date "+%Y-%m"`
	LXD_PATH="/var/lib/lxd/containers/$LXD_NAME"
	LXD_BACKUP="$BACKUP_DIR_LXD/$LXD_NAME/$DATE2"
	SNAPSHOT_NAME=`date -u "+%Y-%m-%dT%H:%M:%S%Z"`
	LXD_SNAPSHOT="snap-$LXD_NAME-$SNAPSHOT_NAME-master"
	
	if [ -z "$LXD_NAME" ]; then
		return 0
	fi
	
	if [ ! -d $LXD_PATH ]; then
		return 0
	fi
	
	get_backup_log_var
	
	
	echo -e "Backup containter to ${c_Green}'$LXD_BACKUP/$LXD_SNAPSHOT.gz'${c_NC} "
	mkdir -p $LXD_BACKUP
	
	zfs snapshot ${LXD_ZPOOL_NAME}/containers/${LXD_NAME}@${LXD_SNAPSHOT}
	zfs send ${LXD_ZPOOL_NAME}/containers/${LXD_NAME}@${LXD_SNAPSHOT} | gzip > $LXD_BACKUP/$LXD_SNAPSHOT.gz
	
	
	return 1
}

dump_lxd_increment () {
	LXD_NAME="$1"
	LXD_SNAPSHOT_MASTER="$2"
	DATE2=`date "+%Y-%m"`
	LXD_PATH="/var/lib/lxd/containers/$LXD_NAME"
	LXD_BACKUP="$BACKUP_DIR_LXD/$LXD_NAME/$DATE2"
	SNAPSHOT_NAME=`date -u "+%Y-%m-%dT%H:%M:%S%Z"`
	LXD_SNAPSHOT="$LXD_SNAPSHOT_MASTER-increment-$SNAPSHOT_NAME"
	
	if [ -z "$LXD_NAME" ]; then
		return 0
	fi
	
	if [ -z "$LXD_SNAPSHOT_MASTER" ]; then
		return 0
	fi
	
	FOUND=`lxd_check_snapshot $LXD_NAME $LXD_SNAPSHOT_MASTER`
	if [ $FOUND != "1" ]; then
		return 0
	fi
	
	if [ ! -d $LXD_PATH ]; then
		return 0
	fi
	
	get_backup_log_var
	
	
	echo -e "Backup containter to ${c_Green}'$LXD_BACKUP/$LXD_SNAPSHOT.gz'${c_NC} "
	mkdir -p $LXD_BACKUP
	
	zfs snapshot ${LXD_ZPOOL_NAME}/containers/${LXD_NAME}@${LXD_SNAPSHOT}
	zfs send -i ${LXD_ZPOOL_NAME}/containers/${LXD_NAME}@${LXD_SNAPSHOT_MASTER} ${LXD_ZPOOL_NAME}/containers/${LXD_NAME}@${LXD_SNAPSHOT} | gzip > $LXD_BACKUP/$LXD_SNAPSHOT.gz
	
	zfs destroy ${LXD_ZPOOL_NAME}/containers/${LXD_NAME}@${LXD_SNAPSHOT}
	
	
	return 1
}


import_lxd_master () {
	LXD_NAME="$1"
	LXD_SNAPSHOT_FILE_NAME="$2"
	
	if [ -z "$LXD_NAME" ]; then
		return 0
	fi
	
	if [ -z "$LXD_SNAPSHOT_FILE_NAME" ]; then
		return 0
	fi
	
	LXD_SNAPSHOT=$(echo `basename $LXD_SNAPSHOT_FILE_NAME` | cut -f 1 -d '.')
	echo $LXD_SNAPSHOT
	
	echo "Destroy container ${LXD_NAME}"
	zfs destroy -r ${LXD_ZPOOL_NAME}/containers/${LXD_NAME}
	
	echo -e "Import master snapshot ${c_Green}'$LXD_SNAPSHOT'${c_NC} to ${c_Yellow}'${LXD_NAME}'${c_NC} "
	CMD="gunzip -c $LXD_SNAPSHOT_FILE_NAME | zfs receive  ${LXD_ZPOOL_NAME}/containers/${LXD_NAME}@${LXD_SNAPSHOT}"
	
	#echo $CMD
	eval $CMD
	
	echo "Set mount point ${LXD_NAME} to /var/lib/lxd/containers/${LXD_NAME}.zfs"
	zfs set mountpoint=/var/lib/lxd/containers/${LXD_NAME}.zfs ${LXD_ZPOOL_NAME}/containers/${LXD_NAME}
	
	
	return 1
}


import_lxd_increment () {
	LXD_NAME="$1"
	LXD_SNAPSHOT_FILE_NAME="$2"
	
	if [ -z "$LXD_NAME" ]; then
		return 0
	fi
	
	if [ -z "$LXD_SNAPSHOT_FILE_NAME" ]; then
		return 0
	fi
	
	LXD_SNAPSHOT=$(echo `basename $LXD_SNAPSHOT_FILE_NAME` | cut -f 1 -d '.')
	echo $LXD_SNAPSHOT
	
	
	echo -e "Import increment snapshot ${c_Green}'$LXD_SNAPSHOT'${c_NC} to ${c_Yellow}'${LXD_NAME}'${c_NC} "
	CMD="gunzip -c $LXD_SNAPSHOT_FILE_NAME | zfs receive -F ${LXD_ZPOOL_NAME}/containers/${LXD_NAME}@${LXD_SNAPSHOT}"
	
	#echo $CMD
	eval $CMD
	
	return 1
}
