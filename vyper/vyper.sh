#!/bin/sh

DATE_STR=$(date +'%d/%m/%Y %H:%M:%S')
STATUS=`ifconfig | grep "tun0"`;

IP_LOCAL=`ip r | grep 'link' | cut -d" " -f1`
IP_EXTER=`curl -s https://ifconfig.me`
IP_GATE=`ip r | grep default | cut -d" " -f3`

echo "IP_LOCAL ${IP_LOCAL}"
echo "IP_EXTER ${IP_EXTER}"
echo "IP_GATE ${IP_GATE}"

check_dante() {
    STATUS=`ps | grep "sockd -D" | grep -v "grep"`
    if [ ! -z "${STATUS}" ]; then
               echo "dante is working";
               return
    fi
    echo "STARTING DANTE"
    sockd
}

check_vpn() {
    if [ ! -z "${STATUS}" ]; then
            echo "${DATE_STR} VPN_OK";
            check_dante
            exit 0;
    fi

    echo "VPN OFFLINE. RESTARTING"
    openvpn --config /etc/openvpn/client.conf

    echo "WAITING FOR DEMON"
    sleep 20


    STATUS=`ifconfig | grep "tun0"`;
    if [ -z "${STATUS}" ]; then
            echo "${DATE_STR} VPN_BAD";
            exit 10000;
    fi
}

add_rules() {
    echo "CHECKING RULES"
# IF VPN IS DEFAULT
       STATUS=`ip rule | grep "${IP_LOCAL}"`
       if [ ! -z "${STATUS}" ]; then
               echo "rules are already there";
               return
       fi


       echo "ADDING RULES"
       ip rule add from $IP_LOCAL table 200
       ip rule add from $IP_EXTER table 200
       echo "ADDING ROUTE"
       ip route add table 200 default via $IP_GATE


# if vpn ISN't default
        #getting vyper ip
#        CURRENT_VYPER_IP=`ip addr show dev tun0 | grep "inet" | sed  -E "s/[ ]+/ /" | cut -d" " -f3 | cut -d"/" -f1 | head -n 1`;
#
#
#        STATUS=`ip rule | grep "${CURRENT_VYPER_IP}"`
#        if [ ! -z "${STATUS}" ]; then
#                echo "rules are already there";
#                return
#        fi
#
#        ip rule add from $CURRENT_VYPER_IP table 200
#        ip rule add to   $CURRENT_VYPER_IP table 200
#
#        ip route add default dev tun0 table 200
#
#        ip route del 8.8.8.8/32
#        ip route del 8.8.4.4/32
#        ip route add 8.8.8.8/32 via $CURRENT_VYPER_IP
#        ip route add 8.8.4.4/32 via $CURRENT_VYPER_IP
#
#        echo "IP RULES ADDED:"
#        ip rule
#        echo "ROUTE:"
#        ip route show
#        echo "ROUTE TABLE 200:"
#        ip route show table 200

}

check_vpn
add_rules
check_dante

