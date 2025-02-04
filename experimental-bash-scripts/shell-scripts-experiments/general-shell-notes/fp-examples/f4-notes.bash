
# The idea behind the script was to auto-create 1pass secrets, upload ssh keys to DO & GH,
# and eventually other things.  Might return to finish it-- needed to work on other things.
# 
# echo "This script will do the following:"
# echo "Section 1."
# echo " - CLI Login to DigitalOcean, Github for upcoming operations (ssh key upload)"
# echo " - Create ssh keys for the terraform project (DigitalOcean, Github)"
# echo " - Upload those ssh keys to DigitalOcean, Github"


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

# Function to get timestamp-based names
get_timestamp_suffix() {
    date +%m%d%y
}

# Function to setup GitHub PAT
setup_github_pat() {
    echo "First, you'll need a GitHub Personal Access Token (PAT)"
    echo "Please create one at: https://github.com/settings/tokens"
    echo "Required scopes: admin:public_key, repo, read:org"
    echo -n "Enter your GitHub PAT: "
    read -s GITHUB_PAT
    echo
    echo "$GITHUB_PAT"
}

# Function to setup DigitalOcean token
setup_do_token() {
    echo
    echo "Next, you'll need a DigitalOcean API Token"
    echo "Please create one at: https://cloud.digitalocean.com/account/api/tokens"
    echo "Required scope: Full Access (Write)"
    echo -n "Enter your DigitalOcean Token: "
    read -s DO_TOKEN
    echo
    echo "$DO_TOKEN"
}

# Function to select or create 1Password vault
select_or_create_vault() {
    local timestamp_suffix=$(get_timestamp_suffix)
    local default_vault_name="server-${timestamp_suffix}"
    
    echo "Would you like to:"
    echo "1. Use an existing vault"
    echo "2. Create a new vault"
    read -p "Enter your choice (1 or 2): " vault_choice
    
    case $vault_choice in
        1)
            echo "Available vaults:"
            VAULTS=$(get_vaults)
            echo "$VAULTS"
            read_with_default "Select vault name" "$(op vault list --format=json | jq -r '.[0].name')"
            ;;
        2)
            read_with_default "Enter new vault name" "$default_vault_name"
            op vault create "$REPLY" >/dev/null 2>&1
            echo "$REPLY"
            ;;
        *)
            echo "Invalid choice. Defaulting to existing vault selection..."
            select_or_create_vault
            ;;
    esac
}

# Function to select or create 1Password item
select_or_create_item() {
    local vault="$1"
    local timestamp_suffix=$(get_timestamp_suffix)
    local default_item_name="Keys-for-server-${timestamp_suffix}"
    
    echo "Would you like to:"
    echo "1. Use an existing item"
    echo "2. Create a new SecureNote item"
    read -p "Enter your choice (1 or 2): " item_choice
    
    case $item_choice in
        1)
            echo "Items in selected vault:"
            ITEMS=$(get_vault_items "$vault")
            echo "$ITEMS"
            read_with_default "Select item name" "$(op item list --vault "$vault" --format=json | jq -r '.[0].title')"
            ;;
        2)
            read_with_default "Enter new item name" "$default_item_name"
            ;;
        *)
            echo "Invalid choice. Defaulting to existing item selection..."
            select_or_create_item "$vault"
            ;;
    esac
}

# Function to get custom field names
get_field_names() {
    local timestamp_suffix=$(get_timestamp_suffix)
    local default_do_token_name="DO_TOKEN_${timestamp_suffix}"
    local default_gh_pat_name="GITHUB_PAT_${timestamp_suffix}"
    
    echo "Field name configuration:"
    local do_token_name=$(read_with_default "Enter field name for DigitalOcean token" "$default_do_token_name")
    local gh_pat_name=$(read_with_default "Enter field name for GitHub PAT" "$default_gh_pat_name")
    
    echo "$do_token_name:$gh_pat_name"
}

# Function to get SSH email
get_ssh_email() {
    echo
    echo -n "Enter email for SSH keys: "
    read SSH_EMAIL
    echo "$SSH_EMAIL"
}

# Function to store tokens in 1Password
store_tokens() {
    local vault="$1"
    local item_title="$2"
    local github_pat="$3"
    local do_token="$4"
    local do_field_name="$5"
    local gh_field_name="$6"

    if op item get "$item_title" --vault "$vault" &>/dev/null; then
        echo "Updating existing item with tokens..."
        op item edit "$item_title" --vault "$vault" \
            "${do_field_name}[password]=$do_token" \
            "${gh_field_name}[password]=$github_pat"
    else
        echo "Creating new SecureNote item..."
        op item create --category SecureNote --vault "$vault" \
            --title "$item_title" \
            "${do_field_name}[password]=$do_token" \
            "${gh_field_name}[password]=$github_pat"
    fi
}

# Function to initialize CLI tools
init_cli_tools() {
    local do_token="$1"
    local github_pat="$2"

    echo "Initializing DigitalOcean CLI..."
    doctl auth init --context default --access-token "$do_token"

    echo "Initializing GitHub CLI..."
    echo "$github_pat" | gh auth login --with-token
}

# Main function to orchestrate token setup process
setup_tokens() {
    # Clear screen and show welcome message
    clear
    echo "=== SSH Key Setup and Management Tool ==="
    echo "This script will help you set up SSH keys and configure various services."
    echo

    # Get all required inputs with new branching logic
    local github_pat=$(setup_github_pat)
    local do_token=$(setup_do_token)
    local vault=$(select_or_create_vault)
    local item_title=$(select_or_create_item "$vault")
    local ssh_email=$(get_ssh_email)
    
    # Get custom field names
    IFS=':' read -r do_field_name gh_field_name <<< "$(get_field_names)"
    
    # Store and configure everything
    store_tokens "$vault" "$item_title" "$github_pat" "$do_token" "$do_field_name" "$gh_field_name"
    init_cli_tools "$do_token" "$github_pat"

    # Return collected values for use in next phase
    echo "$ssh_email"
}

# Main execution
main() {
    local ssh_email=$(setup_tokens)
    # Here we can add the next phase (SSH key setup)
    # Using $ssh_email and other values as needed
}

# Run the script
main