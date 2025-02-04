First, I created a DO Token with full permissions, to log into DO CLI with.

Paste the DO Token when prompted by this:
doctl auth init --context default

Or, automate that:
doctl auth init --context default --access-token "$(op item get "2025 Feb 020325 Debian project" --vault "Z_Tech_ClicksAndCodes" --field DO_TOKEN_ALL_PERMISSIONS_LEVEL)"

For uploading SSH keys to GitHub via the gh CLI, you need a Personal Access Token (PAT) with the following minimum permissions:

- admin:public_key - Allows full control of public keys (this includes read and write access)
- repo - Full control of repositories (needed for basic git operations)
- read:org - This is a required scope for the gh CLI tool to function properly, even if you're not directly using organization features.

gh auth login --with-token <your_token_here>

echo "$(op item get "2025 Feb 020325 Debian project" --vault "Z_Tech_ClicksAndCodes" --field GH_PAT_repo_read-org_admin-publickey)" | gh auth login --with-token

# Or interactively (will prompt for token)

gh auth login

```bash

echo "Logging into DigitalOcean CLI Tool"
doctl auth init --context default --access-token "$(op item get "2025 Feb 020325 Debian project" --vault "Z_Tech_ClicksAndCodes" --field DO_TOKEN_ALL_PERMISSIONS_020325)"

echo "Logging into Github CLI Tool"
echo "$(op item get "2025 Feb 020325 Debian project" --vault "Z_Tech_ClicksAndCodes" --field GH_PAT_repo_read-org_admin-publickey)" | gh auth login --with-token

echo "Generating key for CICD Bot user"
ssh-keygen -t ed25519 -C "patrick.wm.meaney@gmail.com" -f ~/.ssh/id_ed25519_nopass_GHACICD_BOT_SSH_KEY_DEB020325 -N ""

echo "Generating key for Human developer user"
ssh-keygen -t ed25519 -C "patrick.wm.meaney@gmail.com" -f ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_SSH_KEY_DEB020325

echo "Adding keys to ssh agent"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_nopass_GHACICD_BOT_SSH_KEY_DEB020325
ssh-add ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_SSH_KEY_DEB020325

echo "Adding keys to ssh config file"
cat << EOF >> ~/.ssh/config

# CICD Bot SSH Key
Host github.com-cicdbot
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_nopass_GHACICD_BOT_SSH_KEY_DEB020325

# Human Developer SSH Key
Host github.com-human
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_SSH_KEY_DEB020325
EOF

echo "Uploading ssh public keys for both users to DigitalOcean via DO CLI"
doctl compute ssh-key create GHACICD_BOT_SSH_KEY_DEB020325 --public-key "$(cat ~/.ssh/id_ed25519_nopass_GHACICD_BOT_SSH_KEY_DEB020325.pub)"
doctl compute ssh-key create DO_TF_HUMAN_SSH_KEY_DEB020325 --public-key "$(cat ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_SSH_KEY_DEB020325.pub)"

echo "Uploading ssh public keys for both users to Github"
gh ssh-key add ~/.ssh/id_ed25519_nopass_GHACICD_BOT_SSH_KEY_DEB020325.pub -t "GHACICD_BOT_SSH_KEY_DEB020325"
gh ssh-key add ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_SSH_KEY_DEB020325.pub -t "DO_TF_HUMAN_SSH_KEY_DEB020325"

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

```
