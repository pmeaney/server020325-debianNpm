#!/bin/bash

# Helper function to read user input with a default value
read_with_default() {
    local prompt="$1"
    local default="$2"
    local input
    
    echo -n "$prompt [$default]: "
    read input
    echo "${input:-$default}"
}

# Helper function to get a list of 1Password vaults
get_vaults() {
    op vault list --format=json | jq -r '.[].name'
}

# Helper function to get items in a vault
get_vault_items() {
    local vault="$1"
    op item list --vault "$vault" --format=json | jq -r '.[].title'
}

# Clear screen and show welcome message
clear
echo "=== SSH Key Setup and Management Tool ==="
echo "This script will help you set up SSH keys and configure various services."
echo

# GitHub PAT setup
echo "First, you'll need a GitHub Personal Access Token (PAT)"
echo "Please create one at: https://github.com/settings/tokens"
echo "Required scopes: admin:public_key, repo, read:org"
echo -n "Enter your GitHub PAT: "
read -s GITHUB_PAT
echo

# DigitalOcean Token setup
echo
echo "Next, you'll need a DigitalOcean API Token"
echo "Please create one at: https://cloud.digitalocean.com/account/api/tokens"
echo "Required scope: Full Access (Write)"
echo -n "Enter your DigitalOcean Token: "
read -s DO_TOKEN
echo

# 1Password vault selection
echo
echo "Available 1Password vaults:"
VAULTS=$(get_vaults)
echo "$VAULTS"
DEFAULT_VAULT=$(op vault list --format=json | jq -r '.[0].name')
VAULT=$(read_with_default "Select vault name" "$DEFAULT_VAULT")

# 1Password item selection
echo
echo "Items in selected vault:"
ITEMS=$(get_vault_items "$VAULT")
echo "$ITEMS"
DEFAULT_ITEM=$(op item list --vault "$VAULT" --format=json | jq -r '.[0].title')
ITEM_TITLE=$(read_with_default "Select or enter new item name" "$DEFAULT_ITEM")

# Email for SSH key
echo
echo -n "Enter email for SSH keys: "
read SSH_EMAIL

# Generate timestamp for unique identifiers
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Store tokens in 1Password
if op item get "$ITEM_TITLE" --vault "$VAULT" &>/dev/null; then
    echo "Updating existing item with tokens..."
    op item edit "$ITEM_TITLE" --vault "$VAULT" \
        "GH_PAT_${TIMESTAMP}[password]=$GITHUB_PAT" \
        "DO_TOKEN_${TIMESTAMP}[password]=$DO_TOKEN"
else
    echo "Creating new item with tokens..."
    op item create --vault "$VAULT" \
        --title "$ITEM_TITLE" \
        "GH_PAT_${TIMESTAMP}[password]=$GITHUB_PAT" \
        "DO_TOKEN_${TIMESTAMP}[password]=$DO_TOKEN"
fi

# Initialize DO and GH CLI tools
echo "Initializing DigitalOcean CLI..."
doctl auth init --context default --access-token "$DO_TOKEN"

echo "Initializing GitHub CLI..."
echo "$GITHUB_PAT" | gh auth login --with-token

# Generate and configure SSH keys
# [Rest of your existing SSH key generation and configuration code, 
# but using $TIMESTAMP instead of hardcoded dates and $SSH_EMAIL instead of hardcoded email]