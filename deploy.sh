#!/bin/bash

source /etc/environment
source /opt/site-deployer/functions/vars.sh
source /opt/site-deployer/functions/system.sh
source /opt/site-deployer/functions/common.sh
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
        case $1 in
            "dryrun")
                checkConfigFile dryrun
                ::
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