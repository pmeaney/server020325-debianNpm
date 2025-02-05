# SSH Troubleshooting

If you have issues with ssh, here are some troubleshooting ideas.

- First rule of ssh-ing from public places:
  - **Do not trust library wifi networks to allow port 22 access!** - A Little story: I setup a server from a cafe & ssh access worked. Then went to a library. Ssh access seemed to work initially, then at some point it quit. I thought I introduced a bug, and it was tough to debug. I noticed that my cicd runner still had ssh access to my DO Server, but not my laptop. Strange... Eventually I realized tried to trace the ssh port issue to the source and realized it was probably the library's network itself. So, I moved to a cafe and suddenly ssh (port 22) worked again. (Prior to leaving the library though, I changed my ~/.ssh/config file to use port 443 for github (instead of the default 22)-- and that worked.) Problem solved. -
    Prior to starting a new workflow... or returning to an old one after a while away, it's good to get an overview of what is happening between our ssh key on our laptop, vs. services like Github & DigitalOcean, which we access via ssh.

## Why we need ssh keys & how they work

When we try to ssh into a service, we're using our Private Key as our identity file (to prove our identity as "owner" of both keys-- that is, we originally created both and handed the public one to services we intend to connect to from our laptop), whereas the service we try to reach uses the Public Key we gave them to verify our login.

In more detail:

- When you try to connect, you have your private key (on your computer in ~/.ssh/)
- The server has your public key (which you previously uploaded/provided)
- The SSH protocol uses public key cryptography where:
  - The server sends you a challenge that can only be solved using your private key
  - Your SSH client uses your private key to solve this challenge
  - The server verifies the solution using your public key

## Github

- Add your ssh key via Account > Settings > Ssh & Gpg keys
- Run: `ssh -T git@github.com` to test the ssh connection.
- If you added an ssh key to Github, and want to check the fingerprint sh own on Github matches the one you expect it to me, you can run: `ssh-keygen -l -f ~/.ssh/id_ed25519_someKeyName`

- ssh key gen
- ssh add key to agent
- add key to github (do manually)
- add key to digital ocean server (happens via TF)

# copy key to server (or use TF to do so, which is what we do in the project)

ssh-copy-id -i ~/.ssh/key-filename.pub -p port# 'username@server.com'

# login

ssh -i ~/.ssh/key-filename -p port# 'username@server.com'

## DigitalOcean

You can test your ability to reach DO via SSH in a very simple way:

When you create a new DigitalOcean droplet, it's initially set up with just the root user. The SSH key you selected will be added to root's authorized_keys.

- Add an ssh to your DO account via its Security dashboard
- Boot up a server from DO's web browser dashboard. If you can reach it via ssh, you can generally ssh into your DO account's servers.
- Run `ssh root@your-droplet-ip` to test logging into the newly booted server.

If those were both successful, then your ssh key apparently works & has been uploaded correctly.

Now you're ready to use that same ssh key via Terraform-- where, we're basically just automating the "add this ssh key to the server" which DO lets you do during Droplet Setup on its dashboard

![Droplet dashboard-- SSh key](./docs-images/droplet-dashboard-sshkey-section.png)

```bash
ssh-keygen -t ed25519 -C "your.email@example.com" -f ~/.ssh/id_ed25519_gh_do_humanuser_020525
```

When sshing in, we have two options for specifying which key to use.

Simplest approach - specify the key
`ssh -i /path/to/your/private_key username@server_ip`

Better approach - configure SSH config file.
Once your user

`nano ~/.ssh/config`
Add this to your SSH config (replace ${LINUX_HUMAN_USERNAME} with your user's username):

For example, let's go with "deb" short for debian. The actual servername on DO is "server020525-debianNpm". but "ssh deb" is all we'll need to run in the CLI.

```bash
Host your-server-nickname
    HostName your-server-ip
    User ${LINUX_HUMAN_USERNAME}
    IdentityFile ~/.ssh/your_private_key

# For example
Host deb
    HostName your-server-ip
    User patDevOpsUser
    IdentityFile ~/.ssh/id_ed25519_gh_do_humanuser_020525


# The Host * with no HostName specified means "use these settings for any host I try to SSH to". This will make SSH use your specified key when connecting to any server, including both GitHub (for git operations) and your DigitalOcean droplets.
# A common practice is to put this as the last entry in your config file, so you can still override it with specific configurations if needed in the future:

# Specific overrides could go here
Host my-special-server
    IdentityFile ~/.ssh/special_key

# Default for everything else
Host *
    IdentityFile ~/.ssh/special_key

#########
# So I might use this-- (add the IP after tf generates the server)
AddKeysToAgent yes
UseKeychain yes

Host deb
    User patDevOpsUser
    Hostname <ServerIPHere>
    IdentityFile ~/.ssh/id_ed25519_gh_do_humanuser_020525

Host *
    IdentityFile ~/.ssh/id_ed25519_gh_do_humanuser_020525
########################

#### At the minimum, you'd want this:
Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519_gh_do_humanuser_020525

```
