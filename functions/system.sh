#!/bin/bash
function checkCompatibility() {
    source $(dirname "$0")/functions/cloudflare.sh
    source $(dirname "$0")/functions/vars.sh
    source $(dirname "$0")/functions/common.sh
    
    echo "## Checking for system"
    echo "  -> Updating repos"
    apt-get update >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo -e "     --> Update ${GREEN}successfully${CLASSIC}"
    fi
    which lsb_release >/dev/null 2>&1
    if [[ ! $? -eq 0 ]]; then 
        apt install lsb-release >/dev/null 2>&1
    fi
    export SYSTEM_NAME=$(lsb_release -si)
    export SYSTEM_VERSION=$(lsb_release -sr)
    export SYSTEM_CODENAME=$(lsb_release -sc)
    case $SYSTEM_NAME in
        Debian|Ubuntu)
            echo "  -> System : $SYSTEM_NAME"
            echo "  -> Version : $SYSTEM_VERSION"
            echo -e "    -> Compatibility : ${GREEN}OK${CLASSIC}"
            ;;
        *)
            echo -e "    -> Compatibility : ${RED}Not OK${CLASSIC}"
            exit 1
            ;;
    esac

    echo ""
    sleep 1

    echo "## Checking for base packages"
    echo "  -> Installations can take some time, be patient..."
    echo "   -> Install base dependencies"
    declare PACKAGES=( "whiptail" "curl" "jq" "whois" "vim" "python3" "binutils" )
    for PACKAGE in "${PACKAGES[@]}"
    do
        which $PACKAGE >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo -e "     --> $PACKAGE ${GREEN}already installed${CLASSIC}"
        else
            apt-get install -y $PACKAGE >/dev/null 2>&1
            if [[ $? -eq 0 ]]; then
                echo -e "     --> $PACKAGE ${GREEN}successfully${CLASSIC} installed"
            else
                echo -e "     --> $PACKAGE install ${RED}failed${CLASSIC}"
            fi
        fi
    done

    echo "   -> Install Python PIP"
    which pip3 >/dev/null 2>&1
    if [[ ! $? -eq 0 ]]; then
        apt-get install -y python3-pip >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo -e "     --> Python3-PIP ${GREEN}successfully${CLASSIC} installed"
            ln -s /usr/bin/pip3 /usr/bin/pip >/dev/null 2>&1
        else
            echo -e "     --> Python3-PIP install ${RED}failed${CLASSIC}"
        fi
    else
        echo -e "     --> Python3-PIP ${GREEN}already installed${CLASSIC}"
    fi

    echo "   -> Install Web Server"
    which nginx >/dev/null 2>&1
    if [[ ! $? -eq 0 ]]; then
        apt-get install -y nginx >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo -e "     --> Nginx ${GREEN}successfully${CLASSIC} installed"
        else
            echo -e "     --> Nginx install ${RED}failed${CLASSIC}"
        fi
    else
        echo -e "     --> Nginx ${GREEN}already installed${CLASSIC}"
    fi

    echo "   -> Install FTP Server"
    which proftpd >/dev/null 2>&1
    if [[ ! $? -eq 0 ]]; then
        apt-get install -y proftpd >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo -e "     --> Proftpd ${GREEN}successfully${CLASSIC} installed"
        else
            echo -e "     --> Proftpd install ${RED}failed${CLASSIC}"
        fi
    else
        echo -e "     --> Proftpd ${GREEN}already installed${CLASSIC}"
    fi

    echo "   -> Install MySQL Server"
    which mysql >/dev/null 2>&1
    if [[ ! $? -eq 0 ]]; then
        apt-get install -y mariadb-client mariadb-server >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo -e "     --> MySQL ${GREEN}successfully${CLASSIC} installed"
        else
            echo -e "     --> MySQL install ${RED}failed${CLASSIC}"
        fi
    else
        echo -e "     --> MySQL ${GREEN}already installed${CLASSIC}"
    fi

    echo "   -> Install Certbot"
    which certbot >/dev/null 2>&1
    if [[ ! $? -eq 0 ]]; then
        apt-get install -y certbot >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo -e "     --> Certbot ${GREEN}successfully${CLASSIC} installed"
        else
            echo -e "     --> Certbot install ${RED}failed${CLASSIC}"
        fi
    else
        echo -e "     --> Certbot ${GREEN}already installed${CLASSIC}"
    fi

    echo "   -> Install Certbot Plugins"
    apt-get install -y python3-certbot-dns-cloudflare >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo -e "     --> Certbot plugins ${GREEN}successfully${CLASSIC} installed"
    else
        echo -e "     --> Certbot plugins install ${RED}failed${CLASSIC}"
    fi

    echo "   -> Install Sendmail"
    which sendmail >/dev/null 2>&1
    if [[ ! $? -eq 0 ]]; then
        apt-get install -y sendmail >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo -e "     --> Sendmail ${GREEN}successfully${CLASSIC} installed"
        else
            echo -e "     --> Sendmail install ${RED}failed${CLASSIC}"
        fi
    else
        echo -e "     --> Sendmail ${GREEN}already installed${CLASSIC}"
    fi

    echo ""
    sleep 1

    echo "## PHP installation"
    which php >/dev/null 2>&1
    if [[ ! $? -eq 0 ]]; then 
        echo -e "  -> PHP ${RED}not found${CLASSIC}"        
        echo "  -> Preparing system for PHP installation"
        apt install -y apt-transport-https lsb-release ca-certificates software-properties-common redis-server >/dev/null 2>&1
        REPO_SYSTEM_NAME=${SYSTEM_NAME,,}
        REPO_SYSTEM_CODENAME=${SYSTEM_CODENAME,,}
        echo "  -> Adding key and repo for $REPO_SYSTEM_NAME"
        case $REPO_SYSTEM_NAME in
            "debian")
                wget -q https://packages.sury.org/php/apt.gpg -O /etc/apt/trusted.gpg.d/php.gpg
                echo "deb https://packages.sury.org/php/ $REPO_SYSTEM_CODENAME main" > /etc/apt/sources.list.d/php.list
                apt-get update >/dev/null 2>&1
                echo -e "   -> Ondrej PHP Repo added ${GREEN}successfully${CLASSIC} for Debian"
                ;;
            "ubuntu")
                apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C >/dev/null 2>&1
                add-apt-repository -y ppa:ondrej/php >/dev/null 2>&1
                # echo -e "deb http://ppa.launchpad.net/ondrej/php/$REPO_SYSTEM_NAME $REPO_SYSTEM_CODENAME main" > /etc/apt/sources.list.d/php.list
                apt-get update >/dev/null 2>&1
                echo -e "   -> Ondrej PHP Repo added ${GREEN}successfully${CLASSIC} for Ubuntu"
                ;;
            *)
                echo -e "   -> Your system ${RED}is not yet${CLASSIC} supported"
                exit 1
                ;;
        esac
        echo -e "   -> Installing PHP packages, please wait..."    
        apt-get install -y php7.0-xsl php-redis php7.0-xmlwriter php7.0-xmlrpc php7.0-xmlreader php7.0-wddx php7.0-soap php7.0-sockets php7.0-shmop php7.0-simplexml php7.0-igbinary php7.0-imagick php7.0-json php7.0-icon php7.0-gd php7.0-ftp php7.0-fileinfo php7.0-exif php7.0-dom php7.0-ctype php7.0-pdo php7.0-gettext php7.0-mysqlnd php7.0-calendar php7.0-curl php7.0-iconv php7.0-intl php7.0-pdo php7.0-phar php7.0-posix php7.0-readline php7.0-sysvmsg php7.0-sysvsem php7.0-sysvshm php7.0-tokenizer php7.0-wddx php7.0 php7.0-fpm php7.0-mail php7.0-mysql php7.1-xsl php7.1-xmlwriter php7.1-xmlrpc php7.1-xmlreader php7.1-wddx php7.1-soap php7.1-sockets php7.1-shmop php7.1-simplexml php7.1-igbinary php7.1-imagick php7.1-json php7.1-icon php7.1-gd php7.1-ftp php7.1-fileinfo php7.1-exif php7.1-dom php7.1-ctype php7.1-pdo php7.1-gettext php7.1-mysqlnd php7.1-calendar php7.1-curl php7.1-iconv php7.1-intl php7.1-pdo php7.1-phar php7.1-posix php7.1-readline php7.1-sysvmsg php7.1-sysvsem php7.1-sysvshm php7.1-tokenizer php7.1-wddx php7.1 php7.1-fpm php7.1-mail php7.1-mysql php7.2-xsl php7.2-xmlwriter php7.2-xmlrpc php7.2-xmlreader php7.2-wddx php7.2-soap php7.2-sockets php7.2-shmop php7.2-simplexml php7.2-igbinary php7.2-imagick php7.2-json php7.2-icon php7.2-gd php7.2-ftp php7.2-fileinfo php7.2-exif php7.2-dom php7.2-ctype php7.2-pdo php7.2-gettext php7.2-mysqlnd php7.2-calendar php7.2-curl php7.2-iconv php7.2-intl php7.2-pdo php7.2-phar php7.2-posix php7.2-readline php7.2-sysvmsg php7.2-sysvsem php7.2-sysvshm php7.2-tokenizer php7.2-wddx php7.2 php7.2-fpm php7.2-mail php7.2-mysql php7.3-xsl php7.3-xmlwriter php7.3-xmlrpc php7.3-xmlreader php7.3-wddx php7.3-soap php7.3-sockets php7.3-shmop php7.3-simplexml php7.3-igbinary php7.3-imagick php7.3-json php7.3-icon php7.3-gd php7.3-ftp php7.3-fileinfo php7.3-exif php7.3-dom php7.3-ctype php7.3-mail php7.3-pdo php7.3-gettext php7.3-mysqlnd php7.3-calendar php7.3-curl php7.3-iconv php7.3-intl php7.3-pdo php7.3-phar php7.3-posix php7.3-readline php7.3-sysvmsg php7.3-sysvsem php7.3-sysvshm php7.3-tokenizer php7.3-wddx php7.3 php7.3-fpm php7.3-mysql php7.3-mysqli >/dev/null 2>&1
        apt-get remove -y php-mailparse >/dev/null 2>&1
        apt-get purge -y php-mailparse >/dev/null 2>&1
        echo -e "   -> Disabling log_errors in PHP CLI"   
        sed -i 's/log_errors\ \=\ On/log_erros\ \=\ Off/g' /etc/php/7.0/cli/php.ini >/dev/null 2>&1
        sed -i 's/log_errors\ \=\ On/log_erros\ \=\ Off/g' /etc/php/7.1/cli/php.ini >/dev/null 2>&1
        sed -i 's/log_errors\ \=\ On/log_erros\ \=\ Off/g' /etc/php/7.2/cli/php.ini >/dev/null 2>&1
        sed -i 's/log_errors\ \=\ On/log_erros\ \=\ Off/g' /etc/php/7.3/cli/php.ini >/dev/null 2>&1
        echo -e "  -> Modifying default version for PHP CLI"
        case $PHP_VERSION_INSTALLED in
            ALL)
                update-alternatives --set php /usr/bin/php7.2 >/dev/null 2>&1
                ;;
            *)
                update-alternatives --set php /usr/bin/php$PHP_VERSION_INSTALLED >/dev/null 2>&1
                ;;
        esac
    else
        PHP_INSTALLED_VERSION=$(php --version | head -1 | grep PHP | cut -d\  -f2 | cut -d\+ -f1)
        echo -e "  -> PHP : ${GREEN}OK${CLASSIC} - CLI Version $PHP_INSTALLED_VERSION"
    fi
    export PHP_BIN=$(which php)

    # echo ""
    # sleep 1

    # if (whiptail --title "Cloudflare" --yesno "Would you like to use Cloudflare for DNS Challenge ? " 10 80) then
    #     echo "## Creating Cloudflare Config File"
    #     export DNS_MANAGER="cloudflare"
    #     cloudflareAccoundChecker
    #     case ${CF_TESTER_RESULT} in
    #         true)
    #             echo -e "   -> Cloudflare account ${GREEN}validated${CLASSIC} - ID ${CF_TESTER_ACCOUNT_ID}"
    #             rm -f /root/.cloudflare.ini && touch /root/.cloudflare.ini
    #             echo "dns_cloudflare_email = ${CF_ACCOUNT_EMAIL}" >> $CLOUDFLARE_CREDS_FILE
    #             echo "dns_cloudflare_api_key = ${CF_ACCOUNT_APIKEY}" >> $CLOUDFLARE_CREDS_FILE
    #             chmod 400 $CLOUDFLARE_CREDS_FILE
    #             ;;
    #         false)
    #             echo -e "   -> Cloudflare account ${RED}couldn't${CLASSIC} be validated"
    #             cloudflareAccoundChecker nook
    #             ;;
    #         *)
    #             echo -e "   -> Cloudflare account ${RED}couldn't${CLASSIC} be validated"
    #             ;;
    #     esac
    # else
    #     export DNS_MANAGER="external"
    # fi

    echo ""
    sleep 1

    echo "## Applying configuration for ProFTPd"
    PROFTPD_PASSWD_FILE="/etc/proftpd/ftpd.passwd"
    PROFTPD_CONF_FILE="/etc/proftpd/proftpd.conf"
    export SYSTEMCTL_BIN=$(which proftpd)
    if [[ ! -f $PROFTPD_PASSWD_FILE ]]; then
        echo "  -> Creating ProFTPd password file"
        touch $PROFTPD_PASSWD_FILE
        chmod 400 $PROFTPD_PASSWD_FILE
    fi
    sed -i '/# authorder/Id' $PROFTPD_CONF_FILE
    sed -i '/authorder/Id' $PROFTPD_CONF_FILE
    sed -i '/authuserfile/Id' $PROFTPD_CONF_FILE
    echo "  -> Change auth type to virtual user"
    echo "Authorder                       mod_auth_file.c mod_auth_unix.c" >> $PROFTPD_CONF_FILE
    echo "AuthUserFile                    /etc/proftpd/ftpd.passwd" >> $PROFTPD_CONF_FILE
    echo "  -> Restarting service"
    systemctl restart proftpd.service

    echo ""
    sleep 1

    echo "## Applying some custom configurations and tuning to WebServer"
    if [[ ! -d /etc/nginx/snippets ]]; then
        mkdir /etc/nginx/snippets
    fi

    echo "  -> Applying security config for Let's Encrypt / SSL and custom for Nginx"
    if [[ ! -f /etc/nginx/snippets/letsencrypt.conf ]]; then
        cp -f $(dirname "$0")/common/nginx/snippets/letsencrypt.conf /etc/nginx/snippets/letsencrypt.conf
        cp -f $(dirname "$0")/common/nginx/snippets/exclusion.conf /etc/nginx/snippets/exclusion.conf
        cp -f $(dirname "$0")/common/nginx/snippets/errors.conf /etc/nginx/snippets/errors.conf
        cp -f $(dirname "$0")/common/nginx/snippets/static_files.conf /etc/nginx/snippets/static_files.conf
        cp -f $(dirname "$0")/common/nginx/snippets/open_file_cache.conf /etc/nginx/snippets/open_file_cache.conf
        cp -f $(dirname "$0")/common/nginx/snippets/fastcgi_cache.conf /etc/nginx/snippets/fastcgi_cache.conf
        cp -f $(dirname "$0")/common/nginx/snippets/fastcgi-php.conf /etc/nginx/snippets/fastcgi-php.conf
    fi

    echo ""
    sleep 1
    
    echo "## Checking for WP-CLI binaries"
    which wp >/dev/null 2>&1
    if [[ ! $? -eq 0 ]]; then
        cd /tmp
        echo "  -> Downloading WP-CLI"
        curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        echo "  -> Installing WP-CLI"
        chmod +x wp-cli.phar
        mv wp-cli.phar /usr/local/bin/wp
    else
        echo "  -> Found WP-CLI binaries"
    fi

    echo ""
    sleep 1

    if [[ ! -f /etc/ssl/certs/dhparam.pem ]] && [[ "$1" != "dryrun" ]]; then
        echo "## Checking for dhparam key"
        OPENSSL_BIN=$(which openssl)
        ${OPENSSL_BIN} dhparam -out /etc/ssl/certs/dhparam.pem 4096
        echo -e "  -> DHPARAM ${GREEN}successfully${CLASSIC} generated"
    else
        echo -e "  -> DHPARAM ${GREEN}already${CLASSIC} generated"
    fi
    
    echo ""
    sleep 1

    case $1 in
        "dryrun")
            echo "  -> Dryrun mode, no Cloudflare check"
            ;;
        *)
            cloudflareRealIPConfiguration
            ;;
    esac

   

    echo ""
    sleep 1

    echo "## Creating configuration file"
    if [[ ! -d /etc/sitedeploy ]]; then
        mkdir -p /etc/sitedeploy
    fi
    if [[ -f $SD_CONF_FILE ]]; then
        rm -f $SD_CONF_FILE
    fi
    touch $SD_CONF_FILE
    echo "## Site deploy configuration file" >> $SD_CONF_FILE
    echo "" >> $SD_CONF_FILE
    echo "[GENERAL]" >> $SD_CONF_FILE
    echo "OS_SYSTEM_NAME=$SYSTEM_NAME" >> $SD_CONF_FILE
    echo "OS_SYSTEM_CODENAME=$SYSTEM_CODENAME" >> $SD_CONF_FILE
    echo "OS_SYSTEM_VERSION=$SYSTEM_VERSION" >> $SD_CONF_FILE
    echo "" >> $SD_CONF_FILE
	echo "  -> Config file created"
    echo "[WP-PLUGINS]" >> ${SD_CONF_FILE}
    echo "WP_DEFAULT_PLUGINS=regenerate-thumbnails hide-admin-bar loco-translate wp-mail-smtp invisible-recaptcha wp-maintenance-mode akismet backwpup disable-gutenberg" >> $SD_CONF_FILE
    echo "" >> ${SD_CONF_FILE}
    echo ""

    case $1 in
        "dryrun")
            newDeploy dryrun
            ;;
        *)
            checkConfigFile
            ;;
    esac
}

function checkConfigFile() {
    source $(dirname "$0")/functions/common.sh
    source $(dirname "$0")/functions/vars.sh
    source $(dirname "$0")/functions/nginx.sh

    if [[ -f /etc/sitedeploy/sitedeploy.conf ]]; then
        SYSTEM_CHECKER=$(whiptail --title "Site Deploy" --menu "Configuration file found !" 15 64 7 \
            "1" "Deploy new Website" \
            "2" "Generate new certificate" \
            "3" "Generate DHParam Key" \
            "4" "Modify default WP Plugin list" \
            "5" "Rollback the last deploy" \
            "6" "Recheck my system and generate a new config file" \
            "7" "Exit" \
            3>&1 1>&2 2>&3)
        exitstatus=$?
        case $SYSTEM_CHECKER in
            1)
                newDeploy
                ;;
            2)
                echo "  -> Generate new Certificate"
                ;;
            3)
                echo "  -> Generate DHPARAM key"
                if [[ ! -f /etc/ssl/certs/dhparam.pem ]]; then
                    echo "## Checking for dhparam key"
                    OPENSSL_BIN=$(which openssl)
                    ${OPENSSL_BIN} dhparam -out /etc/ssl/certs/dhparam.pem 4096
                    echo -e "  -> DHPARAM ${GREEN}successfully${CLASSIC} generated"
                else
                    echo -e "  -> DHPARAM ${GREEN}already${CLASSIC} generated"
                fi
                ;;
            4)
                if [[ -f ${SD_CONF_FILE} ]]; then
                    echo "  -> Modify Default WP plugin list"
                    echo "   -> To modify this list, please edit ${SD_CONF_FILE}"
                fi
                ;;
            5)
                rollback
                ;;
            6)
                echo "### Compatibility check starting"
                checkCompatibility
                ;;
            7)
                exit 1
                ;;
            *)
                exit 1
                ;;
        esac
    else
        echo "  -> Configuration file not found, continue to compatibility check"
        checkCompatibility
    fi
}