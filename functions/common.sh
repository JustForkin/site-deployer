#!/bin/bash

function newDeploy() {
    source ${MY_SCRIPT_PATH}/functions/resume.sh
    source ${MY_SCRIPT_PATH}/functions/vars.sh
    source ${MY_SCRIPT_PATH}/functions/cloudflare.sh

    export CLIENT_NAME=$(whiptail --title "Client name" --inputbox "Client name, will be used for client folder" 10 60 3>&1 1>&2 2>&3)
    export DOMAIN=$(whiptail --title "Domain" --inputbox "First level domain name" 10 60 3>&1 1>&2 2>&3)

    if (whiptail --title "WWW" --yesno "Do you want to use WWW as main servername ?" 10 60) then
        export DOM_PRINCIPAL="www.$DOMAIN"
    else
        SUB_DOMAIN=$(whiptail --title "Subdomain" --inputbox "Do you want use a subdomain - Ex : preprod, dev... (leave empty if not)?" 10 60 3>&1 1>&2 2>&3)
        NO_MAIN_WWW=true
        if [[ -z $SUB_DOMAIN ]]; then
            export DOM_PRINCIPAL="$DOMAIN"
        else
            export DOM_PRINCIPAL="$SUB_DOMAIN.$DOMAIN"
        fi
    fi

    if (whiptail --title "ServerAlias" --yesno "Do you want to use aliases ?" 10 60) then
        case $NO_MAIN_WWW in
            true)
                TMP_ALIAS="www.$DOMAIN"
                ALIAS=$(whiptail --title "Server Alias" --inputbox "Please type all aliases" 10 60 $TMP_ALIAS 3>&1 1>&2 2>&3)
                ;;
            false)
                ALIAS=$(whiptail --title "Server Alias" --inputbox "Please type all aliases" 10 60 3>&1 1>&2 2>&3)
                ;;
            *)
                ALIAS=$(whiptail --title "Server Alias" --inputbox "Please type all aliases" 10 60 3>&1 1>&2 2>&3)
                ;;
        esac
        export DOM_REDIRECT="$DOM_PRINCIPAL $ALIAS"
    else
        export DOM_REDIRECT="$DOM_PRINCIPAL"
    fi

    IPV4=$(curl -s ip4.clara.net)
    for DOM in "${DOM_REDIRECT[@]}"
    do
        RECORD_IP_ADDRESS=$(dig A $DOM +short | head -1)
        if [[ ! "$RECORD_IP_ADDRESS" == "${IPV4}" ]]; then
            whiptail --title "Record IP" --msgbox "Please update/create a DNS record $DOM A $IPV4" 10 60
        fi
    done

    export CLIENT_DIR="/var/www/html/clients/$CLIENT_NAME/$DOM_PRINCIPAL"
    export CLIENT_HOME="/var/www/html/clients/$CLIENT_NAME"
    export LOGROTATE_FILE="/etc/logrotate.d/$DOM_PRINCIPAL.conf"
    export NGINX_REWRITE_FILE="/etc/nginx/rewrites/$DOM_PRINCIPAL.conf"
    export SECRET_FILE="/var/www/html/clients/$CLIENT_NAME/secrets.ini"
    export HTTPCLIENTFILE="$NGINXSITESAVDIR/001-$DOM_PRINCIPAL.conf"
    export HTTPENABLEDCLIENTFILE="$NGINXSITESENDIR/001-$DOM_PRINCIPAL.conf"

    export ASKED_PHP_VERSION=$(whiptail --title "PHP Version" --menu "Which PHP version do you want to use ?" 14 60 4 \
        "1" "PHP 7.0" \
        "2" "PHP 7.1" \
        "3" "PHP 7.2"  \
        "4" "PHP 7.3" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case $ASKED_PHP_VERSION in
            1)
                export VERSION_PHP="7.0"
                ;;
            2)
                export VERSION_PHP="7.1"
                ;;
            3)
                export VERSION_PHP="7.2"
                ;;
            4)
                export VERSION_PHP="7.3"
                ;;
            *)
                echo "Version not installed"
                ;;
        esac
        export PHP_BIN="php$VERSION_PHP-fpm.service"
    fi
    export PHPCLIENTFILE="/etc/php/$VERSION_PHP/fpm/pool.d/$DOM_PRINCIPAL.conf"

    # OPT=""
    # if (whiptail --title "CloudFlare" --yesno "Do you want to use Cloudflare caching ?" 10 60) then
    #     OPT="cloudflare"
    # fi
    # if (whiptail --title "FastCGI Cache" --yesno "Do you want to enable FastCGI caching ?" 10 60) then
    #     OPT="$OPT-cgi"
    # fi

    export VHOST_TEMPLATE="${MY_SCRIPT_PATH}/common/nginx/vhost-https.conf"

    case $OPT in
        "cloudflare")
            VHOSTFILE="${MY_SCRIPT_PATH}/common/vhost-https-cloudflare.conf"
            export VHOST_MOD="cloudflare"
            ;;
        "-cgi")
            VHOSTFILE="${MY_SCRIPT_PATH}/common/vhost-https-fastcgi.conf"
            export VHOST_MOD="fastcgi"
            ;;
        "cloudflare-cgi")
            VHOSTFILE="${MY_SCRIPT_PATH}/common/vhost-https-cloudflare-fastcgi.conf"
            export VHOST_MOD="cloudflare+fastcgi"
            ;;
        *)
            VHOSTFILE="${MY_SCRIPT_PATH}/common/vhost-https.conf"
            export VHOST_MOD="nocache"
            ;;
    esac

    export CERTDIR="/etc/letsencrypt/live/${DOM_PRINCIPAL}"

    if [[ ! -d $CERTDIR ]]; then
        if (whiptail --title "Let's Encrypt" --yesno "Do you want to generate Let's Encrypt Certificate ?" 10 60) then
            export USE_SSL="on"
            if [[ ! -f ${CERTBOT_DNS_PLUGIN_CLOUDFLARE} ]]; then
                export DNS_CLOUDFLARE_EMAIL=$(whiptail --title "Cloudflare DNS" --inputbox "Please enter the Cloudflare account email" 10 60 3>&1 1>&2 2>&3)
                export DNS_CLOUDFLARE_API_KEY=$(whiptail --title "Cloudflare DNS" --inputbox "Please enter the Cloudflare API Key" 10 60 3>&1 1>&2 2>&3)
                touch ${CERTBOT_DNS_PLUGIN_CLOUDFLARE}
                echo "dns_cloudflare_email = $DNS_CLOUDFLARE_EMAIL" >> ${CERTBOT_DNS_PLUGIN_CLOUDFLARE}
                echo "dns_cloudflare_api_key = $DNS_CLOUDFLARE_API_KEY" >> ${CERTBOT_DNS_PLUGIN_CLOUDFLARE}
                chmod 600 ${CERTBOT_DNS_PLUGIN_CLOUDFLARE}
                cloudflareAccoundChecker $DNS_CLOUDFLARE_EMAIL $DNS_CLOUDFLARE_API_KEY
            else
                DNS_CLOUDFLARE_EMAIL=$(cat ${CERTBOT_DNS_PLUGIN_CLOUDFLARE} | grep "dns_cloudflare_email" | cut -d\= -f2)
                DNS_CLOUDFLARE_API_KEY=$(cat ${CERTBOT_DNS_PLUGIN_CLOUDFLARE} | grep "dns_cloudflare_api_key" | cut -d\= -f2)
            fi
            grep "\[CERTBOT_OPT\]" ${SD_CONF_FILE} >/dev/null 2>&1
            if [[ ! $? -eq 0 ]]; then
                CERTBOT_EMAIL=$(whiptail --title "Certbot Email" --inputbox "Please type your email for Certbot alerts" 10 60  3>&1 1>&2 2>&3)
                echo "[CERTBOT_OPT]" >> ${SD_CONF_FILE}
                echo "CERTBOT_EMAIL=$CERTBOT_EMAIL" >> ${SD_CONF_FILE}
                echo "RSA_KEY_SIZE=4096" >> ${SD_CONF_FILE}
                echo "" >> $SD_CONF_FILE
            else
                CERTBOT_EMAIL=$(cat $SD_CONF_FILE | grep "CERTBOT_EMAIL" | cut -d\= -f2)
                CERTBOT_EMAIL=$(whiptail --title "Certbot Email" --inputbox "Please type your email for Certbot alerts" 10 60 $CERTBOT_EMAIL 3>&1 1>&2 2>&3)
            fi
            CERTBOT_CHALLENGE_TYPE_ASK=$(whiptail --title "Certbot challenge" --menu "Which challenge do you want use ?" 13 70 4 \
                "1" "DNS Challenge" \
                "2" "HTTP Challenge" \
                3>&1 1>&2 2>&3)
            case $CERTBOT_CHALLENGE_TYPE_ASK in
                1)
                    export CERTBOT_CHALLENGE_TYPE="dns"
                    CERTBOT_CHALLENGE_DNS_PLUGIN_ASK=$(whiptail --title "DNS challenge plugin" --menu "Which DNS challenge plugin do you want use ?" 13 70 4 \
                        "1" "Cloudflare" \
                        "2" "OVH" 3>&1 1>&2 2>&3)
                    case $CERTBOT_CHALLENGE_DNS_PLUGIN_ASK in
                        1)
                            export CERTBOT_CHALLENGE_DNS_PLUGIN="cloudflare"
                            ;;
                        2)
                            export CERTBOT_CHALLENGE_DNS_PLUGIN="ovh"
                            ;;
                        *)
                    esac
                    ;;
                2)
                    export CERTBOT_CHALLENGE_TYPE="http"
                    ;;
                *)
                    export CERTBOT_CHALLENGE_TYPE=""
                    ;;
            esac
            export DOMAIN_ASK=$(whiptail --title "Domaines LE" --inputbox "Please type domains to use with Let's Encrypt" 10 60 $DOM_REDIRECT 3>&1 1>&2 2>&3)
            export LE_DOMAIN_LIST=$(echo $DOMAIN_ASK | sed 's/\ /\ -d\ /g')
        else
            export USE_SSL="off"
            export VHOST_TEMPLATE="${MY_SCRIPT_PATH}/common/nginx/vhost-http.conf"
        fi
    fi
 
    if (whiptail --title "Database" --yesno "Do you want to create a database ?" 10 60) then
        export DATABASE_OPT="Yes"
        export DB_PASSWORD=$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n'; echo)
        TMP_BDD_USER=$(echo ${DOM_PRINCIPAL} | sed 's/www\.//g' | sed 's/\./_/g' | sed 's/_fr//g' | sed 's/_com//g' | sed 's/_co//g' | sed 's/__//g')
        DB_USER="usr_$TMP_BDD_USER"
        DB_NAME="db_$TMP_BDD_USER"
        export DB_NAME=$(whiptail --title "DBName" --inputbox "Database name" 10 60 $DB_NAME 3>&1 1>&2 2>&3)
        export DB_USER=$(whiptail --title "DBUser" --inputbox "Database username" 10 60 $DB_USER 3>&1 1>&2 2>&3)
    fi

    export FTP_PASSWORD=$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n'; echo)
    export FTP_PASSWORDHASH=$(mkpasswd --hash=md5 -s "$FTPPASSWORD")
    TMP_FTP_USERNAME=$(echo ${DOM_PRINCIPAL} | sed 's/www\.//g' | sed 's/\./_/g' | sed 's/_fr//g' | sed 's/_com//g' | sed 's/_co//g' | sed 's/__//g')
    export FTP_USERNAME="ftp_$TMP_FTP_USERNAME"
    export FTP_ROOT="$CLIENT_DIR/web"

    if (whiptail --title "Deploy Wordpress" --yesno "Do you want to deploy wordpress ?" 10 60) then
        export WORDPRESS_OPT="Yes"
        grep "\[WP-ADMIN\]" $SD_CONF_FILE >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            WPADMINUSER=$(cat $SD_CONF_FILE | grep WP_DEFAULT_ADMIN_USERNAME | cut -d\= -f2)
            WPADMINEMAIL=$(cat $SD_CONF_FILE | grep WP_DEFAULT_ADMIN_EMAIL | cut -d\= -f2)
            WPADMINPASSWORD=$(cat $SD_CONF_FILE | grep WP_DEFAULT_ADMIN_PASSWORD | cut -d\= -f2)
        fi
        export WP_ADMIN_USER=$(whiptail --title "Admin user" --inputbox "Administrator username" 10 60 ${WPADMINUSER} 3>&1 1>&2 2>&3)
        export WP_ADMIN_EMAIL=$(whiptail --title "Admin email" --inputbox "Administrator email" 10 60 ${WPADMINEMAIL} 3>&1 1>&2 2>&3)
        export WP_ADMIN_PASSWORD=$(whiptail --title "Admin password" --inputbox "Administrator password" 10 60 ${WPADMINPASSWORD} 3>&1 1>&2 2>&3)
        export WP_URL=$(whiptail --title "URL" --inputbox "URL complète du site" 10 60 https://$DOM_PRINCIPAL 3>&1 1>&2 2>&3)
        export WP_SITENAME=$(whiptail --title "Site name" --inputbox "Nom du site" 10 60 3>&1 1>&2 2>&3)
        export WP_PATH="$CLIENT_DIR/web"
        grep "\[WP-ADMIN\]" $SD_CONF_FILE >/dev/null 2>&1
        if [[ ! $? -eq 0 ]]; then
            if (whiptail --title "WP Default Admin" --yesno "Do you want to store these values ?" 10 60) then
                echo "[WP-ADMIN]" >> $SD_CONF_FILE
                echo "WP_DEFAULT_ADMIN_USERNAME=$WP_ADMIN_USER" >> $SD_CONF_FILE
                echo "WP_DEFAULT_ADMIN_EMAIL=$WP_ADMIN_EMAIL" >> $SD_CONF_FILE
                echo "WP_DEFAULT_ADMIN_PASSWORD=$WP_ADMIN_PASSWORD" >> $SD_CONF_FILE
                echo "" >> $SD_CONF_FILE
            fi
        fi
        WP_INSTALL_PLUGINS="no"
        if (whiptail --title "WP Base Plugins" --yesno "Do you want install base plugins ?" 10 60) then
            export WP_INSTALL_PLUGINS="yes"
        fi
        if (whiptail --title "New WP User" --yesno "Do you want to create another user ?" 10 60) then
            export WP_SECOND_USER="Yes"
            export WP_SECOND_USERNAME=$(whiptail --title "Username" --inputbox "Username" 10 60 3>&1 1>&2 2>&3)
            export WP_SECOND_FIRSTNAME=$(whiptail --title "Prénom" --inputbox "First Name" 10 60 3>&1 1>&2 2>&3)
            export WP_SECOND_LASTNAME=$(whiptail --title "Nom" --inputbox "Last Name" 10 60 3>&1 1>&2 2>&3)
            export WP_SECOND_EMAIL=$(whiptail --title "Email" --inputbox "User email" 10 60 3>&1 1>&2 2>&3)
            export WP_SECOND_PASSWORD=$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n'; echo)
        fi
    fi 

    TODAY=`date '+%Y%m%d'`
    if [[ ! -d /opt/deploy_history ]]; then
        mkdir -p /opt/deploy_history
    fi
    WEBSITE_FILE="/opt/deploy_history/$TODAY-$DOM_PRINCIPAL.ini"
    touch $WEBSITE_FILE
    echo "[$DOM_PRINCIPAL]" >> $WEBSITE_FILE
    echo "CLIENT_NAME=${CLIENT_NAME}" >> $WEBSITE_FILE
    echo "CLIENT_DIR=${CLIENT_DIR}" >> $WEBSITE_FILE
    echo "CLIENT_HOME=${CLIENT_HOME}" >> $WEBSITE_FILE
    echo "DOM_PRINCIPAL=${DOM_PRINCIPAL}" >> $WEBSITE_FILE
    echo "DOM_REDIRECT=${DOC_REDIRECT}" >> $WEBSITE_FILE
    echo "LOGROTATE_FILE=${LOGROTATE_FILE}" >> $WEBSITE_FILE
    echo "HTTPCLIENTFILE=${HTTPCLIENTFILE}" >> $WEBSITE_FILE
    echo "HTTPENABLEDCLIENTFILE=${HTTPENABLEDCLIENTFILE}" >> $WEBSITE_FILE
    echo "SECRET_FILE=${SECRET_FILE}" >> $WEBSITE_FILE
    echo "NGINX_REWRITE_FILE=${NGINX_REWRITE_FILE}" >> $WEBSITE_FILE
    echo "PHPCLIENTFILE=${PHPCLIENTFILE}" >> $WEBSITE_FILE
    echo "PHPVERSION=$VERSION_PHP" >> $WEBSITE_FILE
    echo "DB_NAME=${DB_NAME}" >> $WEBSITE_FILE
    echo "DB_USER=${DB_USER}" >> $WEBSITE_FILE
    echo "FTP_USERNAME=${FTP_USERNAME}" >> $WEBSITE_FILE
    echo "FTP_ROOT=${FTP_ROOT}" >> $WEBSITE_FILE


    whiptail --title "Deployment" --msgbox "Deployment will be now processed !" 10 60

    install
}

function install() {
    source ${MY_SCRIPT_PATH}/functions/vars.sh
    source ${MY_SCRIPT_PATH}/functions/letsencrypt.sh
    source ${MY_SCRIPT_PATH}/functions/cloudflare.sh
    source ${MY_SCRIPT_PATH}/functions/proftpd.sh
    source ${MY_SCRIPT_PATH}/functions/wordpress.sh
    source ${MY_SCRIPT_PATH}/functions/database.sh

    echo "## Starting deployment"
    if (whiptail --title "Cloudflare DNS Validation" --yesno "Do you wan't to update automatically your DNS Record with Cloudflare API ?" 10 60) then
        checkingCFRecord "${DOMAIN}" "${DOM_REDIRECT}"
    fi

    echo "  -> Creating client's folders"
    if [[ ! -d $CLIENT_HOME ]]; then
        mkdir -p $CLIENT_HOME
    else
        echo -e "   -> Client home directory ${RED}already exist, skipping...${CLASSIC}"
    fi
    if [[ ! -d $CLIENT_DIR ]]; then
        mkdir -p ${CLIENT_DIR}/{web,sessions,tmp,log,backup}
        ln -s /var/www/html/clients/${CLIENT_NAME}/${DOM_PRINCIPAL}/web /var/www/html/${DOM_PRINCIPAL}
    else
        echo -e "   -> ${RED}Website directory already exist, please rechecks vars${CLASSIC}"
    fi
    cp ${MY_SCRIPT_PATH}/common/errors/index.html ${CLIENT_DIR}/web/index.html
    cp ${MY_SCRIPT_PATH}/common/errors ${CLIENT_DIR}/web/error -R

    sleep 1

    echo "  -> Creating user ${CLIENT_NAME} in group www-data"
    grep "${CLIENT_NAME}" /etc/passwd >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo -e "   -> User ${CLIENT_NAME} ${RED}already exists, skipping...${CLASSIC}"
    else
        useradd -G www-data -md ${CLIENT_HOME} -s /bin/false ${CLIENT_NAME} >/dev/null 2>&1
    fi

    sleep 1

    echo "  -> Deploying secret file"
    if [[ ! -f ${SECRET_FILE} ]]; then 
        touch ${SECRET_FILE}
    fi
    chmod 600 ${SECRET_FILE}
    chown $CLIENT_NAME:www-data ${SECRET_FILE}
    echo "[$DOM_PRINCIPAL]" >> ${SECRET_FILE}

    sleep 1

    echo "  -> Deploying Nginx website configuration"
    cp $VHOST_TEMPLATE $HTTPCLIENTFILE
    sed -i "s/{CLIENT_NAME}/$CLIENT_NAME/g" $HTTPCLIENTFILE
    sed -i "s/{SERVERNAME}/$DOMAIN/g" $HTTPCLIENTFILE
    sed -i "s/{DOM_PRINCIPAL}/$DOM_PRINCIPAL/g" $HTTPCLIENTFILE
    sed -i "s/{DOM_REDIRECT}/$DOM_REDIRECT/g" $HTTPCLIENTFILE

    if [[ ! -d /etc/nginx/rewrites ]]; then
        mkdir -p /etc/nginx/rewrites
    fi
    touch $NGINX_REWRITE_FILE

    sleep 1

    echo "  -> Deploying PHP-FPM pool configuration"
    cp ${MY_SCRIPT_PATH}/common/php/pool.conf ${PHPCLIENTFILE}
    sed -i "s/{CLIENT_NAME}/$CLIENT_NAME/g" ${PHPCLIENTFILE}
    sed -i "s/{SERVERNAME}/${DOM_PRINCIPAL}/g" ${PHPCLIENTFILE}
    sed -i "s/{PHPUSER}/$CLIENT_NAME/g" ${PHPCLIENTFILE}

    sleep 1

    echo "  -> Creating logrotate configuration"
    cp ${MY_SCRIPT_PATH}/common/system/logrotate.conf $LOGROTATE_FILE
    sed -i "s/{SERVERNAME}/$DOM_PRINCIPAL/g" $LOGROTATE_FILE
    sed -i "s/{CLIENT_NAME}/$CLIENT_NAME/g" $LOGROTATE_FILE

    sleep 1

    echo "  -> Checking for SSL certificate"
    grep "\[CERTBOT_OPT\]" ${SD_CONF_FILE} >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        CERTBOT_EMAIL=$(cat ${SD_CONF_FILE} | grep "CERTBOT_EMAIL" |  cut -d\= -f2)
        RSA_KEY_SIZE=$(cat ${SD_CONF_FILE} | grep "RSA_KEY_SIZE" |  cut -d\= -f2)
    else
        CERTBOT_EMAIL=$(whiptail --title "Certbot Email" --inputbox "Please type your email for Certbot alerts" 10 60  3>&1 1>&2 2>&3)
        RSA_KEY_SIZE="2048"
    fi
    case ${USE_SSL} in
        "on")
            case ${CERTBOT_CHALLENGE_TYPE} in
                "dns")
                    case ${CERTBOT_CHALLENGE_DNS_PLUGIN} in
                        "cloudflare")
                            if [[ ! -f ${CERTBOT_DNS_PLUGIN_CLOUDFLARE} ]]; then
                                echo "   -> Initializing Python Cloudflare configuration"
                                export DNS_CLOUDFLARE_EMAIL=$(whiptail --title "Cloudflare DNS" --inputbox "Please enter the Cloudflare account email" 10 60 3>&1 1>&2 2>&3)
                                export DNS_CLOUDFLARE_API_KEY=$(whiptail --title "Cloudflare DNS" --inputbox "Please enter the Cloudflare API Key" 10 60 3>&1 1>&2 2>&3)
                                touch ${CERTBOT_DNS_PLUGIN_CLOUDFLARE}
                                echo "dns_cloudflare_email = $DNS_CLOUDFLARE_EMAIL" >> ${CERTBOT_DNS_PLUGIN_CLOUDFLARE}
                                echo "dns_cloudflare_api_key = $DNS_CLOUDFLARE_API_KEY" >> ${CERTBOT_DNS_PLUGIN_CLOUDFLARE}
                                chmod 600 ${CERTBOT_DNS_PLUGIN_CLOUDFLARE}
                                cloudflareAccoundChecker $DNS_CLOUDFLARE_EMAIL $DNS_CLOUDFLARE_API_KEY
                            else
                                DNS_CLOUDFLARE_EMAIL=$(cat ${CERTBOT_DNS_PLUGIN_CLOUDFLARE} | grep "dns_cloudflare_email" | cut -d\= -f2)
                                DNS_CLOUDFLARE_API_KEY=$(cat ${CERTBOT_DNS_PLUGIN_CLOUDFLARE} | grep "dns_cloudflare_api_key" | cut -d\= -f2)
                            fi
                            newCertbot "dns" "cloudflare" "${LE_DOMAIN_LIST}" "$CERTBOT_EMAIL" "$RSA_KEY_SIZE" "$DOM_PRINCIPAL"
                            ;;
                        "ovh")
                            if [[ ! -f ${CERTBOT_DNS_PLUGIN_OVH} ]]; then
                                echo "   -> Initializing Python PIP OVH configuration"
                                pip3 install --yes certbot-dns-ovh >/dev/null 2>&1
                                export DNS_OVH_ENDPOINT=$(whiptail --title "OVH DNS" --inputbox "Please enter the OVH DNS Endpoint" 10 60 ovh-eu 3>&1 1>&2 2>&3)
                                export DNS_OVH_APPLICTION_KEY=$(whiptail --title "OVH DNS" --inputbox "Please enter the OVH DNS App Key" 10 60 3>&1 1>&2 2>&3)
                                export DNS_OVH_APPLICTION_SECRET=$(whiptail --title "OVH DNS" --inputbox "Please enter the OVH DNS App Secret" 10 60 3>&1 1>&2 2>&3)
                                export DNS_OVH_CONSUMER_KEY=$(whiptail --title "OVH DNS" --inputbox "Please enter the OVH DNS Consumer Key" 10 60 3>&1 1>&2 2>&3)
                                touch ${CERTBOT_DNS_PLUGIN_OVH}
                                echo "dns_ovh_endpoint = $DNS_OVH_ENDPOINT" >> ${CERTBOT_DNS_PLUGIN_OVH}
                                echo "dns_ovh_application_key = $DNS_OVH_APPLICTION_KEY" >> ${CERTBOT_DNS_PLUGIN_OVH}
                                echo "dns_ovh_application_secret = $DNS_OVH_APPLICTION_SECRET" >> ${CERTBOT_DNS_PLUGIN_OVH}
                                echo "dns_ovh_consumer_key = $DNS_OVH_CONSUMER_KEY" >> ${CERTBOT_DNS_PLUGIN_OVH}
                                chmod 600 ${CERTBOT_DNS_PLUGIN_OVH}
                            else
                                DNS_OVH_ENDPOINT=$(cat ${CERTBOT_DNS_PLUGIN_OVH} | grep "dns_ovh_endpoint" | cut -d\= -f2)
                                DNS_OVH_APPLICTION_KEY=$(cat ${CERTBOT_DNS_PLUGIN_OVH} | grep "dns_ovh_application_key" | cut -d\= -f2)
                                DNS_OVH_APPLICTION_SECRET=$(cat ${CERTBOT_DNS_PLUGIN_OVH} | grep "dns_ovh_application_secret" | cut -d\= -f2)
                                DNS_OVH_CONSUMER_KEY=$(cat ${CERTBOT_DNS_PLUGIN_OVH} | grep "dns_ovh_consumer_key" | cut -d\= -f2)
                            fi
                            newCertbot "dns" "ovh" "${LE_DOMAIN_LIST}" "$CERTBOT_EMAIL" "$RSA_KEY_SIZE" "$DOM_PRINCIPAL"
                            ;;
                        *)
                            ;;
                    esac
                    ;;
                "http")
                    newCertbot "http" "" "${LE_DOMAIN_LIST}" "$CERTBOT_EMAIL" "$RSA_KEY_SIZE" "$DOM_PRINCIPAL"
                    ;;
                *)
                    ;;
            esac
            ;;
        "off")
            echo "  -> No certificate will be installed !"
            ;;
        *)
            echo "  -> No certificate will be installed !"
            ;;
    esac

    case $DATABASE_OPT in
        "Yes")
            echo "  -> Checking for database generation"
            dbcreate "${DB_NAME}" "${DB_USER}" "${DB_PASSWORD}"
            ;;
        *)
            ;;
    esac

    sleep 1

    echo "  -> Creating FTP account"
    ftpasswd "${FTP_USERNAME}" "${FTP_PASSWORD}" "${FTP_ROOT}"
    
    sleep 1

    case $WORDPRESS_OPT in
        "Yes")
            echo "  -> Deploying Wordpress"
            WP_LOCALE=$(whiptail --title "Wordpress locale" --menu "Which locale do you want deploy ?" 13 60 5 \
                "1" "French" \
                "2" "English" \
                "3" "English UK" \
                "4" "German" \
                "5" "Spanish" 3>&1 1>&2 2>&3)
            case $WP_LOCALE in
                1)
                    export WP_DL_LOCALE="fr_FR"
                    ;;
                2)
                    export WP_DL_LOCALE="en_US"
                    ;;
                3)
                    export WP_DL_LOCALE="en_GB"
                    ;;
                4)
                    export WP_DL_LOCALE="de_DE"
                    ;;
                5)
                    export WP_DL_LOCALE="es_ES"
                    ;;
                *)
                    export WP_DL_LOCALE="en_US"
                    ;;
            esac
            wordpressdeploy "${WP_SITENAME}" "${WP_URL}" "${WP_PATH}" "${WP_ADMIN_USER}" "${WP_ADMIN_EMAIL}" "${WP_ADMIN_PASSWORD}" "${WP_INSTALL_PLUGINS}" "${DB_NAME}" "${DB_USER}" "${DB_PASSWORD}" "${WP_DL_LOCALE}"
            case $WP_SECOND_USER in
                "Yes")
                    wordpressNewUser "${WP_PATH}" "${WP_SECOND_USERNAME}" "${WP_SECOND_EMAIL}" "${WP_SECOND_FIRSTNAME}" "${WP_SECOND_LASTNAME}" "${WP_SECOND_PASSWORD}"
                    ;;
                *)
                    ;;
            esac
            ;;
        *)
            ;;
    esac
    
    sleep 1

    echo "  -> Fixing permissions"
    chown ${CLIENT_NAME}:www-data ${CLIENT_HOME} -R
    find ${CLIENT_DIR} -type f -exec chmod 644 "{}" \;
    find ${CLIENT_DIR} -type d -exec chmod 755 "{}" \;

    if (whiptail --title "Activate" --yesno "Do you wan't to activate your site $DOM_PRINCIPAL ?" 10 60) then
        ln -s /etc/nginx/sites-available/001-$DOM_PRINCIPAL.conf /etc/nginx/sites-enabled/001-$DOM_PRINCIPAL.conf
        systemctl reload nginx.service >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo -e "   -> Reload Nginx ${GREEN}Successfull${CLASSIC}"
        fi
        systemctl reload $PHP_BIN >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo -e "   -> Reload PHP ${GREEN}Successfull${CLASSIC}"
        fi
    fi
    echo ""
    echo "  --> You can now visit your new website at $DOM_PRINCIPAL"
    echo ""
}

function rollback() {
    echo "# Rollback function, use at your own risk !"
    TODAY=`date '+%Y%m'`
    ROLLBACK_FILE=$(find /opt/deploy_history -type f -name "$TODAY*" | sort -nr | head -1)
    ROLLBACK_DOMAIN=$(echo $ROLLBACK_FILE | cut -d\/ -f4 | sed 's/[0-9]//g' | sed 's/^-//g' | sed 's/\.ini//g')

    if (whiptail --title "Rollback" --yesno "You are rollbacking deploy for $ROLLBACK_DOMAIN, continue ?" 10 60) then
        LOGROTATE_FILE=$(cat $ROLLBACK_FILE | grep "LOGROTATE_FILE" | cut -d\= -f2)
        DOM_PRINCIPAL=$(cat $ROLLBACK_FILE | grep "DOM_PRINCIPAL" | cut -d\= -f2)
        CLIENT_DIR=$(cat $ROLLBACK_FILE | grep "CLIENT_DIR" | cut -d\= -f2)
        HTTPENABLEDCLIENTFILE=$(cat $ROLLBACK_FILE | grep "HTTPENABLEDCLIENTFILE" | cut -d\= -f2)
        HTTPCLIENTFILE=$(cat $ROLLBACK_FILE | grep "HTTPCLIENTFILE" | cut -d\= -f2)
        PHPCLIENTFILE=$(cat $ROLLBACK_FILE | grep "PHPCLIENTFILE" | cut -d\= -f2)
        DB_NAME=$(cat $ROLLBACK_FILE | grep "DB_NAME" | cut -d\= -f2)
        FTP_USERNAME=$(cat $ROLLBACK_FILE | grep "FTP_USERNAME" | cut -d\= -f2)
        PHPVERSION=$(cat $ROLLBACK_FILE | grep "PHPVERSION" | cut -d\= -f2)

        echo "  -> Deleting Logrotate file $LOGROTATE_FILE"
        rm $LOGROTATE_FILE -f
        echo "  -> Deleting symbolik link /var/www/html/$DOM_PRINCIPAL"
        if [[ ! -z $DOM_PRINCIPAL ]]; then
            rm /var/www/html/$DOM_PRINCIPAL
        fi
        echo "  -> Deleting Web folders $CLIENT_DIR"
        if [[ ! -z $CLIENT_DIR ]]; then
            rm -Rf $CLIENT_DIR
        fi
        echo "  -> Deleting PHP Pool configuration file $PHPCLIENTFILE"
        if [[ ! -z $PHPCLIENTFILE ]]; then
            rm -Rf $PHPCLIENTFILE
        fi
        echo "  -> Deleting Nginx configuration for this site : $HTTPENABLEDCLIENTFILE"
        if [[ ! -z $HTTPENABLEDCLIENTFILE ]]; then
            rm -Rf $HTTPENABLEDCLIENTFILE
        fi
        if [[ ! -z $HTTPCLIENTFILE ]]; then
            rm -Rf $HTTPCLIENTFILE
        fi
        echo "  -> Dropping database $DB_NAME"
        mysql -e "DROP DATABASE $DB_NAME;" >/dev/null 2>&1
        echo "  -> Deleting FTP User $FTP_USERNAME"
        sed -i "/^$FTP_USERNAME/d" /etc/proftpd/ftpd.passwd >/dev/null 2>&1

        echo "  -> Reloading services"
        systemctl reload nginx.service >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo -e "   -> Reload Nginx ${GREEN}Successfull${CLASSIC}"
        fi
        systemctl reload php$PHPVERSION-fpm.service >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo -e "   -> Reload PHP ${GREEN}Successfull${CLASSIC}"
        fi

        rm -f $ROLLBACK_FILE >/dev/null 2>&1

        echo -e "  -> Rollback ${GREEN}done${CLASSIC} for $ROLLBACK_DOMAIN"
    fi

}

function updateNginxConfiguration() {
    echo "### Updating Nginx configuration with latest optimization"
    for CONF in $(ls $SNIPPETS_FILES)
    do
	    if [[ "$(md5sum $SNIPPETS_FILES/$CONF | awk '{print $1}')" != "$(md5sum /etc/nginx/snippets/$CONF | awk '{print $1}')" ]]; then
            case $1 in
                "check")
                    SNIPPETS_UPDATE="available"
                    ;;
                *)
                    rsync -azpq $SNIPPETS_FILES/$CONF /etc/nginx/snippets/$CONF --delete
                    if [[ $? -eq 0 ]]; then
                        echo -e "   -> Snippet $CONF ${GREEN}successfully updated${CLASSIC}"
                    else
                        echo -e "   -> ${RED}Fail${CLASSIC} to update snippets $CONF !"
                    fi
                    ;;
            esac
	    fi
    done
    case $SNIPPETS_UPDATE in
        "available")
            case $1 in
                "check")
                    break
                    ;;
                *)
                    whiptail --title "Update Available" --msgbox "Updates available for Nginx Snippets !" 10 60
                    ;;
            esac
            ;;
        *)
            break
            ;;
    esac
}
