#!/bin/bash
# Check if yq is installed
if ! [ -x "$(command -v yq)" ]; then
    echo "yq is not installed. Please install yq" >&2
    echo "Installing yq:"
    sudo curl -L "https://github.com/mikefarah/yq/releases/download/v4.41.1/yq_linux_$(dpkg --print-architecture)" -o /usr/local/bin/yq
    sudo chmod +x /usr/local/bin/yq
fi

# Path to the kube-apiserver.yaml file
FILE="/etc/kubernetes/manifests/kube-apiserver.yaml"

# Convert the YAML file to JSON
json=$(yq -o=json . "$FILE")

# Extract the value of --advertise-address
advertise_address=$(echo "$json" | jq -r '.spec.containers[0].command[] | select(startswith("--advertise-address="))' | cut -d'=' -f2)

# Check if the --bind-address line already exists
bind_address_index=$(echo "$json" | jq -r '.spec.containers[0].command | map(startswith("--bind-address=")) | index(true)')
if [ "$bind_address_index" == "null" ]; then
    # If it doesn't exist, add the line to the file
    json=$(echo "$json" | jq ".spec.containers[0].command += [\"--bind-address=${advertise_address}\"]")
else
    # If it already exists, replace it with the new value
    json=$(echo "$json" | jq ".spec.containers[0].command[$bind_address_index] = \"--bind-address=${advertise_address}\"")
fi

# Convert the JSON back to YAML and write the result to the file
echo "$json" | yq -p json . > "$FILE"
