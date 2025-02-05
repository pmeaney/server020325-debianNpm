## Readme status

This readme is a bit disorganized... I plan to update it soon.
Was dealing with network issues due to library wifi, thought I had a bug. So, I am a little tired of this project, haha!

### Intro

To get this project running,

Ensure the first 4 items in the `1PASSWORD` section are set propertly at the top of script0
You'll need:

- 1Password, with a given Vault & Item (of Category "SecureNote")
- DigitalOcean Token - Full Permissions (`FIELD_1P_DO_TOKEN=DO_TOKEN_ALL_PERMISSIONS_020325`)
- Github PAT Token - repo, read:org, admin:publickey (`FIELD_1P_GH_TOKEN=GH_PAT_repo_read-org_admin-publickey`)
- CLI tools for all 3 installed & logged in.

Then, clone the project.

Then, run the commands in these files (be sure to tailor the first one to your use case):

- [Step 1: Ssh Key Setup](./tf020325/prep-for-tf/STEP1-SSH-KEY-SETUP.md')
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

## Nginx Proxy Manager Configuration

Transfer configuration files to the server:

```bash
rsync -avvz ./npm020325/ user@ip:~/npm020325

# Or, if you have an~/.ssh/config setup for a Host named "deb" (short for debian) setup for your patDevOpsUser, IP, & ssh file, you can just run this:
rsync -avvz ./npm020325/ deb:~/npm020325

# Start NPM containers

# Simple way to watch it boot & make sure it runs:
cd npm020325 && \
docker compose up

# This command is to Run in background, then check out logs.  It's a nice way to view the running container, while leaving it running after you exit the logs view.:
cd npm020325 && \
docker compose -vvv -f docker-compose.yml up --build --remove-orphans -d && \
docker compose logs -f nginx-proxy-mgr-020325

# Verify Nginx Proxy Manager is reachable by navigating to this address on your browser:
# NOTE: Be sure it's HTTP and not HTTPS! We haven't yet setup any SSL certs, so HTTPS won't reach anything
http://yourServerIP:81
```

## SSL Certificate Setup

To configure SSL certificates and serve traffic to your applications:

1. Register a domain name
2. Configure DNS with your registrar
3. Create DNS A-Records pointing to your server IP
4. Access NPM admin panel at `http://<server-ip>:81`
   - Default credentials:
     - Username: admin@example.com
     - Password: changeme

## Deployment

See [NPM Project Readme](./npm020325/README.md) for more info on Nginx Proxy Manager setup

### Updating NPM Configuration

To transfer updates you make to your NPM Docker Compose file in a quick, automated way, run this rsync command from your developer environment (laptop), and assuming rsync is installed on the remote server, it'll transfer the whole `npm020325` directory to the server. Useful when initially setting things up & testing things out.

```bash
rsync -avvz ./npm020325/ user@ip:~/npm020325

```

## Basic Nginx Proxy Manager Deployment via rsync

Deploy the newest Nginx Proxy Manager config update via rsync instead of git project cloning:

```bash

rsync -avvz ./npm020325/ user@ip:~/npm020325

# if rsync isn't installed on remote server (and your laptop), be sure to install it first.  For debian, for example:
sudo apt install rsync -y

```
