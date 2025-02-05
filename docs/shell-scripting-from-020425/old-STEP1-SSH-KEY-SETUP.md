# SSH Key Setup for Project

This script sets up two SSH key pairs:

1. A developer (human) key for direct access
2. A CICD bot key for automated deployments

## Key Distribution

The keys will be distributed to:

- Local Laptop: Both private and public keys
- DigitalOcean: Public keys only
- GitHub: Public keys only
- 1Password: Public keys only
- GitHub Repository Secrets (later): CICD bot's private key (added per repository)

## How It Works

### Server Authentication

- The remote server uses the CICD bot's public key to verify the GitHub Actions bot when it SSHs in to deploy new Docker images
- The server uses the developer's public key to verify when developers SSH in from their laptops

### CICD Setup

- The CICD bot's private key will be added to GitHub repository secrets later
- When GitHub Actions runs, it uses this private key to authenticate with the server
- The server verifies the bot's identity using the corresponding public key

### Note

This is configured for personal use. To use this script, you'll need to modify:

- The email address
- SSH key names
- 1Password vault and item details
- Token field names

The script below handles the key generation and distribution automatically.

```bash
export EMAIL=patrick.wm.meaney@gmail.com
export SSH_KEY_NAME_HUMAN_WITHPASS=withpass_DO_TF_HUMAN_PUB_SSH_KEY
export SSH_KEY_NAME_CICDBOT_NOPASS=nopass_GHACICD_BOT_PUB_SSH_KEY

# 1PASSWORD
export VAULT_1P=Z_Tech_ClicksAndCodes
export ITEM_1P="2025 Feb 020325 Debian project"
export FIELD_1P_DO_TOKEN=DO_TOKEN_ALL_PERMISSIONS_020325
export FIELD_1P_GH_TOKEN=GH_PAT_repo_read-org_admin-publickey

# Generate the keys
ssh-keygen -t ed25519 -C "${EMAIL}" -f ~/.ssh/id_ed25519_${SSH_KEY_NAME_HUMAN_WITHPASS}
ssh-keygen -t ed25519 -C "${EMAIL}" -f ~/.ssh/id_ed25519_${SSH_KEY_NAME_CICDBOT_NOPASS} -N ""
# Add them to ssh agent (priv key filepath)
ssh-add ~/.ssh/id_ed25519_${SSH_KEY_NAME_HUMAN_WITHPASS}
ssh-add ~/.ssh/id_ed25519_${SSH_KEY_NAME_CICDBOT_NOPASS}

# Add them to ssh-config file.  Since its our laptop, we only need to specify our human user's ssh key.
# First ensure there's a newline at the end of the existing config
echo "" >> ~/.ssh/config

# Then append the new configuration
cat << EOF >> ~/.ssh/config
# New key -- from shell script -- for human dev user
Host github.com-humanuser
    HostName ssh.github.com
    User git
    Port 443
    IdentityFile ~/.ssh/id_ed25519_${SSH_KEY_NAME_HUMAN_WITHPASS}
    PreferredAuthentications publickey
    AddKeysToAgent yes

EOF

# Add the 2 ssh pub keys to 1password
op item edit "$ITEM_1P" --vault "$VAULT_1P" \
       "id_ed25519_nopass_GHACICD_BOT_PUB_SSH_KEY[text]=$(cat ~/.ssh/id_ed25519_nopass_GHACICD_BOT_PUB_SSH_KEY.pub)" \
       "id_ed25519_withpass_DO_TF_HUMAN_PUB_SSH_KEY[text]=$(cat ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_PUB_SSH_KEY.pub)"

# cmd to output GH Token
# op item get "${ITEM_1P}" --vault "${VAULT_1P}" --field "${FIELD_1P_GH_TOKEN}"

# cmd to output DO Token
# op item get "${ITEM_1P}" --vault "${VAULT_1P}" --field "${FIELD_1P_DO_TOKEN}"

# Log into GH with token (so we can auto-upload the 2 ssh keys to GH)
echo "$(op item get "${ITEM_1P}" --vault "${VAULT_1P}" --field "${FIELD_1P_GH_TOKEN}")" | gh auth login --with-token
gh ssh-key add ~/.ssh/id_ed25519_${SSH_KEY_NAME_HUMAN_WITHPASS}.pub -t "${SSH_KEY_NAME_HUMAN_WITHPASS}"
gh ssh-key add ~/.ssh/id_ed25519_${SSH_KEY_NAME_CICDBOT_NOPASS}.pub -t "${SSH_KEY_NAME_CICDBOT_NOPASS}"

# if you want, now that github has the ssh key, you can test with this: `ssh -vT github.com-humanuser` (enter the pw associated with the ssh key)

# Log into DO with token (so we can auto-upload the 2 ssh keys to DO)
doctl auth init --context default --access-token "$(op item get "${ITEM_1P}" --vault "${VAULT_1P}" --field "${FIELD_1P_DO_TOKEN}")"
doctl compute ssh-key create "${SSH_KEY_NAME_CICDBOT_NOPASS}" --public-key "$(cat ~/.ssh/id_ed25519_${SSH_KEY_NAME_CICDBOT_NOPASS}.pub)"
doctl compute ssh-key create "${SSH_KEY_NAME_HUMAN_WITHPASS}" --public-key "$(cat ~/.ssh/id_ed25519_${SSH_KEY_NAME_HUMAN_WITHPASS}.pub)"

### Now that our 2 SSH keys are on both DO, GH, and 1Password,
# We can run our terraform commands, which puts both public keys onto the remote server it builds.
# That remote server then uses the CICD pub key to verify when the GHA CICD Bot uses ssh to login our server to deploy a new docker image to it.  We'll eventually upload the private ssh key for the CICD Bot to the Github Repo where we'll setup CICD.  Since the Bot will use that private key to try to ssh in-- which it will be able to do, assuming the server can verify its identity with the public key.  So, that's why we need Tf to put the public key on the server (note-- I think by adding it to DO, it may be done automatically as well-- not 100% sure on that).  With the Human SSH key-- we add have TF add that to the server, so the server can verify me (the developer) when I ssh in from my laptop.
# So, now we've covered ssh logins by the human & the bot.

# We have the SSH keys on the Laptop (Priv, Pub), DO (Pub), GH (Pub), & 1P (Pub).  And later, GH ([Priv, in Repo Secrets] & Pub)
# Don't worry about adding the priv key to GH-- itll be done on a repo by repo basis
```
