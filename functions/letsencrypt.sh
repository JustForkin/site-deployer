function newCertbot() {
        source $(readlink -f $(dirname $0))/functions/vars.sh

        case $1 in
                "dns")
                        case $2 in
                                "ovh")
                                        export CERTBOT_OPTION="--dns-ovh --dns-ovh-credentials /etc/sitedeploy/ovh.secret --agree-tos -m $4 --rsa-key-size $5 --quiet"
                                        ;;
                                "cloudflare")
                                        export CERTBOT_OPTION="--dns-cloudflare --dns-cloudflare-credentials /etc/sitedeploy/cloudflare.secret --agree-tos -m $4 --rsa-key-size $5 --quiet"
                                        ;;
                                *)
                                        export CERTBOT_OPTION="--agree-tos -m $4 --rsa-key-size $5 --quiet"
                                        ;;
                        esac
                        ;;
                "http")
                        export CERTBOT_OPTION="--agree-tos -m $4 --rsa-key-size $5 --quiet"
                        ;;
                *)
                        export CERTBOT_OPTION="--agree-tos -m $4 --rsa-key-size $5 --quiet"
                        ;;
        esac

        CERTBOT_BIN=$(which certbot)
        echo "   -> Generating certificate for ${DOM_REDIRECT}"
        ${CERTBOT_BIN} certonly ${CERTBOT_OPTION} -d $3
        if [[ -f /etc/letsencrypt/live/$6/fullchain.pem ]]; then
                EXPIRE_DATE=$(openssl x509 -enddate -noout -in  /etc/letsencrypt/live/$6/fullchain.pem | cut -d\= -f2)
                echo -e "     --> SSL Certificate ${GREEN}successfully generated${CLASSIC}"
                echo -e "     --> Expire date : $EXPIRE_DATE"
        else
                echo -e "     --> ${RED}Failed${CLASSIC} to generate certificate"
        fi
}