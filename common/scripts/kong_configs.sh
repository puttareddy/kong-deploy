#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/kong_functions.sh

if [ -z "$KONG_HOST" ]; then
    echo "KONG_HOST is not set";
    exit 1 
else 
    echo "Updating kong at $KONG_HOST ";
fi

KONG_IP=$KONG_HOST

# Remove existing routes
ALL_APIS="go-microservice"
AUTH_RESTRICTED_APIS=""

configure_users() {
    # Create basic auth consumer
    curl -sS -X POST $KONG_IP/consumers/ \
        --data "username=consul"
    if [ `echo $?` -eq 0 ]; then
    curl -sS -X POST $KONG_IP/consumers/consul/basic-auth \
        --data "username=consul" \
        --data "password=${BASIC_AUTH_PASSWORD}"
    fi
}

start () {
    # Delete existing APIS
    for api in $ALL_APIS; do
        delete_api $api
    done

    for api in $AUTH_RESTRICTED_APIS; do
        delete_api $api
    done

    # Add the routes
    add_api_with_host go-microservice http://go-microservice.apps.svc.cluster.local:8080 "example-service.com"
    #add_api_with_host "client_docs" "http://client_docs:3000" "client-aws-blueocean.com"
    #add_api_with_path loans_summary http://loans-service:8080/loans true /api/loans
    #add_api_with_path loans_details http://loans-service:8080/loans/{id} true /ppc/loans/{id}

    for api in $ALL_APIS; do
        add_correlation_id $api
        add_log $api
        add_auth $api authorization
        # Add accept-encoding header for some responses that are going to directly to the DSB are not coming back with the proper encoding header
        curl -sS -X POST $KONG_IP/apis/$api/plugins \
            --data "name=request-transformer" \
            --data "config.append.headers=Accept-Encoding:application/json"
    done

    for api in $AUTH_RESTRICTED_APIS; do
        add_correlation_id $api
        add_log $api
        add_basic_auth $api
    done

    # Whitelist {api} {group(s)}
    whitelist_acl_groups loans_summary loans_summary
    
    # This is a custom plug-in. Just for reference
    add_consumer_resolver loans_summary
  
    configure_users
}

start



