#!/bin/bash

echo "# Starting install of Site Deployer"
git clone git@github.com:bilyboy785/site-deployer.git ~/site-deployer >/dev/null 2>&1
if [ -f ~/.zshrc ]
then
    echo 'alias deploy="bash ~/site-deployer/deploy.sh"' >> /root/.zshrc
    # shellcheck disable=SC1091
    source /root/.zshrc
elif [ -f ~/.bashrc ]
then
    echo 'alias deploy="bash ~/site-deployer/deploy.sh"' >> /root/.bashrc
    # shellcheck disable=SC1091
    source /root/.bashrc
fi