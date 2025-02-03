# Server Setup & Docker Networking Guide

### Setting Up Environment Variables

Export required variables from 1Password:

```bash
# Export Terraform variables
export DIGITALOCEAN_ACCESS_TOKEN=$(op item get "2025 Feb 020325 Debian project" --fields label=TF_VAR_DIGITAL_OCEAN_TOKEN_DEB020325) &&
export TF_VAR_LINUX_PASSWORD_DEVOPS_DEB020325=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_PASSWORD_DEVOPS_DEB020325) &&
export TF_VAR_LINUX_USER_DEVOPS_DEB020325=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_USER_DEVOPS_DEB020325) &&
export TF_VAR_LINUX_SSH_KEY_DEB020325=$(op item get "2025 Feb 020325 Debian project" --fields label=id_ed25519_nopass_LINUX_SSH_KEY_DEB020325) &&
export TF_VAR_LINUX_SERVER_NAME_DEB020325=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_SERVER_NAME_DEB020325)
```

## Nginx Proxy Manager Configuration

### Setting Up NPM

First, export required environment variables:

```bash
export TF_VAR_LINUX_USER_DEVOPS_DEB020325=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_USER_DEVOPS_DEB020325) && \
export LINUX_SERVER_IPADDRESS_DEB020325=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_SERVER_IPADDRESS_DEB020325)
```

### Deploying NPM Configuration

Transfer configuration files to the server:

```bash
rsync -avvz ./npm020325/ "${TF_VAR_LINUX_USER_DEVOPS_DEB020325}"@"${LINUX_SERVER_IPADDRESS_DEB020325}":~/npm020325

# OR if you need to specify your identity file:
rsync -avvz -e "ssh -i ~/.ssh/id_ed25519_nopass_LINUX_SSH_KEY_DEB020325" ./npm020325/ "${TF_VAR_LINUX_USER_DEVOPS_DEB020325}"@"${LINUX_SERVER_IPADDRESS_DEB020325}":~/npm020325


# Start NPM containers

# Simple way to watch it boot & make sure it runs:
cd npm020325 && \
docker compose up

# This command is to Run in background, then check out logs.  It's a nice way to view the running container, while leaving it running after you exit the logs view.:
cd npm020325 && \
docker compose -vvv -f docker-compose.yml up --build --remove-orphans -d && \
docker compose logs -f nginx-proxy-mgr-012825

# Verify Nginx Proxy Manager is reachable by navigating to this address on your browser:
# NOTE: Be sure it's HTTP and not HTTPS! We haven't yet setup any SSL certs, so HTTPS won't reach anything
http://yourServerIP:81
```

## Docker Cross-Service Networking

### Primary Network Configuration

In your NPM Docker Compose file, define the shared network:

```yaml
networks:
  main-network--nginxproxymgr:
    name: main-network--nginxproxymgr
```

### Connecting Additional Services

For other Docker Compose files in different directories, connect to the shared network:

```yaml
services:
  your-application:
    image: your-image:tag
    networks:
      - main-network--nginxproxymgr

networks:
  main-network--nginxproxymgr:
    external: true
    name: main-network--nginxproxymgr
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

## ❗❗❗ See `npm020325/README.md` for more info on Nginx Proxy Manager setup

### Updating NPM Configuration

To transfer updates you make to your NPM Docker Compose file in a quick, automated way, run this rsync command from your developer environment (laptop), and assuming rsync is installed on the remote server, it'll transfer the whole `npm020325` directory to the server. Useful when initially setting things up & testing things out.

```bash
rsync -avvz ./npm020325/ "${TF_VAR_LINUX_USER_DEVOPS_DEB020325}"@"${LINUX_SERVER_IPADDRESS_DEB020325}":~/npm020325

```

### Verifying Network Configuration

Check network connections using Docker commands:

```bash
# List all networks
docker network ls

# Inspect network connections
docker network inspect main-network--nginxproxymgr

# View connected containers
docker network inspect main-network--nginxproxymgr -f '{{range .Containers}}{{.Name}} {{end}}'
```

This comprehensive guide provides the foundation for setting up a secure, well-organized server infrastructure using modern DevOps practices and tools.

# Resources & References

### Source of initial Terraform project code

- oleksii*y. (2022, June 5). \_How to create DigitalOcean droplet using Terraform. A-Z guide*. AWSTip.com. Retrieved from [https://awstip.com/how-to-create-digitalocean-droplet-using-terraform-a-z-guide-df91716f6021](https://awstip.com/how-to-create-digitalocean-droplet-using-terraform-a-z-guide-df91716f6021)
  - Archived Article: https://archive.is/I2Mh0
  - Original's Raw Source Code as an archived Github Gist: https://gist.githubusercontent.com/alexsplash/5f8f34f4020092b634dfd29316683718/raw/f6a4331346efe3bc333fb3cf1e91203faa1e7bf1/digitalocean.tf
-

# Deployment

Deploy the newest Nginx Proxy Manager config update via rsync instead of git project cloning:

```bash

# I think you might still need to install rsync manually, the cloud init script is failing to do so. (terraform-server--Debian-Jan2025-PortfolioEtc/yamlScripts/with-envVars.yaml)
sudo apt-get install -y rsync

rsync -avvz ./npm020325/ "${TF_VAR_LINUX_USER_DEVOPS_DEB020325}"@"${LINUX_SERVER_IPADDRESS_DEB020325}":~/npm020325

# if rsync isn't installed on remote server (and your laptop), be sure to install it first.  For debian, for example:
sudo apt install rsync -y

```

```bash
# for ssh login, I like to pull login & ip from 1pass:export TF_VAR_LINUX_USER_DEVOPS_DEB020325=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_USER_DEVOPS_DEB020325) && \
export TF_VAR_LINUX_USER_DEVOPS_DEB020325=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_USER_DEVOPS_DEB020325) && \
export LINUX_SERVER_IPADDRESS_DEB020325=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_SERVER_IPADDRESS_DEB020325)=LINUX_SERVER_IPADDRESS_DEB020325)

# then ssh in:
ssh "${TF_VAR_LINUX_USER_DEVOPS_DEB020325}"@"${LINUX_SERVER_IPADDRESS_DEB020325}"

# and maybe view the cloud-init logs to see how everything booted & make sure cloud init installed what it's supposed to (see bottom of ./terraform-server--Debian-Jan2025-PortfolioEtc/yamlScripts/with-envVars.yaml file)
sudo cat /var/log/cloud-init-output.log
```
