# Required env vars

Here are the Shell environment variables you need to set based on both the Terraform configuration and the cloud-init YAML script.

So, run `env` from a shell, and if these are set... you've done it right.

First, generate s ssh keys.

First, add these env vars which will be used to automate things.

```bash
EMAIL=patrick.wm.meaney@gmail.com
SSH_KEY_NAME_HUMAN_NOPASS=withpass_DO_TF_HUMAN_PUB_SSH_KEY
SSH_KEY_NAME_CICDBOT_NOPASS=nopass_GHACICD_BOT_PUB_SSH_KEY

# 1PASSWORD
VAULT_1P=Z_Tech_ClicksAndCodes
ITEM_1P="2025 Feb 020325 Debian project"
FIELD_1P_DO_TOKEN=DO_TOKEN_ALL_PERMISSIONS_020325
FIELD_1P_GH_TOKEN=GH_PAT_repo_read-org_admin-publickey

# Generate the keys
ssh-keygen -t ed25519 -C "${EMAIL}" -f "~/.ssh/id_ed25519_${SSH_KEY_NAME_HUMAN_NOPASS}" -N ""
ssh-keygen -t ed25519 -C "${EMAIL}" -f "~/.ssh/id_ed25519_${SSH_KEY_NAME_CICDBOT_NOPASS}" -N ""
# Add them to ssh agent (priv key filepath)
ssh-add "~/.ssh/id_ed25519_${SSH_KEY_NAME_HUMAN_NOPASS}"
ssh-add "~/.ssh/id_ed25519_${SSH_KEY_NAME_CICDBOT_NOPASS}"

# Add them to ssh-config file
echo "Adding key to ssh config file"
cat << EOF >> ~/.ssh/config
# New key -- from shell script -- for human dev user
Host github.com-humanuser
    HostName ssh.github.com
    User git
    Port 443
    IdentityFile ~/.ssh/id_ed25519_${SSH_KEY_NAME_HUMAN_NOPASS}
# New key -- from shell script -- for cicd bot
Host github.com-cicdbot
    HostName ssh.github.com
    User git
    Port 443
    IdentityFile ~/.ssh/id_ed25519_${SSH_KEY_NAME_CICDBOT_NOPASS}
EOF

# cmd to output GH Token
# op item get "${ITEM_1P}" --vault "${VAULT_1P}" --field "${FIELD_1P_GH_TOKEN}"

# cmd to output DO Token
# op item get "${ITEM_1P}" --vault "${VAULT_1P}" --field "${FIELD_1P_DO_TOKEN}"

# Log into GH with token (so we can auto-upload the 2 ssh keys to GH)
echo "$(op item get "${ITEM_1P}" --vault "${VAULT_1P}" --field "${FIELD_1P_GH_TOKEN}")" | gh auth login --with-token
gh ssh-key add "~/.ssh/id_ed25519_${SSH_KEY_NAME_HUMAN_NOPASS}.pub" -t "${SSH_KEY_NAME_HUMAN_NOPASS}"
gh ssh-key add "~/.ssh/id_ed25519_${SSH_KEY_NAME_CICDBOT_NOPASS}.pub" -t "${SSH_KEY_NAME_CICDBOT_NOPASS}"

# Log into DO with token (so we can auto-upload the 2 ssh keys to DO)
doctl auth init --context default --access-token "$(op item get "${ITEM_1P}" --vault "${VAULT_1P}" --field "${FIELD_1P_DO_TOKEN}")"
doctl compute ssh-key create "${SSH_KEY_NAME_CICDBOT_NOPASS}" --public-key "$(cat ~/.ssh/id_ed25519_${SSH_KEY_NAME_CICDBOT_NOPASS}.pub)"
doctl compute ssh-key create "${SSH_KEY_NAME_HUMAN_NOPASS}" --public-key "$(cat ~/.ssh/id_ed25519_${SSH_KEY_NAME_HUMAN_NOPASS}.pub)"

### Now that our 2 SSH keys are on both DO, GH, and 1Password,
# We can run our terraform commands, which puts both public keys onto the remote server it builds.
# That remote server then uses the CICD pub key to verify when the GHA CICD Bot uses ssh to login our server to deploy a new docker image to it.  We'll eventually upload the private ssh key for the CICD Bot to the Github Repo where we'll setup CICD.  Since the Bot will use that private key to try to ssh in-- which it will be able to do, assuming the server can verify its identity with the public key.  So, that's why we need Tf to put the public key on the server (note-- I think by adding it to DO, it may be done automatically as well-- not 100% sure on that).  With the Human SSH key-- we add have TF add that to the server, so the server can verify me (the developer) when I ssh in from my laptop.
# So, now we've covered ssh logins by the human & the bot.

# We have the SSH keys on the Laptop (Priv, Pub), DO (Pub), GH (Pub), & 1P (Pub).  And later, GH ([Priv, in Repo Secrets] & Pub)
# Don't worry about adding the priv key to GH-- itll be done on a repo by repo basis
# Let's set up the rest of the shell env vars.

# 1PASSWORD
export DIGITAL_OCEAN_TOKEN=$(op item get ${ITEM_1P} --fields label=DIGITAL_OCEAN_TOKEN)
export TF_VAR_LINUX_SERVER_NAME=$(op item get ${ITEM_1P} --fields label=LINUX_SERVER_NAME)
export TF_VAR_LINUX_USERNAME_DEVOPS_HUMAN=$(op item get ${ITEM_1P} --fields label=LINUX_USERNAME_DEVOPS_HUMAN)
export TF_VAR_LINUX_HUMAN_SSH_KEY_PUB_NOPASS=$(op item get ${ITEM_1P} --fields label=id_ed25519_nopass_DO_TF_HUMAN_PUB_SSH_KEY)
export TF_VAR_LINUX_USERNAME_GHA_CICD_BOT=$(op item get ${ITEM_1P} --fields label=LINUX_USERNAME_GHA_CICD_BOT)
export TF_VAR_LINUX_GHACICD_BOT_SSH_KEY_PUB_NOPASS=$(op item get ${ITEM_1P} --fields label=id_ed25519_nopass_GHACICD_BOT_PUB_SSH_KEY)
export TF_VAR_VAULT_1P=$(op item get "2025 Feb 020325 Debian project" --fields label=VAULT_1P)
export TF_VAR_ITEM_1P=$(op item get "2025 Feb 020325 Debian project" --fields label=ITEM_1P)
```

```bash
# Descriptions

# To interact with DO, TF expects an env var of "DIGITALOCEAN_ACCESS_TOKEN" exactly.  So, storing it in 1pass with that name as well is a good idea for clarity
DIGITALOCEAN_ACCESS_TOKEN=
TF_VAR_LINUX_SERVER_NAME

# TF uses these to setup ssh access for human & cicd nopass ssh login access
TF_VAR_LINUX_USERNAME_DEVOPS_HUMAN
TF_VAR_LINUX_HUMAN_SSH_KEY_PUB_NOPASS
TF_VAR_LINUX_USERNAME_GHA_CICD_BOT
TF_VAR_LINUX_GHACICD_BOT_SSH_KEY_PUB_NOPASS

# We export these so TF can access them, in order to upload IP address from its output, to this vault & item, into "LINUX_SERVER_IPADDRESS" field
TF_VAR_VAULT_1P
TF_VAR_ITEM_1P

```

---

---

---

---

---

---

---

To return to fix or add in--------------

```bash
#
#       VERIFY
#

export DIGITAL_OCEAN_TOKEN=$(op item get "2025 Feb 020325 Debian project" --fields label=DIGITAL_OCEAN_TOKEN) &&
export TF_VAR_LINUX_SERVER_NAME=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_SERVER_NAME) &&
# Human user secrets: ssh pub key, ssh user, ssh pw
export TF_VAR_LINUX_HUMAN_SSH_KEY_PUB_NOPASS=$(op item get "2025 Feb 020325 Debian project" --fields label=id_ed25519_withpass_DO_TF_HUMAN_PUB_SSH_KEY) &&
export TF_VAR_LINUX_USERNAME_DEVOPS_HUMAN=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_USERNAME_DEVOPS_HUMAN) &&
export TF_VAR_LINUX_USERPASSWORD_DEVOPS_HUMAN=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_USERPASSWORD_DEVOPS_HUMAN) &&

# CICD bot user secrets: ssh pub key, ssh user, (no ssh pw for bot user)
export TF_VAR_LINUX_GHACICD_BOT_SSH_KEY_PUB_NOPASS=$(op item get "2025 Feb 020325 Debian project" --fields label=id_ed25519_nopass_GHACICD_BOT_PUB_SSH_KEY) &&
export TF_VAR_LINUX_USERNAME_GHA_CICD_BOT=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_USERNAME_GHA_CICD_BOT) &&

# We export these so TF can access them, in order to upload IP address for us ("LINUX_SERVER_IPADDRESS")
export TF_VAR_VAULT_1P=$(op item get "2025 Feb 020325 Debian project" --fields label=VAULT_1P) &&
export TF_VAR_ITEM_1P=$(op item get "2025 Feb 020325 Debian project" --fields label=ITEM_1P)

```
