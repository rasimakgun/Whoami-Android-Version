#########################################################################################
readonly config_dir="/usr/share/whoami/data"
readonly backup_dir="/usr/share/whoami/backups"
readonly tor_uid="$(id -u debian-tor)"
readonly trans_port="9040"
readonly dns_port="5353"
readonly virtual_address="10.192.0.0/10"
readonly non_tor="127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"
##########################################################################################
die() {
    
    exit 1
}
##########################################################################################
check_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        die 
    fi
}
##########################################################################################
check_settings() {
    declare -a dependencies=('tor' 'curl')

    for package in "${dependencies[@]}"; do
        if ! hash "${package}" 2>/dev/null; then
            die 
        fi
    done

    if [ ! -d "$backup_dir" ]; then
        die 
    fi

    if [ ! -d "$config_dir" ]; then
        die 
    fi

    if [[ ! -f /etc/tor/torrc ]]; then

        if ! cp -vf "$config_dir/torrc" /etc/tor/torrc &> /dev/null; then
            die 
        fi
    else
        
        grep -q -x 'VirtualAddrNetworkIPv4 10.192.0.0/10' /etc/tor/torrc
        local string1=$?

        grep -q -x 'AutomapHostsOnResolve 1' /etc/tor/torrc
        local string2=$?

        grep -q -x 'TransPort 9040 IsolateClientAddr IsolateClientProtocol IsolateDestAddr IsolateDestPort' /etc/tor/torrc
        local string3=$?

        grep -q -x 'SocksPort 9050' /etc/tor/torrc
        local string4=$?

        grep -q -x 'DNSPort 5353' /etc/tor/torrc
        local string5=$?

        if [[ "$string1" -ne 0 ]] ||
           [[ "$string2" -ne 0 ]] ||
           [[ "$string3" -ne 0 ]] ||
           [[ "$string4" -ne 0 ]] ||
           [[ "$string5" -ne 0 ]]; then

            if ! cp -vf /etc/tor/torrc "$backup_dir/torrc.backup" &> /dev/null; then
                die 
            fi

            if ! cp -vf "$config_dir/torrc" /etc/tor/torrc &> /dev/null; then
                die 
            fi
        fi
    fi

    systemctl --system daemon-reload

}
##########################################################################################
setup_iptables() {
    case "$1" in
        tor_proxy)

            if ! [[ -f /etc/iptables.rules ]]; then
                iptables-save > "$backup_dir/iptables.backup"
            fi

            iptables -F
            iptables -X
            iptables -t nat -F
            iptables -t nat -X

            iptables -t nat -A OUTPUT -d $virtual_address -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j REDIRECT --to-ports $trans_port

            iptables -t nat -A OUTPUT -d 127.0.0.1/32 -p udp -m udp --dport 53 -j REDIRECT --to-ports $dns_port

            iptables -t nat -A OUTPUT -m owner --uid-owner $tor_uid -j RETURN
            iptables -t nat -A OUTPUT -o lo -j RETURN

            for lan in $non_tor; do
                iptables -t nat -A OUTPUT -d $lan -j RETURN
            done

            iptables -t nat -A OUTPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j REDIRECT --to-ports $trans_port

            iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT
            iptables -A INPUT -i lo -j ACCEPT
            iptables -A INPUT -j DROP

            iptables -A FORWARD -j DROP

            iptables -A OUTPUT -m conntrack --ctstate INVALID -j DROP

            iptables -A OUTPUT -m state --state INVALID -j DROP
            iptables -A OUTPUT -m state --state ESTABLISHED -j ACCEPT

            iptables -A OUTPUT -m owner --uid-owner $tor_uid -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -m state --state NEW -j ACCEPT

            iptables -A OUTPUT -d 127.0.0.1/32 -o lo -j ACCEPT

            iptables -A OUTPUT -d 127.0.0.1/32 -p tcp -m tcp --dport $trans_port --tcp-flags FIN,SYN,RST,ACK SYN -j ACCEPT

            iptables -A OUTPUT -j DROP

            iptables -P INPUT DROP
            iptables -P FORWARD DROP
            iptables -P OUTPUT DROP

        ;;

        default)

            iptables -F
            iptables -X
            iptables -t nat -F
            iptables -t nat -X
            iptables -P INPUT ACCEPT
            iptables -P FORWARD ACCEPT
            iptables -P OUTPUT ACCEPT

            if ! [[ -f "${backup_dir}/iptables.backup" ]]; then
                iptables-restore < "${backup_dir}/iptables.backup"

            fi
        ;;
    esac
}
##########################################################################################
start() {
    check_root
    sleep 2
    check_settings

    if systemctl is-active tor.service >/dev/null 2>&1; then
        systemctl stop tor.service
    fi

    if ! cp -vf /etc/resolv.conf "$backup_dir/resolv.conf.backup" &> /dev/null ; then
        die 
    fi

    printf "%s\\n" "nameserver 127.0.0.1" > /etc/resolv.conf
    sleep 1

    sysctl -w net.ipv6.conf.all.disable_ipv6=1 &> /dev/null
    sysctl -w net.ipv6.conf.default.disable_ipv6=1 &> /dev/null

    if systemctl start tor.service 2>/dev/null; then
        sleep 1
    else
        die 
    fi

    setup_iptables tor_proxy

}
##########################################################################################
stop() {
    check_root

    sleep 2

    setup_iptables default

    systemctl stop tor.service

    if hash resolvconf 2>/dev/null; then
        resolvconf -u
    else
        cp -vf "$backup_dir/resolv.conf.backup" /etc/resolv.conf &> /dev/null
    fi
    sleep 1

    sysctl -w net.ipv6.conf.all.disable_ipv6=0 &> /dev/null
    sysctl -w net.ipv6.conf.default.disable_ipv6=0 &> /dev/null

    cp -vf "$backup_dir/torrc.backup" /etc/tor/torrc &> /dev/null

}
##########################################################################################
restart() {
    check_root

    if systemctl is-active tor.service >/dev/null 2>&1; then
        systemctl restart tor.service
        sleep 3

        check_ip
        exit 0
    else
        die 
    fi
}
##########################################################################################
main() {
    if [[ "$#" -eq 0 ]]; then
        exit 1
    fi

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -t | --tor)
                start
                ;;
            -c | --clearnet)
                stop
                ;;
            -r | --restart)
                restart
                exit 0
                ;;
            -- | -* | *)
                printf "%s\\n" "$prog_name: Invalid option '$1'"
                exit 1
                ;;
        esac
        shift
    done
}

main "$@"
