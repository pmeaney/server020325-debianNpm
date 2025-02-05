# Step 2: Export environment variables to shell environment

## Purpose

This script is part of a multi-step server deployment process. It exports essential environment variables needed for Terraform to provision a DigitalOcean server with proper SSH access configuration. The script retrieves sensitive data from 1Password and sets them as environment variables, ensuring secure handling of credentials and configuration values.

## What This Script Does

1. Retrieves the DigitalOcean access token from 1Password for Terraform authentication
2. Sets up Linux user configurations for both a human developer and a GitHub Actions CI/CD bot
3. Configures SSH access variables for passwordless authentication
4. Prepares environment variables for Terraform to store server IP information back into 1Password

## Prerequisites

- 1Password CLI installed and authenticated
- Access to the specified 1Password vault
- Completed [Step 1: Ssh Key Setup](./STEP-1-SSH-KEY-SETUP.md')

## Environment Variables

Below are the actual export commands and their descriptions:

This setup enables secure, automated server provisioning while maintaining security best practices by:

- Keeping sensitive information in 1Password
- Supporting both human and automated (CI/CD) access
- Using passwordless SSH authentication
- Preparing for automated IP address management

```bash

# 1PASSWORD
export DIGITALOCEAN_ACCESS_TOKEN=$(op item get ${ITEM_1P} --fields label=DIGITALOCEAN_ACCESS_TOKEN)
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
