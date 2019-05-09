function resume() {
    . $(readlink -f $(dirname $0))/functions/vars.sh
    . $(readlink -f $(dirname $0))/functions/common.sh

    RESUME_FILE="/tmp/$DOMAIN.ini"
    touch $RESUME_FILE
    echo "[$DOM_PRINCIPAL]" >> $RESUME_FILE
    echo "CLIENT_NAME=${CLIENT_NAME}" >> $RESUME_FILE
    echo "DOMAIN=${DOMAIN}" >> $RESUME_FILE
    echo "CLIENT_HOME=${CLIENT_HOME}" >> $RESUME_FILE
    echo "CLIENT_DIR=${CLIENT_DIR}" >> $RESUME_FILE
    echo "LOGROTATE_FILE=${LOGROTATE_FILE}" >> $RESUME_FILE
    echo "SECRET_FILE=${SECRET_FILE}" >> $RESUME_FILE
    echo "PRINCIPAL_DOMAIN=${DOM_PRINCIPAL}" >> $RESUME_FILE
    echo "ALIAS_DOMAINS=${DOM_REDIRECT}" >> $RESUME_FILE
    echo "VHOST_MOD=${VHOST_MOD}" >> $RESUME_FILE
    echo "NGINX_REWRITE_FILE=${NGINX_REWRITE_FILE}" >> $RESUME_FILE
    echo "VHOST_FILE=${HTTPCLIENTFILE}" >> $RESUME_FILE
    echo "VHOST_TEMPLATE=${VHOST_TEMPLATE}" >> $RESUME_FILE
    echo "PHP_VERSION=${VERSION_PHP}" >> $RESUME_FILE
    echo "PHP_POOL_FILE=${PHPCLIENTFILE}" >> $RESUME_FILE
    case $USE_SSL in
        "on")
            echo "LE_DOMAIN_LIST=${LE_DOMAIN_LIST}" >> $RESUME_FILE
            echo "CERTBOT_CHALLENGE_TYPE=${CERTBOT_CHALLENGE_TYPE}" >> $RESUME_FILE
            echo "CERTBOT_CHALLENGE_DNS_PLUGIN=${CERTBOT_CHALLENGE_DNS_PLUGIN}" >> $RESUME_FILE
            ;;
        "off")
            ;;
        *)
            ;;
    esac
    case $DATABASE_OPT in
        "Yes")
            echo "DB_NAME=${DB_NAME}" >> $RESUME_FILE
            echo "DB_USER=${DB_USER}" >> $RESUME_FILE
            echo "DB_PASSWORD=${DB_PASSWD}" >> $RESUME_FILE
            ;;
        *)
            ;;
    esac
    echo "FTP_USERNAME=${FTP_USERNAME}" >> $RESUME_FILE
    echo "FTP_PASSWORD=${FTP_PASSWORD}" >> $RESUME_FILE
    echo "FTP_ROOT=${FTP_ROOT}" >> $RESUME_FILE
    echo "FTP_DOMAIN=ftp.${DOMAIN}" >> $RESUME_FILE
    case $WORDPRESS_OPT in
        "Yes")
            echo "WP_SITENAME=${WP_SITENAME}" >> $RESUME_FILE
            echo "WP_URL=${WP_URL}" >> $RESUME_FILE
            echo "WP_PATH=${WP_PATH}" >> $RESUME_FILE
            echo "WP_ADMIN_USER=${WP_ADMIN_USER}" >> $RESUME_FILE
            echo "WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL}" >> $RESUME_FILE
            echo "WP_ADMIN_PASSWORD=${WP_ADMIN_PASSWORD}" >> $RESUME_FILE
            echo "WP_INSTALL_PLUGINS=${WP_INSTALL_PLUGINS}" >> $RESUME_FILE
            ;;
        *)
            ;;
    esac
    case $WP_SECOND_USER in
        "Yes")
            echo "WP_SECOND_USERNAME=$WP_SECOND_USERNAME" >> $RESUME_FILE
            echo "WP_SECOND_EMAIL=$WP_SECOND_EMAIL" >> $RESUME_FILE
            echo "WP_SECOND_FIRSTNAME=$WP_SECOND_FIRSTNAME" >> $RESUME_FILE
            echo "WP_SECOND_LASTNAME=$WP_SECOND_LASTNAME" >> $RESUME_FILE
            echo "WP_SECOND_PASSWORD=$WP_SECOND_PASSWORD" >> $RESUME_FILE
            ;;
        *)
            ;;
    esac
    cat $RESUME_FILE

    echo ""
    echo ""

    read -n 1 -s -r -p "Press any key to continue"

    install
}