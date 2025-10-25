#!/bin/sh

config_dir="/etc/ddns.d"

alert() {
    # echo "$1"
    logger -t "ddns" "$1"
}

parse_config() {
    config_file="$1"

    [ "$(basename "$config_file")" = "example.conf" ] && return 0

    if [ ! -f "$config_file" ] || [ ! -r "$config_file" ] ; then
        alert "Can't open config: $config_file"
        return 0
    fi

    sed -n 's/^[\t ]*DDNS_URL[\t ]*=[\t ]*\(.*\?\)[\t ]*$/\1/p' "$config_file" | while read -r DDNS_URL; do

        # echo ">> $DDNS_URL"
        ret=9
        if command -v curl 1> /dev/null; then
            curl --silent "$DDNS_URL" 1> /dev/null
            ret=$?
        elif command -v wget 1> /dev/null ; then
            wget --quiet -O - "$DDNS_URL" 1> /dev/null
            ret=$?
        else
            alert "Neither curl nor wget is installed. DDNS update canceled"
            return 1
        fi

        if [ "$ret" -eq 0 ] ; then
            alert "DNS updated from $config_file"
        else
            alert "DNS update failed from $config_file"
        fi
    done
}

ls "$config_dir"/*.conf | while read -r fname; do
    parse_config "$fname"
done
