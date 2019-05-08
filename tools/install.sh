#!/bin/bash

case $(whoami) in
    root)
        git clone https://github.com/bilyboy785/site-deployer.git /opt/site-deployer
        if [[ -f ~/.zshrc ]]; then
            BASHRC_FILE="~/.zshrc"
        fi

        if [[ -f ~/.bashrc ]]; then
            BASHRC_FILE="~/.bashrc"
        fi

        echo 'alias deploy="bash /opt/site-deployer/deploy.sh"' >> $BASHRC_FILE
        source $BASHRC_FILE
        ;;
    *)
        echo "-> Please execute as root !"
        ;;
esac
