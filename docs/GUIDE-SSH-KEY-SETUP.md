# Project SSH Key Setup and Management Guide

## 1. Generate SSH Keys

### Human Developer Key (with password)

```bash
# Generate SSH key with a strong password
ssh-keygen -t ed25519 -C "your.email@example.com" -f ~/.ssh/id_ed25519_devops_DEB020325

# Add to SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_devops_DEB020325
```

### CI/CD Bot Key (no password)

```bash
# Generate SSH key without password for automation
ssh-keygen -t ed25519 -C "cicd-bot@example.com" -f ~/.ssh/id_ed25519_cicdbot_DEB020325 -N ""

# Add to SSH agent
ssh-add ~/.ssh/id_ed25519_cicdbot_DEB020325
```

## 2. Configure SSH Config File

Add these entries to `~/.ssh/config`:

```text
# Human Developer Access
Host do-portfolio-feb2025
    HostName [Your-DO-Droplet-IP]
    User ${LINUX_USERNAME_DEVOPS_HUMAN_DEB020325}
    IdentityFile ~/.ssh/id_ed25519_devops_DEB020325
    AddKeysToAgent yes
    UseKeychain yes

# CI/CD Bot Access
Host do-portfolio-feb2025-cicd
    HostName [Your-DO-Droplet-IP]
    User ${TF_VAR_LINUX_USERNAME_GHA_CICD_BOT_DEB020325}
    IdentityFile ~/.ssh/id_ed25519_cicdbot_DEB020325
    AddKeysToAgent yes
```

## 3. 1Password Storage Guide

### Human Developer Keys

- Vault: Development
- Item Type: SSH Key
- Item Name: "DevOps SSH Key - Portfolio Feb 2025"
- Fields:
  - Private Key: [Contents of ~/.ssh/id_ed25519_devops_DEB020325]
  - Public Key: [Contents of ~/.ssh/id_ed25519_devops_DEB020325.pub]
  - Passphrase: [Your key password]
  - Purpose: "Human developer access for Portfolio Feb 2025"

### CI/CD Bot Keys

- Vault: Development
- Item Type: SSH Key
- Item Name: "CI/CD Bot SSH Key - Portfolio Feb 2025"
- Fields:
  - Private Key: [Contents of ~/.ssh/id_ed25519_cicdbot_DEB020325]
  - Public Key: [Contents of ~/.ssh/id_ed25519_cicdbot_DEB020325.pub]
  - Purpose: "GitHub Actions CI/CD bot access - no password"

## 4. Key Distribution Guide

### Private Keys Usage

1. **Laptop**

   - Store both private keys locally (~/.ssh/)
   - Add both to SSH agent
   - Never share or expose private keys

2. **Digital Ocean & Server Security**

   - Private keys are never stored on DO or your server
   - Server only needs public keys to verify incoming SSH connections
   - How it works:
     - Your laptop/GitHub Actions holds private keys
     - Server holds corresponding public keys
     - When you connect, your private key creates a signature that only the matching public key can verify
     - This is why private keys must be kept secure - anyone with the private key can connect to systems that trust the corresponding public key

3. **GitHub Actions**

   - Stores CI/CD bot's private key as a repository secret (LINUX_SSH_PRIVATE_KEY)
   - Needs private key because GitHub Actions acts like a remote computer trying to SSH into your server
   - How it works:
     - When a workflow runs, GitHub's runner needs to prove it's authorized to access your server
     - It uses the CI/CD bot's private key to create a unique signature that only your server (which has the matching public key) can verify
     - This is similar to how your laptop uses your private key to prove it's really you
   - Used by workflows to authenticate SSH connections during deployments
   - Important: The private key in GitHub Secrets is like the CI/CD bot's "password" - it proves the bot is authorized to deploy code

4. **Terraform**

   - References public keys only
   - Uses variables to inject public keys into cloud-init script
   - Example variables:
     - LINUX_HUMAN_SSH_KEY_PUB_WITHPASS_DEB020325
     - LINUX_GHACICD_BOT_SSH_KEY_PUB_NOPASS_DEB020325

5. **GitHub Actions CI/CD**
   - Stores CI/CD bot's private key as GitHub Secret (LINUX_SSH_PRIVATE_KEY)
   - Used for automated deployments
   - Never expose in logs or outputs

### Public Keys Usage

1. **Digital Ocean**

   - Two separate use cases for public keys:
     1. Server Access: Both public keys (human and bot) are added to the server's authorized_keys via Terraform/cloud-init
     2. DO Console Access: Human user's public key must be manually added via DO web interface (Settings > Security > SSH Keys)
   - Enables SSH access for both human and bot users on server
   - Enables human user access to DO console and API

2. **GitHub**
   - Add human developer's public key to your GitHub account
   - Enables repository access and management

## 5. Security Best Practices

- Never commit private keys to version control
- Use strong passwords for human keys
- Rotate keys periodically (recommended: every 90 days)
- Monitor access logs for unusual activity
- Use separate keys for different environments (dev/staging/prod)
- Store backup copies of keys securely in 1Password

## 6. Testing SSH Access

### Test Human Access

```bash
ssh do-portfolio-feb2025 "echo SSH connection successful"
```

### Test CI/CD Bot Access

```bash
ssh do-portfolio-feb2025-cicd "echo SSH connection successful"
```

Note: Github Actions workflow will use the CI/CD bot's credentials for automated deployments as shown in the deployment YAML file.
