
# Not sure if I want to create this yet... or simply keep exporting env var manually prior to `terraform apply`
# The purpose of this script is to
# - Create two ssh keys for 1 Human Dev (w/ pass) & 1 CICD Bot (nopass), so those two users can ssh into the remote server.  (Human dev will have priv key on laptop, CICD Bot will have priv key in Repo Secrets)
# - Upload those keys to DO, GH, & 1P

# And MAYBE... (or maybe its overkill vs. global vars in the bash script)
# - Prompt the user for the data needed for new server deploymnt

