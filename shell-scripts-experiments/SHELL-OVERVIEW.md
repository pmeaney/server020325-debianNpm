# Shell Script Process

Update:

Assume we have a presets section of the script with the info we need--
NOT to ask the user for info.

Just have them put the info in a presets section of the script.

Keep it simple-- this just for me for the most part!

---

Here's what we'll eventually have.

## Manual steps:

- You manually create:
  - DO Token (full access)
  - GH PAT ()
    - Required scopes: admin:public_key, repo, read:org
    - Those scopes are for upcoming action: automatic upload to github of public ssh key

## Automated steps:

### Step 0: Set Presets file

Initially, Prompt the user to ask if they want to auto-gen a presets file
('1pass-presets.yml') containing their preferred Vault & SecureNote name.
If one doesnt exist, create it.
if it exists check if the fields exist, ask if we want to use them, without recreating
if the fields dont exist, ask to create them

In the next step, before asking if they want to use existing or create new 1pass vault & secure note... first, ask ift hey want to use presets.

preset file's fields:
vaultname
secureNoteName
emailaddress (for ssh keys)
devops-username
cicdbot-username
server-name

### Step 1: Token & 1pass setup

- You run ex1.bash (ex1 = example1. working name.)

- ex1.bash does the following:
  - Prompts you for yout DO Token & GH PAT
  - Prompts you for 1pass Vault & SecureNote setup preferences
  - Uploads DO Token & GH PAT into a vault you picked

### Step 2: SSH Key Setup & Upload

3 ssh keys are typically needed for this project:

1. General SSH key for Laptop <-> Github communication. You probably already have one. In which case, no need to make one.
2. A Human User ssh key for logging into the DigitalOcean server we'll launch with Terraform, via our developer laptop.
3. A CICD Bot User ssh key for logging into the DigitalOcean server via a Github Actions CICD process we'll create in the future

So, Step 2 will automate all 3, or if you prefer, just the last two.

### Step 3: Setup of remaining Terraform-related input & output secrets

In our Terraform project, we input & output some secrets. Let's automate the setup of those.
Our goal is to automate their preparation for use with Terraform (i.e. import them into 1pass, then inject them into our shell env)

The following shows inputs.
We also want to import to 1pass the output from terraform (IP address).

##### Terraform variables

- We need to export them so our Terraform processes can access them.
- We could hardcode these into the terraform file, but that wouldn't be as secure as
- exporting them into the current shell env, from storage in a password manager (1password in this case)
- For more info on how ssh keys are used in this project, see [./docs/GUIDE-SSH-KEY-SETUP.md](./docs/GUIDE-SSH-KEY-SETUP.md)
- General: DO token, & name to give server
  export DIGITALOCEAN_ACCESS_TOKEN=$(op item get "2025 Feb 020325 Debian project" --fields label=TF_VAR_DIGITAL_OCEAN_TOKEN_DEB020325) &&
  for DIGITALOCEAN_ACCESS_TOKEN... can we create is automatically (now that we CLI logged into DO w/ admin DO key in the first phase of the script)

- We'll prompt the user for some of them
- Others, we'll generate based on presets
  - 2 ssh keys: Human developer & CICD bot (cicd bot we won't use now, but for simplicity we'll add them into the server. (the pub key, which the server uses to verify ssh logins from its end))

```bash

export DIGITALOCEAN_ACCESS_TOKEN=$(op item get "2025 Feb 020325 Debian project" --fields label=TF_VAR_DIGITAL_OCEAN_TOKEN_DEB020325) &&
export TF_VAR_LINUX_SERVER_NAME_DEB020325=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_SERVER_NAME_DEB020325) &&

# Human user secrets: ssh pub key, ssh user, ssh pw
export TF_VAR_LINUX_HUMAN_SSH_KEY_PUB_WITHPASS_DEB020325=$(op item get "2025 Feb 020325 Debian project" --fields label=id_ed25519_withpass_DO_TF_HUMAN_SSH_KEY_DEB020325) &&
export TF_VAR_LINUX_USERNAME_DEVOPS_HUMAN_DEB020325=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_USERNAME_DEVOPS_HUMAN_DEB020325) &&
export TF_VAR_LINUX_USERPASSWORD_DEVOPS_HUMAN_DEB020325=$(op item get "2025 Feb 020325 Debian project" --fields label=LINUX_USERPASSWORD_DEVOPS_HUMAN_DEB020325) &&

# CICD bot user secrets: ssh pub key, ssh user, (no ssh pw for bot user)
export TF_VAR_LINUX_GHACICD_BOT_SSH_KEY_PUB_NOPASS_DEB020325=$(op item get "2025 Feb 020325 Debian project" --fields label=id_ed25519_nopass_GHACICD_BOT_SSH_KEY_DEB020325) &&
export TF_VAR_TF_VAR_LINUX_USERNAME_GHA_CICD_BOT_DEB020325=$(op item get "2025 Feb 020325 Debian project" --fields label=TF_VAR_LINUX_USERNAME_GHA_CICD_BOT_DEB020325)
``
```
