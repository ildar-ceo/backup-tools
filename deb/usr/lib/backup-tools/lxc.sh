###############################################################################
#                               Backup Tools                                  #
#                                                                             #
# https://github.com/vistoyn/backup-tools                                     #
# Copyright (c) 2016 Ildar Bikmamatov <vistoyn@gmail.com>                     #
# Licensed under the MIT License                                              #
# (https://github.com/vistoyn/backup-tools/blob/master/LICENSE)               #
#                                                                             #
###############################################################################

dump_lxc () {
	LXC_NAME="$1"
	DATE=`date -I`
	DATE2=`date "+%Y-%m"`
	LXC_PATH="/var/lib/lxc/$LXC_NAME"
	LXC_SNAPSHOT="snap-$LXC_NAME-$DATE"
	LXC_BACKUP="$BACKUP_DIR_LXC/$LXC_NAME/$DATE2"
	
	if [ -z "$LXC_NAME" ]; then
		return 0
	fi
	
	if [ ! -d $LXC_PATH ]; then
		return 0
	fi
	
	get_backup_log_var
	
	echo -e "Backup containter to ${c_Green}'$LXC_BACKUP/$LXC_SNAPSHOT.tar.gz'${c_NC} "
	mkdir -p $LXC_BACKUP
	
	pushd /var/lib/lxc/$LXC_NAME > /dev/null
	
	CMD="tar --exclude='rootfs/dev/*' \
			--exclude='rootfs/proc/*' \
			--exclude='rootfs/sys/*' \
			--exclude='rootfs/tmp/*' "

	if [ -f "./exclude.list" ]; then
		CMD="$CMD --exclude-from='./exclude.list' "
	fi
	
	echo "[`date -R`] Start backup " > $LXC_BACKUP/$LXC_SNAPSHOT.log
	echo "[`date -R`] Start backup lxc container $LXC_NAME " >> $BACKUP_LOG 2>&1
	
	CMD="$CMD -czvf $LXC_BACKUP/$LXC_SNAPSHOT.tar.gz * >> $LXC_BACKUP/$LXC_SNAPSHOT.log 2>&1"
	
	#echo $CMD 
	eval $CMD

	pushd $LXC_BACKUP > /dev/null
	gzip -f $LXC_SNAPSHOT.log
	
	echo "[`date -R`] End backup lxc container $LXC_NAME " >> $BACKUP_LOG 2>&1
	
	popd > /dev/null
	
	return 1
}
