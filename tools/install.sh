#!/bin/bash

CURRENT_USER=$(whoami)

if [ "$CURRENT_USER" = "root" ]
then
    echo "# Starting install of Site Deployer"
    git clone git@github.com:bilyboy785/site-deployer.git $(dirname "$0") >/dev/null 2>&1
    if [ -f ~/.zshrc ]
    then
        echo 'alias deploy="bash $(dirname "$0")/deploy.sh"' >> /root/.zshrc
        source /root/.zshrc
    elif [ -f ~/.bashrc ]
    then
        echo 'alias deploy="bash $(dirname "$0")/deploy.sh"' >> /root/.bashrc
        source /root/.bashrc
    fi
else
    echo "-> Please execute as root !"
fi
