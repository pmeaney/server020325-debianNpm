# Intro

```bash

git clone
cd tf020325
terraform init
terraform apply
# enter "yes"
# add ip address to 1pass so we can export it to local env via CLI cmd

```

### Setting Up Environment Variables

Export required variables from 1Password:

```bash
# Export Terraform variables
# We need to export them so our Terraform processes can access them.
# We could hardcode these into the terraform file, but that wouldn't be as secure as
# exporting them into the current shell env, from storage in a password manager (1password in this case)
# For more info on how ssh keys are used in this project, see ./docs/GUIDE-SSH-KEY-SETUP.md
# General: DO token, & name to give server
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

## Nginx Proxy Manager Configuration

### Setting Up NPM

First, export required environment variables:

```bash
export TF_VAR_LINUX_USERNAME_DEVOPS_HUMAN=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_USERNAME_DEVOPS_HUMAN) && \
export LINUX_SERVER_IPADDRESS=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_SERVER_IPADDRESS)
```

### Deploying NPM Configuration

Transfer configuration files to the server:

```bash
rsync -avvz ./npm020325/ "${TF_VAR_LINUX_USERNAME_DEVOPS_HUMAN}"@"${LINUX_SERVER_IPADDRESS}":~/npm020325

# OR if you need to specify your identity file:
rsync -avvz -e "ssh -i ~/.ssh/id_ed25519_nopass_LINUX_SSH_KEY" ./npm020325/ "${TF_VAR_LINUX_USERNAME_DEVOPS_HUMAN}"@"${LINUX_SERVER_IPADDRESS}":~/npm020325


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
rsync -avvz ./npm020325/ "${TF_VAR_LINUX_USERNAME_DEVOPS_HUMAN}"@"${LINUX_SERVER_IPADDRESS}":~/npm020325

```

## Basic Nginx Proxy Manager Deployment via rsync

Deploy the newest Nginx Proxy Manager config update via rsync instead of git project cloning:

```bash

rsync -avvz ./npm020325/ "${TF_VAR_LINUX_USERNAME_DEVOPS_HUMAN}"@"${LINUX_SERVER_IPADDRESS}":~/npm020325

# if rsync isn't installed on remote server (and your laptop), be sure to install it first.  For debian, for example:
sudo apt install rsync -y

```

## Project ssh key setup (Developer login, Github CICD bot access)

See [Project Ssh Key Setup Guide](./docs/GUIDE-SSH-KEY-SETUP.md) for more info on

- How to setup ssh keys for the project
- How ssh keys are used in the project & related projects such as app deployments

```bash
# for ssh login, I like to pull login & ip from 1pass:export TF_VAR_LINUX_USERNAME_DEVOPS_HUMAN=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_USERNAME_DEVOPS_HUMAN) && \
export TF_VAR_LINUX_USERNAME_DEVOPS_HUMAN=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_USERNAME_DEVOPS_HUMAN) && \
export LINUX_SERVER_IPADDRESS=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_SERVER_IPADDRESS)

# then ssh in:
ssh "${TF_VAR_LINUX_USERNAME_DEVOPS_HUMAN}"@"${LINUX_SERVER_IPADDRESS}"

# and if you want, view the cloud-init logs to see how everything booted & make sure cloud init installed what it's supposed to (see bottom of ./terraform-server--Debian-Jan2025-PortfolioEtc/yamlScripts/with-envVars.yaml file)
sudo cat /var/log/cloud-init-output.log
```

# More info on env vars

Exported env vars must be prefixed with `TF_VAR_` to be picked up by Terraform.

We'll have the following items in our OS Env so Terraform can access them:

| Environment Variable                        | Notes                                                                                                                     | Example Value                                                                                                                                |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| TF_VAR_LINUX_HUMAN_SSH_KEY_PUB_WITHPASS     | Pub ssh key for human dev user. Used during ssh login                                                                     | [More Info](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) |
| TF_VAR_LINUX_USERNAME_DEVOPS_HUMAN          | Username to setup as Server's first user. You'll use it during ssh login                                                  | bobDev                                                                                                                                       |
| TF_VAR_LINUX_USERPASSWORD_DEVOPS_HUMAN      | User's password to setup for Server's first user. You'll use it during ssh login                                          |                                                                                                                                              |
| TF_VAR_LINUX_USERNAME_GHA_CICD_BOT          | Username for CICD Bot to use. The server is setup with this as a user, so a CICD Runner bot can ssh in to deploy projects | githubCICDBotUser                                                                                                                            |
| TF_VAR_LINUX_GHACICD_BOT_SSH_KEY_PUB_NOPASS | Pub ssh key for Github CICD Bot user                                                                                      | [More Info](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) |
| TF_VAR_LINUX_SERVER_NAME                    | Used by DigitalOcean to give the server a name. Shows up in DO Dashboard                                                  | server020325-debianNpm                                                                                                                       |

## Nginx Proxy Manager & Networking in Dockerized Apps

Check out the doc [Docker Networking Info](./docs/DOCKER-NETWORK-INFO.md)

rences

### Source of initial Terraform project code

- `oleksii_y`. (2022, June 5). `How to create DigitalOcean droplet using Terraform. A-Z guide`. AWSTip.com. Retrieved from [https://awstip.com/how-to-create-digitalocean-droplet-using-terraform-a-z-guide-df91716f6021](https://awstip.com/how-to-create-digitalocean-droplet-using-terraform-a-z-guide-df91716f6021)
  - Archived Article: https://archive.is/I2Mh0
  - Original's Raw Source Code as an archived Github Gist: https://gist.githubusercontent.com/alexsplash/5f8f34f4020092b634dfd29316683718/raw/f6a4331346efe3bc333fb3cf1e91203faa1e7bf1/digitalocean.tf
