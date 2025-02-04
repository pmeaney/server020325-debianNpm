# The purpose of this script is to allow a developer to quickly:
# - run through the process of SSH key setup, plus adding public ssh key to DigitalOcean, Github, & storing it in 1pass
# Note: files can't yet be CLI auto-uploaded to 1pass, so I typically upload my ssh private key after running this script.

########## Project Abbreviations   ##########
## 1P = 1Password      GH = Github         ##
## DO = DigitalOcean                       ##
#############################################

#### Section: Editable variables: 
# Make sure these are right for your use case.
EMAIL=patrick.wm.meaney@gmail.com
SSH_KEY_NAME=nopass_GENERAL_TEST_KEY_XYZ

# 1PASSWORD -- Set your Vault, Item (e.g. name of a SecureNote), and Field names here
VAULT_1P=Z_Tech_ClicksAndCodes
ITEM_1P="2025 Feb 020325 Debian project"
# for DigitalOcean token -- Create one, give it full access-- that's what I did, though less permissions may work.
# Go here: [DigitalOcean ssh keys dashboard](https://cloud.digitalocean.com/account/security?i=16c58b)
FIELD_1P_DO_TOKEN=DO_TOKEN_ALL_PERMISSIONS_020325

# for Github Personal Access Token (Classic) -- give it repo (all), read:org, and admin:publickey permissions in classic token mode
# Go here: [Github ssh keys dashboard](https://github.com/settings/keys)
FIELD_1P_GH_TOKEN=GH_PAT_repo_read-org_admin-publickey

#### Section: Other variables
SSH_KEY_ENCTYPE=id_ed25519
SSH_KEY_NAME_WITH_DATE=${SSH_KEY_NAME}_$(get_timestamp_suffix)
SSH_KEY_FULL_FILENAME=${SSH_KEY_ENCTYPE}_${SSH_KEY_NAME_WITH_DATE}
SSH_KEY_FILE_CREATION_PATH=~/.ssh/${SSH_KEY_FULL_FILENAME}
SSH_KEY_PUBKEY_FILENAME=${SSH_KEY_FULL_FILENAME}.pub
SSH_KEY_FILE_PUBKEY_PATH=~/.ssh/${SSH_KEY_FILE_PUBKEY_PATH}

#### Section: Functions
get_timestamp_suffix() {
  # format the current date as MMDDYY -- e.g. 020425
    date +%m%d%y
}
DATE=$(get_timestamp_suffix)

get_1password_field() {
    local vault="$1"
    local item="$2"
    local field="$3"

    # Retrieves field value from 1Password
    op item get "${item}" \
        --vault "${vault}" \
        --field "${field}"
}


#### Section: Main Script

echo "Logging into Github CLI tool with GH PAT Token so we can upload to GH the upcoming ssh key we create"
echo "$(get_1password_field "${VAULT_1P}" "${ITEM_1P}" "${FIELD_1P_GH_TOKEN}")" | gh auth login --with-token

echo "Logging into DigitalOcean CLI Tool with DO Token so we can upload to DO the upcoming ssh key we create"
doctl auth init --context default --access-token "$(get_1password_field "${VAULT_1P}" "${ITEM_1P}" "${FIELD_1P_DO_TOKEN}")"

echo "Creating an ssh key: " ${SSH_KEY_FULL_FILENAME}
ssh-keygen -t ed25519 -C "${EMAIL}" -f ${SSH_KEY_FILE_CREATION_PATH}

echo "Adding private ssh key to ssh agent - " ${SSH_KEY_FILE_CREATION_PATH}
ssh-add ${SSH_KEY_FILE_CREATION_PATH}

echo "Adding keys to ssh config file"
cat << EOF >> ~/.ssh/config

# New key -- from shell script on ${DATE}
Host github.com
    HostName ssh.github.com
    User git
    Port 443
    IdentityFile ${SSH_KEY_FILE_CREATION_PATH}
EOF

echo "Uploading ssh public key to DigitalOcean via DO CLI"
doctl compute ssh-key create ${SSH_KEY_NAME_WITH_DATE} --public-key "$(cat ${SSH_KEY_FILE_PUBKEY_PATH})"

echo "Uploading ssh public key to Github via GH CLI"
gh ssh-key add ${SSH_KEY_FILE_PUBKEY_PATH} -t "${SSH_KEY_NAME_WITH_DATE}"

## 1Password Integration Section
echo "Checking 1Password vault and item status..."

# Function to check if vault exists
check_vault() {
    if op vault get "${VAULT_1P}" &>/dev/null; then
        echo "Vault '${VAULT_1P}' exists."
        return 0
    else
        echo "Vault '${VAULT_1P}' does not exist."
        return 1
    fi
}

# Function to create vault
create_vault() {
    echo "Creating vault '${VAULT_1P}'..."
    op vault create "${VAULT_1P}"
}

# Function to check if item exists
check_item() {
    if op item get "${ITEM_1P}" --vault "${VAULT_1P}" &>/dev/null; then
        echo "Item '${ITEM_1P}' exists in vault '${VAULT_1P}'."
        return 0
    else
        echo "Item '${ITEM_1P}' does not exist in vault '${VAULT_1P}'."
        return 1
    fi
}

# Main execution flow
main() {
    # Step 1: Check and create vault if necessary
    if ! check_vault; then
        create_vault
    fi

    # Step 2: Check if item exists and update/create accordingly
    if check_item; then
        # Item exists, update by adding new field
        echo "Adding/updating public key in existing item..."
        op item edit "${ITEM_1P}" --vault "${VAULT_1P}" \
            "${SSH_KEY_PUBKEY_FILENAME}[text]=$(cat ${SSH_KEY_FILE_PUBKEY_PATH})" \
            --category "Secure Note"
    else
        # Item doesn't exist, create new item with field
        echo "Creating new item with public key..."
        op item create --vault "${VAULT_1P}" \
            --title "${ITEM_1P}" \
            --category "Secure Note" \
            "${SSH_KEY_PUBKEY_FILENAME}[text]=$(cat ${SSH_KEY_FILE_PUBKEY_PATH})"
    fi

    echo "1Password operation completed successfully."
}

# Execute main function
main