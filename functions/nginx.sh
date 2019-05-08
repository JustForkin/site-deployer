
function dhparam() {
    if [[ ! -f /etc/ssl/certs/dhparam.pem ]]; then
        echo "## Checking for dhparam key"
        if (whiptail --title "DHParam" --yesno "Would you like to generate a DHPARAM Key ? " 10 80) then
            OPENSSL_BIN=$(which openssl)
            ${OPENSSL_BIN} dhparam -out /etc/ssl/certs/dhparam.pem 4096
            echo -e "  -> DHPARAM ${GREEN}successfully${CLASSIC} generated"
        else
            echo -e "  -> Skipping DHPARAM generation"
            sed -i 's/^ssl_dhparam/#ssl_dhparam/g' /etc/nginx/snippets/letsencrypt.conf 
        fi
    else
        echo -e "  -> DHPARAM ${GREEN}already${CLASSIC} generated"
    fi
}