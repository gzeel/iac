#
#  See https://www.terraform.io/intro/getting-started/variables.html for more details.
#

#  Change these defaults to fit your needs!

variable "esxi_hostname" {
  default = "192.168.100.40"
}

variable "esxi_hostport" {
  default = "22"
}

variable "esxi_hostssl" {
  default = "443"
}

variable "esxi_username" {
  default = "root"
}

variable "esxi_password" {
  default = "Welkom01!"
}

variable "virtual_network" {
  default = "VM Network"
}

variable "disk_store" {
  default = "datastore1"
}

variable "ovf_file" {
  default = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.ova" 
}

variable "public_key" {
  default = "AAAAC3NzaC1lZDI1NTE5AAAAIF6G9pDoOboYjf3yABBbgs1i/p8S2sKQoeFz5LSj8rnj"
}

variable "ssh_username" {
  default = "ansible"
}
