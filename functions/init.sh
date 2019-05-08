function init() {
    source $(dirname "$0")/functions/vars.sh
    source $(dirname "$0")/functions/system.sh
    export IPV4=$(curl -s ip4.clara.net)

    clear
    echo -e "${WHITE}${BLUE}########${CLASSIC}################${CLASSIC}${RED}##########${CLASSIC}"
    echo -e "${WHITE}${BLUE}--------${CLASSIC}----------------${CLASSIC}${RED}----------${CLASSIC}"
    echo -e "${WHITE}${BLUE}########${CLASSIC} Site Deploy V2 ${CLASSIC}${RED}##########${CLASSIC}"
    echo -e "${WHITE}${BLUE}--------${CLASSIC}----------------${CLASSIC}${RED}----------${CLASSIC}"
    echo -e "${WHITE}${BLUE}########${CLASSIC}################${CLASSIC}${RED}##########${CLASSIC}"
    echo "##"
    echo "# Date : 2019/04/30"
    echo "# Maintainer : bilyb0y"
    echo "# Version : 2"
    echo "####"
    echo ""
    case $(whoami) in
        root)
            checkConfigFile
            ;;
        *)
            echo -e "${RED}## Please login as root to execute SiteDeploy !${CLASSIC}"
            echo "  -> Exiting"
            echo ""
            exit 1
            ;;
    esac
}
