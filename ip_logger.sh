#!/bin/bash

# Dep: nmap, ipcalc
# Usage: ./ip_logger.sh IP/MASK
# Objective: Know which ip is up in a network, and which ip is connecting and disconnecting

## FUNCTIONS

list_ip() {
    # List all ip in a network
    echo "Scanning network $1" >&2
    nmap -sP $network | grep "Nmap scan report for" | sed -E 's/Nmap scan report for ([0-9.]+).*/\1/g'
}

## INITIALIZATION

networks="$@"
# networks="192.168.1.0/24"
all_ips=""

for network in $networks; do
    all_ips="$all_ips $(list_ip $network)"
done

# make it in lineœ
all_ips=$(echo $all_ips)

echo "Ip in the network: $all_ips"

## LOOP

while true; do
    for network in $networks; do
        # List all ip in a network
        ips=$(list_ip $network)
        for ip in $ips; do
            if [[ ! $all_ips =~ $ip ]]; then
                echo "New ip: $ip"
                all_ips="$all_ips $ip"
            fi
        done
        for ip in $all_ips; do
            if [[ ! $ips =~ $ip ]]; then
                echo "Ip disconnected: $ip"
                all_ips=$(echo $all_ips | sed -E "s/$ip//g")
            fi
        done
    done
    echo "Waiting 30s..."
    sleep 30
done
