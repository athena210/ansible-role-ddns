#!/bin/sh

config_dir="/etc/ddns.d"

alert() {
    # echo "$1"
    logger -t "ddns" "$1"
}


open_url() {
    # -4 or -6
    # url
    ipver="$1"
    url="$2"

    # echo ">>$ipver $url"
    if command -v curl 1> /dev/null; then
        echo curl "$ipver" --silent "$url" 1> /dev/null
        return $?
    elif command -v wget 1> /dev/null ; then
        echo wget "$ipver" --quiet -O - "$url" 1> /dev/null
        return $?
    fi
    alert "Neither curl nor wget is installed. DDNS update canceled"
    return 1
}


parse_config() {
    config_file="$1"

    [ "$(basename "$config_file")" = "example.conf" ] && return 0

    if [ ! -f "$config_file" ] || [ ! -r "$config_file" ] ; then
        alert "Can't open config: $config_file"
        return 0
    fi

    sed -n 's/^[\t ]*DDNS4_URL[\t ]*=[\t ]*\(.*\?\)[\t ]*$/\1/p' "$config_file" | while read -r DDNS_URL; do
        if open_url "-4" "$DDNS_URL" ; then
            alert "DNS ipv4 updated from $config_file"
        else
            alert "DNS4 ipv4 update failed from $config_file"
        fi
    done

    sed -n 's/^[\t ]*DDNS6_URL[\t ]*=[\t ]*\(.*\?\)[\t ]*$/\1/p' "$config_file" | while read -r DDNS_URL; do
        if open_url "-6" "$DDNS_URL" ; then
            alert "DNS ipv6 updated from $config_file"
        else
            alert "DNS4 ipv6 update failed from $config_file"
        fi
    done
}


ls -1 "$config_dir"/*.conf | while read -r fname; do
    parse_config "$fname"
done
