# The purpose of this script is to allow a developer to quickly:
# - run through the process of SSH key setup for use with the terraform project (2 keys-- human dev and cicd bot)

# Keeping it relatively manual, because it might need tweaking


########## Project Abbreviations   ##########
## 1P = 1Password      GH = Github         ##
## DO = DigitalOcean                       ##
#############################################

#### Section: Editable variables: Make sure these are right for your use case.
EMAIL=patrick.wm.meaney@gmail.com
SSH_KEY_NAME=nopass_GENERAL_TEST_KEY

# 1PASSWORD
VAULT_1P=Z_Tech_ClicksAndCodes
ITEM_1P="2025 Feb 020325 Debian project"
# for GH token, give it full access-- that's what I did, though less permissions may work.
FIELD_1P_DO_TOKEN=DO_TOKEN_ALL_PERMISSIONS_020325
# for GH PAT token, give it repo (all), read:org, and admin:publickey permissions in classic token mode
FIELD_1P_GH_TOKEN=GH_PAT_repo_read-org_admin-publickey

#### Section: Other variables
SSH_KEY_ENCTYPE=id_ed25519
SSH_KEY_NAME_WITH_DATE=${SSH_KEY_NAME}_$(get_timestamp_suffix)
SSH_KEY_FULL_FILENAME=${SSH_KEY_ENCTYPE}_${SSH_KEY_NAME_WITH_DATE}
SSH_KEY_FILE_CREATION_PATH=~/.ssh/${SSH_KEY_FULL_FILENAME}
SSH_KEY_FILE_PUBKEY_PATH=~/.ssh/${SSH_KEY_FULL_FILENAME}.pub
SSH_KEY_PUBKEY_FILENAME=${SSH_KEY_FULL_FILENAME}.pub
DATE=$(get_timestamp_suffix)

#### Section: Functions
get_timestamp_suffix() {
  # format the current date as MMDDYY -- e.g. 020425
    date +%m%d%y
}

get_1password_field() {
    local vault="$1"
    local item="$2"
    local field="$3"

    # Retrieves field value from 1Password
    op item get "${item}" \
        --vault "${vault}" \
        --field "${field}"
}

echo "Logging into Github CLI tool with GH PAT Token so we can upload to GH the upcoming ssh key we create"
echo "$(get_1password_field "${VAULT_1PASSWORD}" "${ITEM_1PASSWORD}" "${FIELD_1PASSWORD_GH_TOKEN}")" | gh auth login --with-token

echo "Logging into DigitalOcean CLI Tool with DO Token so we can upload to DO the upcoming ssh key we create"
doctl auth init --context default --access-token "$(get_1password_field "${VAULT_1PASSWORD}" "${ITEM_1PASSWORD}" "${FIELD_1PASSWORD_DO_TOKEN}")"

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


## NEW TO THE SCRIPT-- FIX THIS PART
# Check if the item exists in the vault
if op item get "$ITEM_TITLE" --vault "$VAULT" &>/dev/null; then
    echo "Item '$ITEM_TITLE' exists in vault '$VAULT'. Public keys will be updated."

    # Update existing item with just the public keys
    op item edit "$ITEM_TITLE" --vault "$VAULT" \
        "id_ed25519_nopass_GHACICD_BOT_PUB_SSH_KEY_DEB020325[text]=$(cat ~/.ssh/id_ed25519_nopass_GHACICD_BOT_SSH_KEY_DEB020325.pub)" \
        "id_ed25519_withpass_DO_TF_HUMAN_PUB_SSH_KEY_DEB020325[text]=$(cat ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_SSH_KEY_DEB020325.pub)"
else
    echo "Item '$ITEM_TITLE' does not exist in vault '$VAULT'. Creating new item with public keys."

    # Create new item with just the public keys
    op item create --vault "$VAULT" \
        --title "$ITEM_TITLE" \
        "id_ed25519_nopass_GHACICD_BOT_PUB_SSH_KEY_DEB020325[text]=$(cat ~/.ssh/id_ed25519_nopass_GHACICD_BOT_SSH_KEY_DEB020325.pub)" \
        "id_ed25519_withpass_DO_TF_HUMAN_PUB_SSH_KEY_DEB020325[text]=$(cat ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_SSH_KEY_DEB020325.pub)"
fi

echo "Done: Setup new ssh key, uploaded it to DO, GH, 1P"