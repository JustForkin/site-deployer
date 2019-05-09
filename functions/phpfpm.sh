function enablefpm() {
    ## Version PHP
    export PHP_VERSION=$(whiptail --title "PHP Version" --menu "Quelle version PHP Utiliser ?" 15 60 4 \
        "1" "PHP 7.0" \
        "2" "PHP 7.1" \
        "3" "PHP 7.2"  \
        "4" "PHP 7.3" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case $PHP_VERSION in
            1)
                VERSION_PHP="7.0"
                ;;
            2)
                VERSION_PHP="7.1"
                ;;
            3)
                VERSION_PHP="7.2"
                ;;
            4)
                VERSION_PHP="7.3"
                ;;
            *)
                echo "PHP Version is not installed"
                ;;
        esac
        export PHP_BIN="php$VERSION_PHP-fpm.service"
    fi

    export PHPCLIENTFILE="/etc/php/$VERSION_PHP/fpm/pool.d/$DOMAIN.conf"
    # echo "### Copie du pool FPM $PHPCLIENTFILE"
    # cp $(dirname "$0")/common/pool.conf $PHPCLIENTFILE
    # sed -i "s/{CLIENT_NAME}/$CLIENT_NAME/g" $PHPCLIENTFILE
    # sed -i "s/{SERVERNAME}/$DOMAIN/g" $PHPCLIENTFILE
    # sed -i "s/{PHPUSER}/$CLIENT_NAME/g" $PHPCLIENTFILE
    # systemctl reload php$VERSION_PHP-fpm.service
    # if [[ $1 -eq 0 ]]; then
    #     echo -e "  -> ${green}Reload Ok${reset}"
    # else
    #     echo -e "  -> ${red}Reload failed !${reset}"
    # fi
}