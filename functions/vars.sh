#!/bin/bash

export MY_SCRIPT=$(readlink -f $0)
export MY_SCRIPT_PATH=`dirname $MY_SCRIPT`
export RED="\e[31m"
export ORANGE="\e[93m"
export GREEN="\e[32m"
export BLUE="\e[34m"
export WHITE="\e[1m"
export YELLOW="\e[33m"
export CLASSIC="\e[39m"
export SD_CONF_FILE="/etc/sitedeploy/sitedeploy.conf"
export CERTBOT_DNS_PLUGIN_OVH="/etc/sitedeploy/ovh.secret"
export PROFTPD_PASSWD_FILE="/etc/proftpd/ftpd.passwd"
export CERTBOT_DNS_PLUGIN_CLOUDFLARE="/etc/sitedeploy/cloudflare.secret"
export NGINXSITESAVDIR="/etc/nginx/sites-available"
export PHPFPM_MONITORING_VHOST="/etc/nginx/sites-enabled/000-phpfpm-status.conf"
export NGINXSITESENDIR="/etc/nginx/sites-enabled"
export WEBROOTDIR="/var/www/html"
export CLOUDFLARE_CREDS_FILE="/root/.cloudflare.ini"
export INDEXFILE="${MY_SCRIPT_PATH}/common/index.html"
export SNIPPETS_FILES="${MY_SCRIPT_PATH}/common/nginx/snippets"
export PHPPOOLFILE="${MY_SCRIPT_PATH}/common/pool.conf"
export HTTPVHOST="${MY_SCRIPT_PATH}/common/vhost-http.conf"
export HTTPSVHOST="${MY_SCRIPT_PATH}/common/vhost-https.conf"
export NORMALIZEVHOST="${MY_SCRIPT_PATH}/common/vhost-normalize.conf"
export LOGROTATESAMPLE="${MY_SCRIPT_PATH}/common/logrotate.conf"
export DBSCRIPTSRC="${MY_SCRIPT_PATH}/common/sql/database.sql"
export DBSCRIPTDEST="/tmp/database.sql"
export IPV4=$(curl -s ip4.clara.net)
export CERTBOT_BIN=$(which certbot)
export SYSTEMCTL_BIN=$(which systemctl)
