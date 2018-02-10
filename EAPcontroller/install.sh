#!/bin/bash

ROOT_UID=0

DEST_DIR=/opt/tplink
DEST_FOLDER=EAPController
INSTALLDIR=${DEST_DIR}/${DEST_FOLDER}
LINK=/etc/init.d/tpeap
LINK_CMD=/usr/bin/tpeap

BACKUP_FOLDER=${INSTALLDIR}/../eap_db_backup
DB_FILE_NAME=eap.db.tar.gz
MAP_FILE_NAME=eap.map.tar.gz

# user confirm
user_confirm() {
    while true
    do
        echo -n "EAP Controller will be installed in [${INSTALLDIR}] (y/n): "
        read input
        confirm=`echo $input | tr '[a-z]' '[A-Z]'`

        if [[ $confirm = "Y" || $confirm = "YES" ]]; then
	    return 0
        elif [[ $confirm = "N" || $confirm = "NO" ]]; then
	    return 1
        fi
    done
}


need_import_mongo_db() {
    while true
    do
        echo -n "EAP Controller detects that you have exported database before, will you import it (y/n): "
        read input
        confirm=`echo $input | tr '[a-z]' '[A-Z]'`

        if [[ $confirm = "Y" || $confirm = "YES" ]]; then
	    return 0
        elif [[ $confirm = "N" || $confirm = "NO" ]]; then
	    return 1
        fi
    done
}


# user confirm
import_mongo_db() {
    if test -f ${BACKUP_FOLDER}/${DB_FILE_NAME}; then
		need_import_mongo_db
        if [ 0 = $? ]; then
            cd  ${BACKUP_FOLDER}
            tar zxvf ${DB_FILE_NAME} -C ${INSTALLDIR}/data/

            #import map pictures
            if test -f ${BACKUP_FOLDER}/${MAP_FILE_NAME}; then
                tar zxvf ${MAP_FILE_NAME} -C ${INSTALLDIR}/data/
            fi
        fi
    fi
}

# return: 0, exist; 1, not exist;
dir_exist() {
    if test -d ${INSTALLDIR}
    then
        dircontent=`ls ${INSTALLDIR}`
        if [ -z "$dircontent" ]; then
	        return 0
        fi

        if test -x ${INSTALLDIR}/uninstall.sh
        then
	      echo "EAP Controller is already installed. Please uninstall it first."
            echo "You can use ${INSTALLDIR}/uninstall.sh"
            exit
        else
	        echo "${INSTALLDIR} is already existed. Please delete it first."
	        exit
        fi
    fi

    return 1
}

# return: 0, 64 bit; 1, 32 bit;
is64bit() {
    if [ $(getconf WORD_BIT) = '32' ] && [ $(getconf LONG_BIT) = '64' ]
    then        
	    return 0
    else        
        return 1
    fi
}

# return: 0, exist; 1, not exist;
link_exist() {

if test -x $1; then
    if [ ${INSTALLDIR}/bin/control.sh = $(readlink -f $1) ]; then
	  rm $1 -v
        return 1
    else
        return 0
    fi
else
    return 1
fi
}


# root permission check
if [ $UID != ${ROOT_UID} ]
then
    echo "The script need root permission. Exit."
    exit
fi

if ! user_confirm ; then
    exit
fi

echo "========================"
echo "Installation start ..."

# install directory check
if ! dir_exist; then
    mkdir ${INSTALLDIR} -vp > /dev/null
fi


# copy files


for name in bin data properties json xml webapps keystore lib  install.sh uninstall.sh
do    
    cp ${name} ${INSTALLDIR} -r
done

if is64bit; then
    cp jre ${INSTALLDIR}/jre -r
else
    cp jre ${INSTALLDIR}/jre -r
fi

if [ ! -d ${INSTALLDIR}/logs ]; then    
    mkdir ${INSTALLDIR}/logs -v >/dev/null 2>&1  
fi

# config application
link_exist ${LINK}
exist=$?
count=0

while [ $exist -eq 0 ]
do
    count=`expr ${count} + 1`
    link_exist ${LINK}${count}
    exist=$?
done

if [ $count -gt 0 ]; then
    link_name=${LINK}${count}
    link_cmd_name=${LINK_CMD}${count}
    
else
    link_name=${LINK}
    link_cmd_name=${LINK_CMD}
fi



ln -s ${INSTALLDIR}/bin/control.sh ${link_name}
ln -s ${INSTALLDIR}/bin/control.sh ${link_cmd_name}


# chmod 755
chmod 755 ${INSTALLDIR}/bin/*
chmod 755 ${INSTALLDIR}/jre/bin/*

if test -x ${link_name}; then
    update-rc.d $(basename ${link_name}) defaults 95 2>/dev/null
    result=$?
    if [ $result -ne 0 ]; then
	    chkconfig --add ${link_name}
        chkconfig --add ${link_cmd_name}        
#       echo "add service with chkconfig"
    fi
    
    echo "Install succeeded!"
    echo "========================"
    
    import_mongo_db
    
    echo "EAP Controller will start up with system boot. You can also control it by [${link_cmd_name}]. "

    ${link_name} start
    
    echo "========================"
    exit
fi

echo "Install failed!"
echo "Roll back ... "
rm -r ${INSTALLDIR}


