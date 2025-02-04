

```bash

# For Github:
echo "Create a Github Personal Access Token with scopes: admin:public_key, rep, read:org"
echo "Add that GH PAT to a 1pass field: GH_PAT_repo_read-org_admin-publickey"

# For DO:
echo "Create a DigitalOcean Token with scopes: Full Access (we may dial this in later)"
echo "Add that DO Token to a 1pass field: DO_TOKEN_ALL_PERMISSIONS_020325"

echo "Logging into DigitalOcean CLI Tool"
doctl auth init --context default --access-token "$(op item get "2025 Feb 020325 Debian project" --vault "Z_Tech_ClicksAndCodes" --field DO_TOKEN_ALL_PERMISSIONS_020325)"

echo "Logging into Github CLI Tool"
echo "$(op item get "2025 Feb 020325 Debian project" --vault "Z_Tech_ClicksAndCodes" --field GH_PAT_repo_read-org_admin-publickey)" | gh auth login --with-token

echo "Generating key for CICD Bot user-- no pass"
ssh-keygen -t ed25519 -C "patrick.wm.meaney@gmail.com" -f ~/.ssh/id_ed25519_nopass_GHACICD_BOT_PUB_SSH_KEY -N ""

echo "Generating key for Human developer user-- with password"
ssh-keygen -t ed25519 -C "patrick.wm.meaney@gmail.com" -f ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_PUB_SSH_KEY

echo "Adding keys to ssh agent"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_nopass_GHACICD_BOT_PUB_SSH_KEY
ssh-add ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_PUB_SSH_KEY

echo "Adding keys to ssh config file"
cat << EOF >> ~/.ssh/config

# Direct GitHub Access
Host github.com
    HostName ssh.github.com
    User git
    Port 443
    IdentityFile ~/.ssh/id_ed25519_withpass_GENERAL_GITHUB_HUMANDEV_USE_020325

# CICD Bot SSH Key
Host github.com-cicdbot
    HostName ssh.github.com
    User git
    Port 443
    IdentityFile ~/.ssh/id_ed25519_nopass_GHACICD_BOT_PUB_SSH_KEY

# Human Developer SSH Key (Terraform/DO)
Host github.com-human-do
    HostName ssh.github.com
    User git
    Port 443
    IdentityFile ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_PUB_SSH_KEY

EOF

echo "Uploading ssh public keys for both users to DigitalOcean via DO CLI"
doctl compute ssh-key create GHACICD_BOT_SSH_KEY --public-key "$(cat ~/.ssh/id_ed25519_nopass_GHACICD_BOT_PUB_SSH_KEY.pub)"
doctl compute ssh-key create DO_TF_HUMAN_SSH_KEY --public-key "$(cat ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_PUB_SSH_KEY.pub)"

echo "Uploading ssh public keys for both users to Github"
gh ssh-key add ~/.ssh/id_ed25519_nopass_GHACICD_BOT_PUB_SSH_KEY.pub -t "GHACICD_BOT_SSH_KEY"
gh ssh-key add ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_PUB_SSH_KEY.pub -t "DO_TF_HUMAN_SSH_KEY"

echo "Reminder: You will need to add the ssh private key for the CICD Bot to use to the Repository where the CICD Bot will run."
echo "Reminder: 1pass does not yet allow uploading of files from CLI.  I recommend uploading both private keys to 1password manually"

echo "Uploading ssh public keys for both users to 1password, to an existing vault"

VAULT="Z_Tech_ClicksAndCodes"
ITEM_TITLE="2025 Feb 020325 Debian project"

echo "1pass does not yet allow uploading of files from CLI.  Will upload pub keys only."

# Check if the item exists in the vault
if op item get "$ITEM_TITLE" --vault "$VAULT" &>/dev/null; then
    echo "Item '$ITEM_TITLE' exists in vault '$VAULT'. Public keys will be updated."

    # Update existing item with just the public keys
    op item edit "$ITEM_TITLE" --vault "$VAULT" \
        "id_ed25519_nopass_GHACICD_BOT_PUB_SSH_KEY[text]=$(cat ~/.ssh/id_ed25519_nopass_GHACICD_BOT_PUB_SSH_KEY.pub)" \
        "id_ed25519_withpass_DO_TF_HUMAN_PUB_SSH_KEY[text]=$(cat ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_PUB_SSH_KEY.pub)"
else
    echo "Item '$ITEM_TITLE' does not exist in vault '$VAULT'. Creating new item with public keys."

    # Create new item with just the public keys
    op item create --vault "$VAULT" \
        --title "$ITEM_TITLE" \
        "id_ed25519_nopass_GHACICD_BOT_PUB_SSH_KEY[text]=$(cat ~/.ssh/id_ed25519_nopass_GHACICD_BOT_PUB_SSH_KEY.pub)" \
        "id_ed25519_withpass_DO_TF_HUMAN_PUB_SSH_KEY[text]=$(cat ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_PUB_SSH_KEY.pub)"
fi

```
