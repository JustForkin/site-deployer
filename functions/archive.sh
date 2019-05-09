function infoclient() {
    source $(dirname "$0")/functions/functions/nginx.sh

    export CLIENT_NAME=$(whiptail --title "Client name" --inputbox "Client name, will be used for client folder" 10 60 3>&1 1>&2 2>&3)
    export DOMAIN=$(whiptail --title "Domain" --inputbox "First level domain name" 10 60 3>&1 1>&2 2>&3)
    export CLIENT_DIR="$WEBROOTDIR/clients/$CLIENT_NAME/$DOMAIN"
    export CLIENT_HOME="$WEBROOTDIR/clients/$CLIENT_NAME"

    # if [[ ! -d $CLIENT_HOME ]]; then
    #     echo ""
    #     echo "## Création du répertoire utilisateur"
    #     # mkdir -p $CLIENT_HOME
    #     # checkretour $?
    #     # useradd -G www-data -md $WEBROOTDIR/clients/$CLIENT_NAME -s /bin/false $CLIENT_NAME >/dev/null 2>&1
    #     # chown $CLIENT_NAME:www-data $WEBROOTDIR/clients/$CLIENT_NAME
    # else
    #     whiptail --title "Warning" --msgbox "Le répertoire $CLIENT_HOME existe déjà." 10 60
    #     echo "  -> Le homedir du client existe déjà."
    # fi
    export LOGROTATE_FILE="/etc/logrotate.d/$DOMAIN.conf"
    export NGINX_REWRITE_FILE="/etc/nginx/rewrites/$DOMAIN.conf"
    export SECRET_FILE="/var/www/html/clients/$CLIENT_NAME/secrets.ini"
    if [[ ! -d ${CLIENT_DIR} ]]; then
        #echo "## Création des webdirs"
        # mkdir -p ${CLIENT_DIR}/{web,log,tmp,sessions}
        # mkdir -p ${CLIENT_DIR}/log/archive
        # cd /var/www/html
        REPLINK="clients/$CLIENT_NAME/$DOMAIN/web"
        # SYMBOLINK=$(whiptail --title "Lien symbolique" --inputbox "Lien symbolique du site $DOMAIN" 10 110 $REPLINK 3>&1 1>&2 2>&3)
        # ln -s $REPLINK $DOMAIN
        # checkretour $?
        # echo "## Création du fichier de rewrites"
        # if [[ ! -d /etc/nginx/rewrites ]]; then
        #     mkdir -p /etc/nginx/rewrites
        # fi
        # touch /etc/nginx/rewrites/$DOMAIN.conf
        # checkretour $?
        # echo "## Création de la configuration logrotate"
        # cp $LOGROTATESAMPLE $LOGROTATE_FILE
        # sed -i "s/{SERVERNAME}/$DOMAIN/g" $LOGROTATE_FILE
        # sed -i "s/{CLIENT_NAME}/$CLIENT_NAME/g" $LOGROTATE_FILE
        # logrotate -d $LOGROTATE_FILE >/dev/null 2>&1
        # checkretour $?
        # cp /opt/site-deployer/common/errors/index.html ${CLIENT_DIR}/web/index.html
        # cp /opt/site-deployer/common/errors ${CLIENT_DIR}/web/error -R
        # fixdroits
    else
        whiptail --title "Warning" --msgbox "Le répertoire ${CLIENT_DIR} existe déjà." 10 85
    fi
    
    # if [[ ! -f $SECRET_FILE ]]; then 
    #     touch $SECRET_FILE
    # fi
    # chmod 600 $SECRET_FILE
    # chown $CLIENT_NAME:www-data $SECRET_FILE
    # echo "[$DOMAIN]" >> $SECRET_FILE
    createvhost
}

# function mainmenu() {
#     ## Main Menu
#     ## Version PHP
#     ACTION=$(whiptail --title "Menu" --menu "Que Souhaitez-vous faire ?" 15 70 6 \
#         "1" "Création des vhosts" \
#         "2" "Déployer Wordpress" \
#         "3" "Déployer un sous domaine FTP" \
#         "4" "Quitter" 3>&1 1>&2 2>&3)
#     exitstatus=$?
#     if [ $exitstatus = 0 ]; then
#         case $ACTION in
#             1)
#                 createvhost 
#                 mainmenu
#                 ;;
#             2)
#                 wordpressdeploy
#                 mainmenu
#                 ;;
#             3)
#                 updateftpletsencrypt
#                 mainmenu
#                 ;;
#             4)
#                 exit
#                 ;;
#             *)
#                 echo "Retour au menu"
#                 mainmenu
#                 ;;
#         esac
#     else
# 	    echo ""
#         echo "## Exiting .."
#         exit
#     fi
# }

function fixdroits() {
    echo ""
    echo "## Fixing perms on dirs and files"
    chown $CLIENT_NAME:www-data ${CLIENT_DIR} -R
    chown $CLIENT_NAME:www-data ${CLIENT_DIR}/* -R
    checkretour $?
}

function checkretour() {
    if [[ $1 -eq 0 ]]; then
        echo -e "   -> ${GREEN}Ok${CLASSIC}"
    else
        echo -e "   -> ${RED}Error${CLASSIC}"
    fi
    echo ""
}