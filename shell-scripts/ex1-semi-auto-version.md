# Process to generate keys, in semi-automated way

Run each command to go through various ssh key setup processes.
We omit the 1pass usage, for simplicity.

ex1.bash is a shell script to help automate this, via an interactive prompt.

```bash

# Generate keys
ssh-keygen -t ed25519 -C "patrick.wm.meaney@gmail.com" -f ~/.ssh/id_ed25519_withpass_GENERAL_GITHUB_HUMANDEV_USE_020325

# Add keys to
ssh-add ~/.ssh/id_ed25519_withpass_GENERAL_GITHUB_HUMANDEV_USE_020325
ssh-add ~/.ssh/id_ed25519_withpass_GENERAL_GITHUB_HUMANDEV_USE_020325

# Add keys to
cat << EOF >> ~/.ssh/config
# Human Developer SSH Key -- General Github Usage
Host github.com-human
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_withpass_GENERAL_GITHUB_HUMANDEV_USE_020325
EOF

# View config file to make sure new section was added
code ~/.ssh/config

# Auto-upload the public key to github
gh ssh-key add ~/.ssh/~/.ssh/id_ed25519_withpass_GENERAL_GITHUB_HUMANDEV_USE_020325.pub -t "id_ed25519_withpass_GENERAL_GITHUB_HUMANDEV_USE_020325"
```

was having issues earlier...

this helped-- setting to 443

```bash
# First backup your current config
cp ~/.ssh/config ~/.ssh/config.backup

# edit ssh config to connec tto github via port 443 rather than 22
cat > ~/.ssh/config << 'EOF'
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

EOF
```
