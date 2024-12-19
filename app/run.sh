#!/bin/bash

# 定義關閉 VPN 的函數
shutdown_vpn() {
    echo "Shutting down VPN server..."
    /app/vpnserver stop
    EXIT_FLAG=1
    exit 0
}

execute_command() {
    local HOST_PORT="localhost"
    local type="SERVER"
    local command=$1
    local parameters=$2
    local password=""
    local extra_arguments=$3
    local VPNCMD_PATH="/app/vpncmd"

    local args="$HOST_PORT /PASSWORD:$password /$type /CSV $extra_arguments /CMD $command $parameters"
    local output
    local error

    output=$(mktemp)
    error=$(mktemp)

    $VPNCMD_PATH $args >"$output" 2>"$error" &
    local pid=$!
    local timeout=30

    while [ $timeout -gt 0 ]; do
        if ! kill -0 $pid 2>/dev/null; then
            break
        fi
        sleep 1
        timeout=$((timeout - 1))
    done

    if kill -0 $pid 2>/dev/null; then
        kill -9 $pid
        rm -f "$output" "$error"
        echo "Timeout"
        return 1
    fi

    local result=$(cat "$output")
    local result2=$(cat "$error")
    rm -f "$output" "$error"

    if [ -n "$result2" ]; then
        echo "$result2"
        return 1
    fi

    echo "$result"
    return 0
}


main() {
    export LD_LIBRARY_PATH=/temp
    mkdir -p /app
    cd /app
    ln -sf /temp/* /app/
    # 捕捉退出信號 (例如 SIGTERM)
    trap 'shutdown_vpn' SIGTERM
    
    echo "Starting VPN server..."
    /app/vpnserver start
    echo "VPN server started."


    if [ -n "$VPN_SERVER_PASSWORD" ]; then
        echo "Set VPN Server Password"
        execute_command "ServerPasswordSet" "$VPN_SERVER_PASSWORD"
        unset VPN_SERVER_PASSWORD
        
    fi


    while true; do
        sleep 1
    done
}

main