#!/bin/bash

########## Project Abbreviations   ##########
## 1P = 1Password      GH = Github         ##
## DO = DigitalOcean                       ##
#############################################

#### Section: Editable variables
EMAIL=patrick.wm.meaney@gmail.com
ENCTYPE=id_ed25519
SSH_KEY_NAME_HUMAN_WITHPASS=withpass_DO_TF_HUMAN_PUB_SSH_KEY
SSH_KEY_NAME_CICDBOT_NOPASS=nopass_GHACICD_BOT_PUB_SSH_KEY

FULL_SSH_KEY_NAME_HUMAN_WITHPASS=${ENCTYPE}_${SSH_KEY_NAME_HUMAN_WITHPASS}
FULL_SSH_KEY_NAME_CICDBOT_NOPASS=${ENCTYPE}_${SSH_KEY_NAME_CICDBOT_NOPASS}

# 1PASSWORD
VAULT_1P=Z_Tech_ClicksAndCodes
ITEM_1P="2025 Feb 020325 Debian project"
FIELD_1P_DO_TOKEN=DO_TOKEN_ALL_PERMISSIONS_020325
FIELD_1P_GH_TOKEN=GH_PAT_repo_read-org_admin-publickey

#### Section: Functions
get_1password_field() {
   local vault="$1"
   local item="$2"
   local field="$3"

   op item get "${item}" \
       --vault "${vault}" \
       --field "${field}"
}

create_and_upload_ssh_key() {
   local key_name="$1"
   local with_password="$2"  # true/false

   local ssh_key_enctype=id_ed25519
   local ssh_key_full_filename="${ssh_key_enctype}_${key_name}"
   local ssh_key_file_creation_path=~/.ssh/${ssh_key_full_filename}
   local ssh_key_file_pubkey_path=~/.ssh/${ssh_key_full_filename}.pub

   echo "Creating SSH key: ${ssh_key_full_filename}"
   if [ "$with_password" = true ]; then
       ssh-keygen -t ed25519 -C "${EMAIL}" -f "${ssh_key_file_creation_path}"
   else
       ssh-keygen -t ed25519 -C "${EMAIL}" -f "${ssh_key_file_creation_path}" -N ""
   fi

   echo "Adding private ssh key to ssh agent - ${ssh_key_file_creation_path}"
   echo "Sorry to ask a 2nd time, but this time its for adding the key to the key agent"
   ssh-add "${ssh_key_file_creation_path}"

   echo "Adding key to ssh config file"
   cat << EOF >> ~/.ssh/config

# New key -- from shell script
Host github.com
    HostName ssh.github.com
    User git
    Port 443
    IdentityFile ${ssh_key_file_creation_path}
EOF

   echo "Uploading ssh public key to DigitalOcean via DO CLI"
   doctl compute ssh-key create "${key_name}" --public-key "$(cat ${ssh_key_file_pubkey_path})"

   echo "Uploading ssh public key to Github via GH CLI"
   gh ssh-key add "${ssh_key_file_pubkey_path}" -t "${key_name}"
}

#### Section: Main Script

echo "Logging into Github CLI tool with GH PAT Token"
echo "$(get_1password_field "${VAULT_1P}" "${ITEM_1P}" "${FIELD_1P_GH_TOKEN}")" | gh auth login --with-token

echo "Logging into DigitalOcean CLI Tool with DO Token"
doctl auth init --context default --access-token "$(get_1password_field "${VAULT_1P}" "${ITEM_1P}" "${FIELD_1P_DO_TOKEN}")"

# Create and upload human key (with password)
create_and_upload_ssh_key "${SSH_KEY_NAME_HUMAN_WITHPASS}" true

# Create and upload CICD bot key (without password)
create_and_upload_ssh_key "${SSH_KEY_NAME_CICDBOT_NOPASS}" false

# After creating both keys, store them in 1Password
echo "Storing public keys in 1Password..."
if op item get "$ITEM_1P" --vault "$VAULT_1P" &>/dev/null; then
   echo "Item '$ITEM_1P' exists in vault '$VAULT_1P'. Public keys will be updated."

   # Update existing item with both public keys
   op item edit "$ITEM_1P" --vault "$VAULT_1P" \
       "${FULL_SSH_KEY_NAME_CICDBOT_NOPASS}[text]=$(cat ~/.ssh/${FULL_SSH_KEY_NAME_CICDBOT_NOPASS}.pub)" \
       "${FULL_SSH_KEY_NAME_HUMAN_WITHPASS}[text]=$(cat ~/.ssh/${FULL_SSH_KEY_NAME_HUMAN_WITHPASS}.pub)"
else
   echo "Item '$ITEM_1P' does not exist in vault '$VAULT_1P'. Creating new item with public keys."

   # Create new item with both public keys
   op item create --vault "$VAULT_1P" \
       --title "$ITEM_1P" \
       "${FULL_SSH_KEY_NAME_CICDBOT_NOPASS}[text]=$(cat ~/.ssh/${FULL_SSH_KEY_NAME_CICDBOT_NOPASS}.pub)" \
       "${FULL_SSH_KEY_NAME_HUMAN_WITHPASS}[text]=$(cat ~/.ssh/${FULL_SSH_KEY_NAME_HUMAN_WITHPASS}.pub)"
fi

echo "Done: Setup new ssh keys, uploaded them to DO, GH, and 1P"