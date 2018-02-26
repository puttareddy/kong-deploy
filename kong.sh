#!/usr/bin/env bash
set -u

# Include common functions, if any
#source "./common/scripts/functions.sh"

# --- LOCAL COMMANDS ---

function configure_kong() #
{
    echo "Configuring kong..."
    config
    sh -c "KONG_HOST=${KONG_HOST} common/scripts/kong_configs.sh"
    sleep 90    
}

config()
{
    export KONG_HOST=http://localhost:8001
    export HTTPS_PORT=443
    export HTTP_PORT=80
}

# MAIN

# Simple hack to support "-h" and "--help" as the first argument
if [[ $# -eq 0 ]] || [[ "$1" =~ ^-+h.? ]]; then
  usage
fi

export KONG_VERSION=${KONG_VERSION:-latest}
export CASSANDRA_VERSION=${CASSANDRA_VERSION:-latest}
export LOGSTASH_VERSION=${LOGSTASH_VERSION:-latest}
