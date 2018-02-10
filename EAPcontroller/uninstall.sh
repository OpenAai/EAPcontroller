#!/bin/bash

ROOT_UID=0

DEST_DIR=/opt/tplink
DEST_FOLDER=EAPController
INSTALLDIR=${DEST_DIR}/${DEST_FOLDER}
#INSTALLDIR=$(dirname $(readlink -f $0))
LINK=/etc/init.d/tpeap
LINK_CMD=/usr/bin/tpeap

user_confirm() {
    while true
    do
        echo -n "EAP Controller will be uninstalled from [${INSTALLDIR}] (y/n): "
        read input
        confirm=`echo $input | tr '[a-z]' '[A-Z]'`

        if [[ $confirm = "Y" || $confirm = "YES" ]]; then
	    return 0
        elif [[ $confirm = "N" || $confirm = "NO" ]]; then
	    return 1
        fi
    done
}


user_keep_db() {
    while true
    do
        echo -n "Do you want to backup database [${INSTALLDIR}/data/db] (y/n): "
        read input
        confirm=`echo $input | tr '[a-z]' '[A-Z]'`

        if [[ $confirm = "Y" || $confirm = "YES" ]]; then
	    return 0
        elif [[ $confirm = "N" || $confirm = "NO" ]]; then
	    return 1
        fi
    done
}

# return: 0, exist; 1, not exist;
link_exist() {
	if test -x $1; then
		if [ ${INSTALLDIR}/bin/control.sh = $(readlink -f $1) ]; then
			return 0
		fi
	fi

	return 1
}

# return: 0,running; 1, not running;
is_running() {
    ps -U root -u root u | grep "com.tp_link.eap.start.EapMain" | grep -v grep >/dev/null
    eap_running=$?
    if [ $eap_running -ne 0 ]; then
	    return 1
    fi

    #ps -U root -u root u | grep mongod |grep -v grep >/dev/null
    #mongod_running=$?
    #if [ $mongod_running -ne 0 ]; then
	#    return 1
    #fi

    return 0
}

# root permission check
if [ $UID != ${ROOT_UID} ]
then
   echo "The script need root permission. Exit."
   exit
fi

# user confirm
if ! user_confirm; then
    exit
fi



NEED_KEEP_DB=0

if ! user_keep_db; then
    NEED_KEEP_DB=0
else 
    NEED_KEEP_DB=1
fi

echo "========================"
echo "Uninstallation start ..."


link_exist ${LINK}
exist=$?
count=0
while [ $exist -eq 1 ]
do
    count=`expr ${count} + 1`
    link_exist ${LINK}${count}
    exist=$?
    if [ $count -gt 100 ]; then
		# not found LINK
		break;
    fi
done

while is_running
do
    if [ -x ${INSTALLDIR}/bin/control.sh ]; then
        ${INSTALLDIR}/bin/control.sh stop
    else
	    echo "Can't stop EAP Controller! You should stop it by yourself before uninstall."
	    exit
    fi

    sleep 3
done

# removing
if [ $count -eq 0 ]; then
    link_name=${LINK}
    link_cmd_name=${LINK_CMD}
else
    link_name=${LINK}${count}
    link_cmd_name=${LINK_CMD}${count}
fi

update-rc.d $(basename ${link_name}) remove 2>/dev/null
result=$?
if [ $result -ne 0 ]; then
    chkconfig --del ${link_name}
    chkconfig --del ${link_cmd_name}
fi

rm ${link_name}
rm ${link_cmd_name}




BACKUP_FOLDER=${INSTALLDIR}/../eap_db_backup
DB_FILE_NAME=eap.db.tar.gz
MAP_FILE_NAME=eap.map.tar.gz

if [ $NEED_KEEP_DB == 1 ]; then
    mkdir $BACKUP_FOLDER > /dev/null 2>&1 
    cd ${INSTALLDIR}/data
    tar zcvf $DB_FILE_NAME db
    cp -f $DB_FILE_NAME $BACKUP_FOLDER/
    
    #backup map，solve Bug 189651
    tar zcvf $MAP_FILE_NAME map
    cp -f $MAP_FILE_NAME $BACKUP_FOLDER/
fi




rm -rf ${INSTALLDIR}

echo "Uninstall successfully."

