#!/bin/bash

# Exit on any error
set -e

# The 1Password item that contains all our secrets
ITEM_NAME="2025 Feb 020325 Debian project"

# Function to safely get 1Password fields
get_1p_field() {
    local field_label=$1
    local value
    
    value=$(op item get "$ITEM_NAME" --fields "label=$field_label")
    if [ -z "$value" ]; then
        echo "Error: Could not retrieve field $field_label from 1Password" >&2
        return 1
    fi
    echo "$value"
}

# DigitalOcean access token
export DIGITALOCEAN_ACCESS_TOKEN=$(get_1p_field "DIGITAL_OCEAN_TOKEN")

# Server name
export TF_VAR_LINUX_SERVER_NAME=$(get_1p_field "LINUX_SERVER_NAME")

# Human user secrets
export TF_VAR_LINUX_HUMAN_SSH_KEY_PUB_WITHPASS=$(get_1p_field "id_ed25519_withpass_DO_TF_HUMAN_PUB_SSH_KEY")
export TF_VAR_LINUX_USERNAME_DEVOPS_HUMAN=$(get_1p_field "LINUX_USERNAME_DEVOPS_HUMAN")
export TF_VAR_LINUX_USERPASSWORD_DEVOPS_HUMAN=$(get_1p_field "LINUX_USERPASSWORD_DEVOPS_HUMAN")

# CICD bot secrets
export TF_VAR_LINUX_GHACICD_BOT_SSH_KEY_PUB_NOPASS=$(get_1p_field "id_ed25519_nopass_GHACICD_BOT_PUB_SSH_KEY")
export TF_VAR_LINUX_USERNAME_GHA_CICD_BOT=$(get_1p_field "LINUX_USERNAME_GHA_CICD_BOT")

# 1Password information for storing server IP
export TF_VAR_VAULT_1P=$(get_1p_field "VAULT_1P")
export TF_VAR_ITEM_1P=$(get_1p_field "ITEM_1P")

# Verify all variables were set
echo "Verifying environment variables..."
vars_to_check=(
    "DIGITALOCEAN_ACCESS_TOKEN"
    "TF_VAR_LINUX_SERVER_NAME"
    "TF_VAR_LINUX_HUMAN_SSH_KEY_PUB_WITHPASS"
    "TF_VAR_LINUX_USERNAME_DEVOPS_HUMAN"
    "TF_VAR_LINUX_USERPASSWORD_DEVOPS_HUMAN"
    "TF_VAR_LINUX_GHACICD_BOT_SSH_KEY_PUB_NOPASS"
    "TF_VAR_LINUX_USERNAME_GHA_CICD_BOT"
    "TF_VAR_VAULT_1P"
    "TF_VAR_ITEM_1P"
)

for var in "${vars_to_check[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set" >&2
        exit 1
    fi
done

echo "All environment variables successfully exported"