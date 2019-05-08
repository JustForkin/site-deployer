#!/bin/bash

case $(whoami) in
    root)
        echo "# Starting install of Site Deployer"
        git clone git@github.com:bilyboy785/site-deployer.git /opt/site-deployer
        if [ -f ~/.zshrc ]
        then
            BASHRC_FILE="~/.zshrc"
        elif [ -f ~/.bashrc ]
        then
            BASHRC_FILE="~/.bashrc"
        fi

        echo 'alias deploy="bash /opt/site-deployer/deploy.sh"' >> $BASHRC_FILE
        source $BASHRC_FILE
        ;;
    *)
        echo "-> Please execute as root !"
        ;;
esac
