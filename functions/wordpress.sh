function wordpressdeploy() {
    source $(dirname "$0")/functions/vars.sh

    cd ${3}
    echo "   -> Downloading latest Wordpress version"
    wp core download --locale="${11}" --path="$3" --quiet --allow-root
    echo "   -> Creating configuration file with database connection"
    wp core config --path="${3}" --dbname="${8}" --dbhost="localhost" --dbuser="${9}" --dbpass="${10}" --dbprefix=wp_ --quiet --allow-root
    echo "   -> Installing Wordpress based on site title, url and administrator values"
    wp core install --path="${3}" --url="${2}" --title="${1}" --skip-plugins=hello-dolly --admin_user="${4}" --admin_password="${6}" --admin_email="${5}" --quiet --allow-root

    case ${WP_INSTALL_PLUGINS} in
        "yes")
            echo "   -> Installing base wordpress plugin"
            PLUGIN_LIST=$(cat ${SD_CONF_FILE} | grep "WP_DEFAULT_PLUGINS" | cut -d\= -f2)
            for plugin in $(echo $PLUGIN_LIST)
            do
                wp plugin install --path=$3 $plugin --activate --quiet --allow-root >/dev/null 2>&1
            done
            ;;
        *)
            echo "   -> No more plugin will be install"
            ;;
    esac

    mv $3/index.html $3/index.html.bak
    
    echo "wpusername=$4" >> ${SECRET_FILE}
    echo "wppassword=$6" >> ${SECRET_FILE}
}

function wordpressNewUser() {
    wp user create --path=$1 "$2" "$3" --role=administrator --user_pass=$6 --first_name=$4 --last_name=$5 --send-email --quiet --allow-root
    echo "secondwpusername=$2" >> ${SECRET_FILE}
    echo "secondwppassword=$6" >> ${SECRET_FILE}
}