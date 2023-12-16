#!/bin/bash

# Script to create a cloudflared tunnel deployment yaml file for k8s

# Check if a replacement name is provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <tunnel-name> <public-hostname> <protocol-service-port> <namespace>"
    echo "Example:"
    echo "gen-cf-tun-deploy.sh cf-tun-hello hello.examples.com http://k8s-svc-in-same-ns:5000 production"
    echo
    exit 1
fi

REPLACEMENT_NAME=$1
PUBLIC_HOSTNAME=$2
SERVICE_PORT="$3"
NAMESPACE=$4
TEMPLATE_FILE="cf-tun-template.yaml"
OUTPUT_FILE="deploy-${REPLACEMENT_NAME}.yaml"

# Escape forward slashes in SERVICE_PORT
ESCAPED_SERVICE_PORT=$(echo $SERVICE_PORT | sed 's/\//\\\//g')

# Check if the template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Error: File '$TEMPLATE_FILE' does not exist."
    exit 1
fi

# Save the output to deploy-cloudflare-tunnel-name.yaml
# Replace CF-TUN-NAME, PUBLIC_HOSTNAME, and PROTOCOL_KUBERNETES_SERVICE_PORT with the provided arguments
sed -e "s/CF-TUN-NAME/$REPLACEMENT_NAME/g" -e "s/PUBLIC_HOSTNAME/$PUBLIC_HOSTNAME/g" \
  -e "s/DESIRED_NAMESPACE/$NAMESPACE/g" -e "s/PROTOCAL_SVC_PORT/$ESCAPED_SERVICE_PORT/g" \
  "$TEMPLATE_FILE" > "$OUTPUT_FILE"

echo
echo "https://github.com/hongyanca/shell-script-utilities/blob/main/cf-tun-secret/cftun-token-to-json.sh"
echo "Use cftun-token-to-json.sh to convert cloudflared tunnel token to credentials.json file:"
echo "cftun-token-to-json.sh eyJhIjoiZBD1MGM4YjU3MG... > credentials.json"
echo
echo "Create a k8s secret from credentials.json file:"
echo "kubectl -n $NAMESPACE create secret generic $REPLACEMENT_NAME --from-file=credentials.json"
echo
echo "Deploy the cloudflared tunnel:"
echo "kubectl apply -f $OUTPUT_FILE"
echo