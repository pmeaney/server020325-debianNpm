# Required env vars

Here are the Shell environment variables you need to set based on both the Terraform configuration and the cloud-init YAML script.

So, run `env` from a shell, and if these are set... you've done it right.

Below this... you'll find the commands to set them from 1password.

```bash
# Human Developer Access
TF_VAR_LINUX_USERNAME_DEVOPS_HUMAN
TF_VAR_LINUX_HUMAN_SSH_KEY_PUB_WITHPASS

# GitHub Actions CI/CD Bot
TF_VAR_LINUX_USERNAME_GHA_CICD_BOT
TF_VAR_LINUX_GHACICD_BOT_SSH_KEY_PUB_NOPASS

# Server Configuration
TF_VAR_LINUX_SERVER_NAME

# 1Password Integration
TF_VAR_VAULT_1P
TF_VAR_ITEM_1P
```

First, generate the ssh keys...
-- add ssh key section

```bash
#
#       VERIFY
#

export DIGITAL_OCEAN_TOKEN=$(op item get "2025 Feb 020325 Debian project" --fields label=DIGITAL_OCEAN_TOKEN) &&
export TF_VAR_LINUX_SERVER_NAME=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_SERVER_NAME) &&
# Human user secrets: ssh pub key, ssh user, ssh pw
export TF_VAR_LINUX_HUMAN_SSH_KEY_PUB_WITHPASS=$(op item get "2025 Feb 020325 Debian project" --fields label=id_ed25519_withpass_DO_TF_HUMAN_PUB_SSH_KEY) &&
export TF_VAR_LINUX_USERNAME_DEVOPS_HUMAN=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_USERNAME_DEVOPS_HUMAN) &&
export TF_VAR_LINUX_USERPASSWORD_DEVOPS_HUMAN=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_USERPASSWORD_DEVOPS_HUMAN) &&

# CICD bot user secrets: ssh pub key, ssh user, (no ssh pw for bot user)
export TF_VAR_LINUX_GHACICD_BOT_SSH_KEY_PUB_NOPASS=$(op item get "2025 Feb 020325 Debian project" --fields label=id_ed25519_nopass_GHACICD_BOT_PUB_SSH_KEY) &&
export TF_VAR_LINUX_USERNAME_GHA_CICD_BOT=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_USERNAME_GHA_CICD_BOT) &&

# We export these so TF can access them, in order to upload IP address for us ("LINUX_SERVER_IPADDRESS")
export TF_VAR_VAULT_1P=$(op item get "2025 Feb 020325 Debian project" --fields label=VAULT_1P) &&
export TF_VAR_ITEM_1P=$(op item get "2025 Feb 020325 Debian project" --fields label=ITEM_1P)

```
