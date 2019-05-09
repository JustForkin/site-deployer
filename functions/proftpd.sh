function ftpasswd() {
    source $(readlink -f $(dirname $0))/functions/vars.sh

    export FTP_PASSWORDHASH=$(mkpasswd --hash=md5 -s "$2")
    export UID_CLIENT=$(id -u ${CLIENT_NAME})
    echo "$1:$FTP_PASSWORDHASH:$UID_CLIENT:33::$3:/bin/sh" >> ${PROFTPD_PASSWD_FILE}
    echo "ftpuser=$1" >> ${SECRET_FILE}
    echo "ftproot=$3" >> ${SECRET_FILE}
    echo "ftppassword=$2" >> ${SECRET_FILE}
    echo -e "   -> FTP account for $1 ${GREEN}successfully created${CLASSIC}"
}