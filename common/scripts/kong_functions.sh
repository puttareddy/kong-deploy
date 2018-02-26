#!/bin/bash

# api_name , upstream_url, strip_request_path: boolean, request_path
add_api_with_path() {
echo "add_api_with $1 $2 $3 $4"
curl -sS -i -X POST --url $KONG_IP/apis/ \
        --data "name=$1" \
        --data "upstream_url=$2" \
        --data "strip_request_path=$3" \
        --data "uris=$4"
}
# api_name , upstream_url, request_host
add_api_with_host() {
echo "add_api_with_host $1 $2 $3"
curl -sS -i -X POST --url $KONG_IP/apis/ \
        --data "name=$1" \
        --data "upstream_url=$2" \
        --data "hosts=$3"

}
# api_name or id
delete_api() {
echo "delete_api $1"
curl -sS -X DELETE $KONG_IP/apis/$1
}
# api_name or id
add_correlation_id() {
echo "add_correlation_id $1"
# Add unique request id generation
curl -sS -X POST $KONG_IP/apis/$1/plugins \
    --data "name=correlation-id" \
    --data "config.header_name=X-Request-ID" \
    --data "config.generator=uuid" \
    --data "config.echo_downstream=true"
}

# api_name or id, key_name( authorization/x-authorization(dsb) )
add_auth() {
echo "add_auth $1 $2"
#configure auth
curl -sS -X POST $KONG_IP/apis/$1/plugins \
    --data "name=key-auth" \
    --data "config.key_names=$2" \
    --data "config.hide_credentials=true"

}

# api_name or id
add_basic_auth() {
echo "add_basic_auth $1"
curl -sS -X POST $KONG_IP/apis/$1/plugins \
    --data "name=basic-auth" \
    --data "config.hide_credentials=true"
}

# Removes the querystring destination ( incoming from dsb )
# api_name or id
remove_destination_from_query() {
echo "remove_destination_from_query $1"
curl -sS -X POST $KONG_IP/apis/$1/plugins \
    --data "name=request-transformer" \
    --data "config.remove.querystring=destination"
}


# Removes the querystring destination and adds a clientType to the query string
# api_name, clientType(INTERNAL|EXTERNAL)
remove_destination_from_query_add_client_type() {
echo "remove_destination_from_query_add_client_type $1 $2"
curl -sS -X POST $KONG_IP/apis/$1/plugins \
    --data "name=request-transformer" \
    --data "config.remove.querystring=clientType" \
    --data "config.remove.querystring=destination" \
    --data "config.add.querystring=clientType:$2"
}

# Logs this endpoint
# api_name or id
add_log() {
echo "add_log $1 ${LOGSTASH_URL}"
curl -sS -X POST $KONG_IP/apis/$1/plugins \
    --data "name=http-log" \
    --data "config.http_endpoint=${LOGSTASH_URL}/kong/1" \
    --data "config.method=POST" \
    --data "config.timeout=1000" \
    --data "config.keepalive=1000"
}

whitelist_acl_groups() {
echo "whitelist_acl_groups $1 $2"
curl -sS -X POST $KONG_IP/apis/$1/plugins \
    --data "name=acl" \
    --data "config.whitelist=$2"
}
blacklist_acl_groups() {
echo "blacklist_acl_groups $1 $2"
curl -sS -X POST $KONG_IP/apis/$1/plugins \
    --data "name=acl" \
    --data "config.whitelist=$2"
}
# custom plugin usage
add_consumer_resolver() {
echo "add_consumer_resolver $1"
curl -sS -X POST $KONG_IP/apis/$1/plugins \
    --data "name=consumer_resolver"
}
