# tf with env vars fed from OS CLI

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

locals {
  // Map of pre-named sizes to look up from
  // See https://docs.digitalocean.com/products/droplets/details/pricing/
  // for how a value below maps to a server size & price
  // e.g.:
  # API/CLI Slug	CPUs	Mem(GiB)	SSD (GiB)	Price (hourly)	      Price (monthly)
  # s-1vcpu-1gb	  1     1	        25	      $0.008928571428571428	$6
  # s-1vcpu-2gb	  1	    2	        50	      $0.017857142857142856	$12
  # s-2vcpu-2gb	  2	    2	        60	      $0.026785714285714284	$18
  # s-2vcpu-4gb	  2	    4	        80	      $0.03571428571428571	$24
  sizes = {
    nano      = "s-1vcpu-1gb"
    nano-plus = "s-1vcpu-2gb"
    micro     = "s-2vcpu-2gb"
    small     = "s-2vcpu-4gb"
    medium    = "s-4vcpu-8gb"
    large     = "s-6vcpu-16gb"
    x-large   = "s-8vcpu-32gb"
    xx-large  = "s-16vcpu-64gb"
    xxx-large = "s-24vcpu-128gb"
    maximum   = "s-32vcpu-192gb"
  }
  // Map of regions
  regions = {
    new_york_1    = "nyc1"
    new_york_3    = "nyc3"
    san_francisco = "sfo3"
    amsterdam     = "ams3"
    singapore     = "sgp1"
    london        = "lon1"
    frankfurt     = "fra1"
    toronto       = "tor1"
    india         = "blr1"
  }
}

provider "digitalocean" {}

# the SERVER_NAME is not as important to set via env var... but we will go ahead and do it
variable "LINUX_SERVER_NAME_DEB020325" {
  type = string
  description = "environment variable for devops user"
  default = "blahServerName"
}

variable "LINUX_USERNAME_DEVOPS_HUMAN_DEB020325" {
  type = string
  description = "environment variable for devops user"
  default = "blahLinuxUser"
}

variable "LINUX_USERNAME_GHA_CICD_BOT_DEB020325" {
  type = string
  description = "environment variable for github actions cicd bot user (so it can login to run tasks)"
  default = "blahLinuxUser"
}

variable "LINUX_USERPASSWORD_DEVOPS_HUMAN_DEB020325" {
  type = string
  description = "environment variable for devops users password"
  default = "blahLinuxUserPassword"
}

variable "LINUX_HUMAN_SSH_KEY_PUB_WITHPASS_DEB020325" {
  type = string
  description = "environment variable for Human Developers devops ssh key"
  default = "blahSshKey"
}

variable "LINUX_GHACICD_BOT_SSH_KEY_PUB_NOPASS_DEB020325" {
  type = string
  description = "environment variable for CICD Runner bots devops ssh key"
  default = "blahSshKey"
}

data "template_file" "my_example_user_data" {
  template = templatefile("./yamlScripts/with-envVars.yaml",
    {
      # For dev login
      LINUX_USERNAME_DEVOPS_HUMAN_DEB020325 = "${var.LINUX_USERNAME_DEVOPS_HUMAN_DEB020325}",
      LINUX_USERPASSWORD_DEVOPS_HUMAN_DEB020325 = "${var.LINUX_USERPASSWORD_DEVOPS_HUMAN_DEB020325}",
      LINUX_HUMAN_SSH_KEY_PUB_WITHPASS_DEB020325 = "${var.LINUX_HUMAN_SSH_KEY_PUB_WITHPASS_DEB020325}",

      # For Github Actions ("GHA") CICD bot to log in.  no pass item b/c the ssh key has no pass-- the ssh key is only for cicd bot
      LINUX_USERNAME_GHA_CICD_BOT_DEB020325 = "${var.LINUX_USERNAME_GHA_CICD_BOT_DEB020325}",
      LINUX_GHACICD_BOT_SSH_KEY_PUB_NOPASS_DEB020325 = "${var.LINUX_GHACICD_BOT_SSH_KEY_PUB_NOPASS_DEB020325}",
    })
}


resource "digitalocean_droplet" "droplet" {
  image     = "debian-12-x64"
  name      = "${var.LINUX_SERVER_NAME_DEB020325}"
  region    = local.regions.san_francisco
  size      = local.sizes.nano-plus
  tags      = ["DEB020325", "2025", "portfolio", "terraform", "docker", "debian"]
  user_data = data.template_file.my_example_user_data.rendered
}

output "ip_address" {
  value       = digitalocean_droplet.droplet.ipv4_address
  description = "The public IP address of your droplet."
}

output "droplet_size" {
  value       = digitalocean_droplet.droplet.size
  description = "The public IP address of your droplet."
}

output "tf_apply_timestamp" {
  value       = timestamp()
  description = "Timestamp of apply"
}

# If you want to make sure the yaml file was properly filled with env vars, you can uncomment this output statement and terraform will show the env vars in situ
# output "template_file_contents" {
#   value = data.template_file.my_example_user_data.rendered
# }

output "LINUX_SERVER_NAME_DEB020325" {
  value = "${var.LINUX_SERVER_NAME_DEB020325}"
}

output "LINUX_USERNAME_DEVOPS_HUMAN_DEB020325" {
  value = "${var.LINUX_USERNAME_DEVOPS_HUMAN_DEB020325}"
}
output "LINUX_USERNAME_GHA_CICD_BOT_DEB020325" {
  value = "${var.LINUX_USERNAME_GHA_CICD_BOT_DEB020325}"
}

output "LINUX_HUMAN_SSH_KEY_PUB_WITHPASS_DEB020325" {
  value = "${var.LINUX_HUMAN_SSH_KEY_PUB_WITHPASS_DEB020325}"
}

output "LINUX_GHACICD_BOT_SSH_KEY_PUB_NOPASS_DEB020325" {
  value = "${var.LINUX_GHACICD_BOT_SSH_KEY_PUB_NOPASS_DEB020325}"
}