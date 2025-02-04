# Intro

To get this project running,

Ensure the first 4 items in the `1PASSWORD` section are set propertly at the top of script0
You'll need:

- 1Password, with a given Vault & Item (of Category "SecureNote")
- DigitalOcean Token - Full Permissions (`FIELD_1P_DO_TOKEN=DO_TOKEN_ALL_PERMISSIONS_020325`)
- Github PAT Token - repo, read:org, admin:publickey (`FIELD_1P_GH_TOKEN=GH_PAT_repo_read-org_admin-publickey`)
- CLI tools for all 3 installed & logged in.

(The first two items above are so the bash script can upload ssh keys to DO & GH after it generates them.)

```bash

git clone
cd tf020325

# setup 2 ssh keys, import them into DO, GH, 1P
bash ./scripts-for-tf-prep/script0-make-2-ssh-keys.bash
# import items from 1pass into env
bash ./scripts-for-tf-prep/script1-for-tf-env.bash

terraform init
terraform apply
# enter "yes"
# add ip address to 1pass so we can export it to local env via CLI cmd

```
