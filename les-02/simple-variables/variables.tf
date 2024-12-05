variable "esxi_hostname" {
  default = "192.168.100.91"
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
  # Unspecified will prompt
  default = "Welkom01!"
}

variable "virtual_network" {
  default = "VM Network"
}

variable "disk_store" {
  default = "datastore1"
}


variable "ovf_file" {
  #  A local file downloaded from https://cloud-images.ubuntu.com
  #default = "ubuntu-19.04-server-cloudimg-amd64.ova"

  #  Or specify a remote (url) file
  default = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.ova" 
}

variable "vm_hostname" {
  default = "vmtest01"
}
