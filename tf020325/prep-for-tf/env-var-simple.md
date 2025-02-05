For the Shell Environment variables we'll be exporting into our shell,
We give them this convention in the tf & tf-cloud-config.yml script:
`LINUX_<ENTITY>_<ATTRIBUTE>` (Linux is just a reminder that its for our Debian Linux server)

We'll also need to create one called `LINUX_SERVER_IPADDRESS` in vault, since 1pass will insert our server's IP there.

So, these are the items we'll have in 1pass:
`DIGITALOCEAN_TOKEN` - a DO Token with full access. Must be exported to shell env as a var named `DIGITALOCEAN_TOKEN` for the TF DigitalOcean Provider to recognize it.
`LINUX_HUMAN_SSHKEY` - public ssh key for human ssh user. So we can log into the server tf creates.
`LINUX_HUMAN_USERNAME` - username for human user's ssh login session
`LINUX_HUMAN_USERPASS` - password for human ssh user. I think DO requires a pw-protected ssh key for at least one user, though I could be wrong.
`LINUX_CICDGHA_USERNAME` - username for CICD Runner's ssh login session
`LINUX_CICDGHA_SSHKEY` - public ssh key for CICD Runner. Eventually we'll add the corresponding private key to a github repo so the CICD Runner can login.
`LINUX_SERVER_NAME` - name it whatever you'd want to see in the DigitalOcean Droplets Dashboard
`LINUX_SERVER_IPADDRESS` - leave empty (TF will run a 1pass CLI command to update it with our servers IP address)

Additionally:

- We must set "DIGITALOCEAN_TOKEN" to the value of a DO Token as the ["Digital Ocean Provider" docs page](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs#argument-reference) mentions:
  - > token - (Required) This is the DO API token.
    >
    > Alternatively, this can also be specified using environment variables ordered by precedence:
    >
    > DIGITALOCEAN_TOKEN
    > DIGITALOCEAN_ACCESS_TOKEN
- All other shell env vars must be prefixed with `TF_VAR_`, because they're just general terraform variables, unrelated to DO.
- The `TF_VAR_` prefix is only needed for variables you want to pass directly to Terraform configurations.
- DIGITALOCEAN_TOKEN is a provider-specific authentication variable that DigitalOcean's Terraform provider looks for directly, while

So, ultimately, we'll export our shell env vars in this structure:
`TF_VAR_LINUX_<ENTITY>_<ATTRIBUTE>`

We'll need 2 ssh keys-- for example:
`ssh-keygen -t ed25519 -C "patrick.wm.meaney@gmail.com" -f ~/.ssh/id_ed25519_gh_do_humanuser_020525`
`ssh-keygen -t ed25519 -C "patrick.wm.meaney@gmail.com" -f ~/.ssh/id_ed25519_gha_cicduser_020525`
See what ssh keys your ssh agent has:
`ssh-add -L`
Add your new ones:
`ssh-add ~/.ssh/id_ed25519_gh_do_humanuser_020525`
`ssh-add ~/.ssh/id_ed25519_gha_cicduser_020525`

Terraform will automatically add these onto the server, much as you'd do manually if you were to create the droplet from the DO Droplet Creation Dashboard. Basically, you'd preload (manually copy & paste) the ssh key into Settings > Security > Ssh keys. Then Navigate to the DO Droplet Creation Dashboard, and you'll have the option to add one or more ssh keys (preloaded ones) or add new ones from the creation dashboard.

In this case, TF will do that for us, as shown in our `tf-cloud-config.yml` file.

export DIGITALOCEAN_TOKEN=dop_v1_c856bf20ssssSomeLongValueeee
export TF_VAR_LINUX_HUMAN_SSHKEY=publicSshKey-for-humanuser
export TF_VAR_LINUX_HUMAN_USERNAME=humanDevopsUser
export TF_VAR_LINUX_HUMAN_USERPASS=i-like-using-1pass-pw-generator
export TF_VAR_LINUX_CICDGHA_USERNAME=ghaCICDUser
export TF_VAR_LINUX_CICDGHA_SSHKEY=publicSshKey-for-cicd-bot-of-github-actions
export TF_VAR_LINUX_SERVER_NAME=serverName-shown-in-DO-dashboard

So, all those items will need to be set up in a Vault & an Item ("Secure Note"). I usually set up all as text, except for passwords & tokens.

- Since I'm using 1password, I like to use the 1password CLI tool to export the env vars directly from 1password using this command...
  - For example, assuming I have an item named "DIGITALOCEAN_TOKEN" with a value of the token, I can do this:
    - `op item get ${ITEM_1P} --fields label=DIGITALOCEAN_TOKEN`

Where ${ITEM_1P} is the "Item" within a vault-- For me, I typically use a Secure note with a title such as "2025 Feb 020525 DebianServer". To use ITEM_1P in my shell, I need to set it before using it:

```bash
ITEM_1P="2025 Feb 020525 DebianServer"
export DIGITALOCEAN_TOKEN=$(op item get ${ITEM_1P} --fields label=DIGITALOCEAN_TOKEN)
export TF_VAR_LINUX_HUMAN_SSHKEY=$(op item get ${ITEM_1P} --fields label=LINUX_HUMAN_SSHKEY)
export TF_VAR_LINUX_HUMAN_USERNAME=$(op item get ${ITEM_1P} --fields label=LINUX_HUMAN_USERNAME)
export TF_VAR_LINUX_HUMAN_USERPASS=$(op item get ${ITEM_1P} --fields label=LINUX_HUMAN_USERPASS)
export TF_VAR_LINUX_CICDGHA_USERNAME=$(op item get ${ITEM_1P} --fields label=LINUX_CICDGHA_USERNAME)
export TF_VAR_LINUX_CICDGHA_SSHKEY=$(op item get ${ITEM_1P} --fields label=LINUX_CICDGHA_SSHKEY)
export TF_VAR_LINUX_SERVER_NAME=$(op item get ${ITEM_1P} --fields label=LINUX_SERVER_NAME)
```
