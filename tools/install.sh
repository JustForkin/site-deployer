#!/bin/bash

echo "# Starting install of Site Deployer"
git clone git@github.com:bilyboy785/site-deployer.git ~/site-deployer >/dev/null 2>&1
if [ -f ~/.zshrc ]
then
    echo 'alias deploy="bash ~/site-deployer/deploy.sh"' >> /root/.zshrc
    source /root/.zshrc
elif [ -f ~/.bashrc ]
then
    echo 'alias deploy="bash ~/site-deployer/deploy.sh"' >> /root/.bashrc
    source /root/.bashrc
fi