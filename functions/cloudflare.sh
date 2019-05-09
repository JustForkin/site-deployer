source $(readlink -f $(dirname $0))/functions/vars.sh

function checkingCFRecord() {
    MY_IP=$(curl -s ip4.clara.net)
    CF_EMAIL=$(cat ${CERTBOT_DNS_PLUGIN_CLOUDFLARE} | grep "dns_cloudflare_email" | cut -d\= -f2)
    CF_APIKEY=$(cat ${CERTBOT_DNS_PLUGIN_CLOUDFLARE} | grep "dns_cloudflare_api_key" | cut -d\= -f2)
    MAIN_DOMAIN=$(whiptail --title "Main Domain" --inputbox "First level domain name" 10 60 $1 3>&1 1>&2 2>&3)
    echo "  -> Getting domain Zone ID for $MAIN_DOMAIN"
    CF_ZONE_CHECK=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$MAIN_DOMAIN" -H "X-Auth-Email: $CF_EMAIL" -H "X-Auth-Key: $CF_APIKEY" -H "Content-Type: application/json")
    TEST_SUCCESS=$(echo $CF_ZONE_CHECK | jq '.success')
    if [[ "$TEST_SUCCESS" == "true" ]]; then
        CF_ZONE_ID=$(echo $CF_ZONE_CHECK | jq '.result[].id' | sed 's/\"//g')
        echo -e "    -> Zone ${GREEN}OK${CLASSIC} in Cloudflare with ID : $CF_ZONE_ID"
        ALIASES=$(whiptail --title "Aliases" --inputbox "Please type all your aliases" 10 60 $2 3>&1 1>&2 2>&3)
        echo "  -> Getting record ID for $ALIASES"
        for DOM in ${ALIASES[@]}
        do
            CF_RECORD_CHECK=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records?type=A&name=$DOM" -H "X-Auth-Email: $CF_EMAIL" -H "X-Auth-Key: $CF_APIKEY" -H "Content-Type: application/json")
            CF_RECORD_SUCCESS=$(echo $CF_RECORD_CHECK | jq '.success')
            CF_RECORD_COUNT=$(echo $CF_RECORD_CHECK | jq '.result_info.count')
            if [[ "$CF_RECORD_COUNT" == "0" ]]; then
                echo -e "   -> Record ${RED}not${CLASSIC} found in Cloudflare, creating type A with $MY_IP"
                createRecord "A" "$DOM" "$MY_IP" "$CF_ZONE_ID" "$CF_EMAIL" "$CF_APIKEY"
            else
                if [[ "$CF_RECORD_SUCCESS" == "true" ]]; then
                    CF_RECORD_ID=$(echo $CF_RECORD_CHECK | jq '.result[].id' | sed 's/\"//g')
                    echo -e "   -> Record ${GREEN}exist${CLASSIC} with ID $CF_RECORD_ID, checking IP Address"
                    CF_RECORD_IP_CHECK=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$CF_RECORD_ID" -H "X-Auth-Email: $CF_EMAIL" -H "X-Auth-Key: $CF_APIKEY" -H "Content-Type: application/json")
                    CF_RECORD_IP=$(echo $CF_RECORD_IP_CHECK | jq '.result.content' | sed 's/\"//g')
                    if [[ "$CF_RECORD_IP" == "$MY_IP" ]]; then
                        echo -e "     -> Record IP ${GREEN}is OK${CLASSIC} !"
                    else
                        echo -e "     -> Record IP ${RED}mismatch${CLASSIC} with My IP - Actual IP : $CF_RECORD_IP"
                        updateRecord "A" "$DOM" "$MY_IP" "$CF_RECORD_ID" "$CF_ZONE_ID" "$CF_EMAIL" "$CF_APIKEY"
                    fi
                else
                    CF_RECORD_CHECK=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records?type=CNAME&name=$DOM" -H "X-Auth-Email: $CF_EMAIL" -H "X-Auth-Key: $CF_APIKEY" -H "Content-Type: application/json")
                    CF_RECORD_SUCCESS=$(echo $CF_RECORD_CHECK | jq '.success')
                    if [[ "$CF_RECORD_SUCCESS" == "true" ]]; then
                        echo -e "   -> Record ${GREEN}exist${CLASSIC} in CNAME type, updating..."
                        updateRecord "A" "$DOM" "$MY_IP" "$CF_RECORD_ID" "$CF_ZONE_ID" "$CF_EMAIL" "$CF_APIKEY"
                    else
                        echo -e "   -> Record ${RED}doesn't exist${CLASSIC}, creating..."
                    fi
                fi
            fi
        done
    else
        echo -e "    -> Zone ${RED}not${CLASSIC} found in Cloudflare."
    fi
}

function createRecord() {
	CF_CREATE_RECORD_CHECK=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$4/dns_records" -H "X-Auth-Email: $5" -H "X-Auth-Key: $6" -H "Content-Type: application/json" --data "{\"type\":\"$1\",\"name\":\"$2\",\"content\":\"$3\"}")
	CF_CHECK_CREATE_RECORD=$(echo $CF_CREATE_RECORD_CHECK | jq '.success')
	if [[ "$CF_CHECK_CREATE_RECORD" == "true" ]]; then
            echo -e "    -> Record successfully created !"
    else
            echo -e "    -> Failed to create record !"
    fi
}

function updateRecord() {
	CF_UPDATE_RECORD_CHECK=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$5/dns_records/$4" -H "X-Auth-Email: $6" -H "X-Auth-Key: $7" -H "Content-Type: application/json" --data "{\"type\":\"$1\",\"name\":\"$2\",\"content\":\"$3\"}")
    CF_CHECK_UPDATE_RECORD=$(echo $CF_UPDATE_RECORD_CHECK | jq '.success')
    if [[ "$CF_CHECK_UPDATE_RECORD" == "true" ]]; then
        echo -e "     -> Record ${GREEN}successfully${CLASSIC} updated to $3 !"
    else
        echo -e "     -> ${RED}Failed${CLASSIC} to update record !"
    fi
}

function cloudflareRealIPConfiguration() {
    echo "## Downloading Cloudflare Real IP Configuration file"
    if [[ ! -d /etc/nginx ]]; then 
        mkdir -p /etc/nginx/snippets 
    fi
    if [[ ! -f /etc/nginx/snippets/cloudflare.conf ]]; then
        touch /etc/nginx/snippets/cloudflare.conf
    fi
    CLOUDFLARE_CONFIG_FILE="/etc/nginx/snippets/cloudflare.conf"
    IPV4LIST="https://www.cloudflare.com/ips-v4?utm_referrer=https://support.cloudflare.com/hc/fr-fr/articles/200170706-Comment-restaurer-l-adresse-IP-originale-du-visiteur-avec-Nginx-"
    IPV6LIST="https://www.cloudflare.com/ips-v6?utm_referrer=https://support.cloudflare.com/hc/fr-fr/articles/200170706-Comment-restaurer-l-adresse-IP-originale-du-visiteur-avec-Nginx-"

    echo "  -> Cleaning old configuration"
    echo "" > $CLOUDFLARE_CONFIG_FILE
    echo "  -> Updating IPV4..."
    echo "## IPV4" >> $CLOUDFLARE_CONFIG_FILE
    for ip in $(curl -s $IPV4LIST)
    do
        echo "set_real_ip_from $ip;" >> $CLOUDFLARE_CONFIG_FILE
    done
    echo "" >> $CLOUDFLARE_CONFIG_FILE
    echo "  -> Updating IPV6..."
    echo "## IPV6" >> $CLOUDFLARE_CONFIG_FILE
    for ip in $(curl -s $IPV6LIST)
    do
            echo "set_real_ip_from $ip;" >> $CLOUDFLARE_CONFIG_FILE
    done
    echo "  -> Adding more config..."
    echo "" >> $CLOUDFLARE_CONFIG_FILE
    echo "## Config" >> $CLOUDFLARE_CONFIG_FILE
    echo "real_ip_header CF-Connecting-IP;" >> $CLOUDFLARE_CONFIG_FILE
    echo "real_ip_recursive on;" >> $CLOUDFLARE_CONFIG_FILE
    echo "  -> Reloading Nginx"
    systemctl reload nginx.service
}

function cloudflareAccoundChecker() {
    source $(readlink -f $(dirname $0))/functions/vars.sh

    CF_TESTER=$(curl -sX GET "https://api.cloudflare.com/client/v4/accounts?page=1&per_page=20&direction=desc" -H "X-Auth-Email: $1" -H "X-Auth-Key: $2" -H "Content-Type: application/json")
    export CF_TESTER_RESULT=$(echo $CF_TESTER | jq '.success')
    case $CF_TESTER_RESULT in
        "true")
            echo -e "   -> ${GREEN}Cloudflare account successfully validated !${CLASSIC}"
            export CF_TESTER_ACCOUNT_ID=$(echo $CF_TESTER | jq '.result[].id' | sed 's/\"//g')
            export CF_ACCOUNT_APIKEY=$CLOUDFLARE_APIKEY
            export CF_ACCOUNT_EMAIL=$CLOUDFLARE_EMAIL
            ;;
        "false")
            echo -e "  -> ${RED}Failed during Cloudflare account checker, please edit the file ${CERTBOT_DNS_PLUGIN_CLOUDFLARE} and fix values${CLASSIC}"
            ;;
        *)
            ;;
    esac
    
}