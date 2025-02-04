# The purpose of this script is to allow a developer to quickly:
# - run through the process of SSH key setup, plus adding public ssh key to DigitalOcean, Github, & storing it in 1pass
# Note: files can't yet be CLI auto-uploaded to 1pass, so I typically upload my ssh private key after running this script.


########## Project Abbreviations   ##########
## 1P = 1Password      GH = Github         ##
## DO = DigitalOcean                       ##
#############################################

#### Instructions:
####  1. Create a 1pass vault with an Item (category: Secure Note) and update their values below: "VAULT_1P", "ITEM_1P"
###   2. Add your email, provide a name for "SSH_KEY_NAME",
###   3. Visit DO & GH and create tokens
# for DigitalOcean token -- Create one, give it full access-- that's what I did, though less permissions may work.
# Go here: [DigitalOcean ssh keys dashboard](https://cloud.digitalocean.com/account/security?i=16c58b)
# Create field "FIELD_1P_DO_TOKEN" and give add paste the token into it

###   4.for Github Personal Access Token (Classic) -- give it repo (all), read:org, and admin:publickey permissions in classic token mode
# Go here: [Github ssh keys dashboard](https://github.com/settings/keys)
# Create field "FIELD_1P_GH_TOKEN" and give add paste the token into it
#
# Everything else is setup for you, to create an ssh key, and auto-upload it to DO, GH, 1P.
################################################################################################

#### Section: Editable variables.
## Thes are Required to be set correctly, so Make sure these are right for your use case.
EMAIL=patrick.wm.meaney@gmail.com
SSH_KEY_NAME=nopass_GENERAL_TEST_KEY_BLAHHH
# 1PASSWORD -- Set your Vault, Item (e.g. name of a SecureNote), and Field names here
VAULT_1P=Z_Tech_ClicksAndCodes
ITEM_1P="2025 Feb 020325 Debian project"
# for DigitalOcean token -- Create one, give it full access-- that's what I did, though less permissions may work.
# Go here: [DigitalOcean ssh keys dashboard](https://cloud.digitalocean.com/account/security?i=16c58b)
FIELD_1P_DO_TOKEN=DO_TOKEN_ALL_PERMISSIONS_020325

# for Github Personal Access Token (Classic) -- give it repo (all), read:org, and admin:publickey permissions in classic token mode
# Go here: [Github ssh keys dashboard](https://github.com/settings/keys)
FIELD_1P_GH_TOKEN=GH_PAT_repo_read-org_admin-publickey

#############################################
#### Section: Other variables
SSH_KEY_ENCTYPE=id_ed25519
SSH_KEY_NAME_WITH_DATE=${SSH_KEY_NAME}_$(get_timestamp_suffix)
SSH_KEY_FULL_FILENAME=${SSH_KEY_ENCTYPE}_${SSH_KEY_NAME_WITH_DATE}
SSH_KEY_FILE_CREATION_PATH=~/.ssh/${SSH_KEY_FULL_FILENAME}
SSH_KEY_FILE_PUBKEY_PATH=~/.ssh/${SSH_KEY_FULL_FILENAME}.pub
SSH_KEY_PUBKEY_FILENAME=${SSH_KEY_FULL_FILENAME}.pub

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
echo " "
echo " "
echo " "
echo "#############################################"
echo "#############################################"
echo " "
echo "### This script assumes you created the 1Password Vault " ${VAULT_1P} " and Item (category: SecureNote) " ${ITEM_1P}
echo "### And that it contains the DO Token and GH Token referenced at the top of the script
echo "### These tokens will be used to log you into the DO and GH CLI Tools
echo " "
echo "#############################################"
echo "#############################################"
echo " "
echo " "
echo " "

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

op item edit "${ITEM_1P}" --vault "${VAULT_1P}" \
    "${SSH_KEY_PUBKEY_FILENAME}[text]=$(cat ${SSH_KEY_FILE_PUBKEY_PATH})" \
