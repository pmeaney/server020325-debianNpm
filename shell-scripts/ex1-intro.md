# ex1 bash script introduction

Here's ex1, broken down into some of its core components:

```
# 1. Generate a new SSH key pair
# - This creates two files: a private key (no .pub extension) and a public key (.pub extension)
# - Ed25519 is a modern, secure encryption type
# - The -C flag adds a comment (usually your email) to help identify the key
# - The -f flag specifies where to save the key files
ssh-keygen -t ed25519 -C "patrick.wm.meaney@gmail.com" -f ~/.ssh/id_ed25519_withpass_GENERAL_GITHUB_HUMANDEV_USE_020325

# 2. Add the private key to the SSH agent
# The SSH agent is a program that runs in the background on your computer.
# It serves as a keychain that:
#   - Safely holds your private keys in memory
#   - Handles the authentication process when you connect to servers
#   - Means you don't have to type your passphrase every time you use the key
# Note: If you get an error about "Could not open a connection to your authentication agent",
#       first run: eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_withpass_GENERAL_GITHUB_HUMANDEV_USE_020325

# 3. Configure SSH to use this key for GitHub
# This adds a new section to your SSH config file that tells SSH:
#   - When connecting to github.com, use this specific key
#   - The AddKeysToAgent yes option automatically adds keys to the agent when used
#   - See next section for more info on `~/.ssh/config` file
cat << EOF >> ~/.ssh/config
# Configuration Option - Using Port 443 (for restrictive firewalls)
Host github.com
    HostName ssh.github.com
    User git
    Port 443
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519_withpass_GENERAL_GITHUB_HUMANDEV_USE_020325

# 4. Open the SSH config file to verify the new section was added correctly
# The config file should open in Visual Studio Code
code ~/.ssh/config

# 5. Upload your public key to GitHub
# The gh command is GitHub's official command line tool
# This command uploads your public key (.pub file) to your GitHub account
# The -t flag sets a title for the key to help you identify it on GitHub
gh ssh-key add ~/.ssh/id_ed25519_withpass_GENERAL_GITHUB_HUMANDEV_USE_020325.pub -t "id_ed25519_withpass_GENERAL_GITHUB_HUMANDEV_USE_020325"

# 6. Test your SSH connection to GitHub
# If successful, you'll see a message like "Hi username! You've successfully authenticated"
ssh -T git@github.com
```

# The `~/.ssh/config` file

```bash

Rather than having multiple definitions, like this... we can make them more compact (see next section)

# Configuration Option 1 - Standard Port (22)
Host github.com
    HostName github.com
    User git
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519_withpass_GENERAL_GITHUB_HUMANDEV_USE_020325

Host github.com
    HostName github.com
    User git
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519_withpass_GENERAL_GITHUB_HUMANDEV_USE_020325

Host github.com
    HostName github.com
    User git
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519_withpass_GENERAL_GITHUB_HUMANDEV_USE_020325

# Configuration Option 2 - Port 443 (for restrictive firewalls)
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
    IdentityFile ~/.ssh/id_ed25519_nopass_GHACICD_BOT_SSH_KEY_DEB020325

# Human Developer SSH Key (Terraform/DO)
Host github.com-human-do
    HostName ssh.github.com
    User git
    Port 443
    IdentityFile ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_SSH_KEY_DEB020325

######## Compact example
# Configuration Option 1 - Standard Port (22)
Host github.com
    HostName github.com
    User git
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519_withpass_GENERAL_GITHUB_HUMANDEV_USE_020325
    IdentityFile ~/.ssh/id_ed25519_nopass_GHACICD_BOT_SSH_KEY_DEB020325
    IdentityFile ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_SSH_KEY_DEB020325

# Direct GitHub Access
Host github.com
    HostName ssh.github.com
    User git
    Port 443
    IdentityFile ~/.ssh/id_ed25519_withpass_GENERAL_GITHUB_HUMANDEV_USE_020325
    IdentityFile ~/.ssh/id_ed25519_nopass_GHACICD_BOT_SSH_KEY_DEB020325
    IdentityFile ~/.ssh/id_ed25519_withpass_DO_TF_HUMAN_SSH_KEY_DEB020325
```
