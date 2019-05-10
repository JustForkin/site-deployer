#!/bin/bash
MY_SCRIPT=$(readlink -f $0)
MY_SCRIPT_PATH=`dirname $MY_SCRIPT`
export MY_SCRIPT_PATH

function dbcreate() {
    source ${MY_SCRIPT_PATH}/functions/vars.sh

    cp ${DBSCRIPTSRC} ${DBSCRIPTDEST}
    sed -i "s/{DBNAME}/$1/g" ${DBSCRIPTDEST}
    sed -i "s/{DBUSR}/$2/g" ${DBSCRIPTDEST} 
    sed -i "s/{DBPASSWD}/$3/g" ${DBSCRIPTDEST}
    mysql < ${DBSCRIPTDEST}
    echo "dbname=$1" >> ${SECRET_FILE}
    echo "dbuser=$2" >> ${SECRET_FILE}
    echo "dbpassword=$3" >> ${SECRET_FILE}
}