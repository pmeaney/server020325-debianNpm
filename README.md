# Intro

To get this project running,

Ensure the first 4 items in the `1PASSWORD` section are set propertly at the top of script0
You'll need:

- 1Password, with a given Vault & Item (of Category "SecureNote")
- DigitalOcean Token - Full Permissions (`FIELD_1P_DO_TOKEN=DO_TOKEN_ALL_PERMISSIONS_020325`)
- Github PAT Token - repo, read:org, admin:publickey (`FIELD_1P_GH_TOKEN=GH_PAT_repo_read-org_admin-publickey`)
- CLI tools for all 3 installed & logged in.

Then, clone the project.

Then, run the commands in these files (be sure to tailor the first one to your use case):

- [Step 1: Ssh Key Setup](./tf020325/prep-for-tf/STEP-1-SSH-KEY-SETUP.md')
- [Step 2: Export env vars to shell env](./tf020325/prep-for-tf/STEP2-EXPORT-ENV-VARS-TO-SHELL.md')

Then you should be ready to apply the terraform file located in `./tf020325` to setup the server, and ssh in.

From there, you can:

- Launch Nginx Proxy Manager
- Create a Project Repo, and add in the CICD Bot Private Key to its Repo Secrets (along with other items-- IP, LinuxUser, etc.) in order to conduct automatic Docker image deployments via Github Actions CICD.

```bash

# git clone PASTE_GIT_URL
# cd tf020325

# !!! Check out ./tf020325/prep-for-tf/ENV-VARS.md for a guide to setting up ssh keys & shell env
# terraform init
# terraform apply
# enter "yes"
# ip address will be output to 1password
# should be ready to ssh in

```
