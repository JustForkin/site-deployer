#!/bin/bash

IPV4=$(curl -s ip4.clara.net)
MY_SCRIPT=$(readlink -f $0)
MY_SCRIPT_PATH=`dirname $MY_SCRIPT`
export MY_SCRIPT_PATH
export IPV4

# shellcheck disable=SC1091
source /etc/environment
source ${MY_SCRIPT_PATH}/functions/vars.sh
source ${MY_SCRIPT_PATH}/functions/system.sh
source ${MY_SCRIPT_PATH}/functions/common.sh

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
        case $1 in
            dryrun)
                checkCompatibility dryrun
                ;;
            *)
                checkConfigFile
                ;;
        esac
        ;;
    *)
        echo -e "${RED}## Please login as root to execute SiteDeploy !${CLASSIC}"
        echo "  -> Exiting"
        echo ""
        exit 1
        ;;
esac