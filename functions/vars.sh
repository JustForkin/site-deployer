#!/bin/bash

export SCRIPT_PATH=$(dirname "$0")
export RED="\033[31m"
export GREEN="\033[32m"
export BLUE="\e[34m"
export WHITE="\e[1m"
export CLASSIC="\033[0m"
export SD_CONF_FILE="/etc/sitedeploy/sitedeploy.conf"
export CERTBOT_DNS_PLUGIN_OVH="/etc/sitedeploy/ovh.secret"
export PROFTPD_PASSWD_FILE="/etc/proftpd/ftpd.passwd"
export CERTBOT_DNS_PLUGIN_CLOUDFLARE="/etc/sitedeploy/cloudflare.secret"
export NGINXSITESAVDIR="/etc/nginx/sites-available"
export NGINXSITESENDIR="/etc/nginx/sites-enabled"
export WEBROOTDIR="/var/www/html"
export CLOUDFLARE_CREDS_FILE="/root/.cloudflare.ini"
export INDEXFILE="$(dirname "$0")/common/index.html"
export PHPPOOLFILE="$(dirname "$0")/common/pool.conf"
export HTTPVHOST="$(dirname "$0")/common/vhost-http.conf"
export HTTPSVHOST="$(dirname "$0")/common/vhost-https.conf"
export NORMALIZEVHOST="$(dirname "$0")/common/vhost-normalize.conf"
export LOGROTATESAMPLE="$(dirname "$0")/common/logrotate.conf"
export DBSCRIPTSRC="$(dirname "$0")/common/sql/database.sql"
export DBSCRIPTDEST="/tmp/database.sql"
export IPV4=$(curl -s ip4.clara.net)
export CERTBOT_BIN=$(which certbot)
export SYSTEMCTL_BIN=$(which systemctl)