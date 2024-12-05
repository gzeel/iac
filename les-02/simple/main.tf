terraform {
  required_version = ">= 0.13"
  required_providers {
    esxi = {
      source = "registry.terraform.io/josenk/esxi"
    }
  }
}

provider "esxi" {
  esxi_hostname      = "192.168.100.40"
  esxi_hostport      = "22"
  esxi_hostssl       = "443"
  esxi_username      = "root"
  esxi_password      = "Welkom01!"
}

resource "esxi_guest" "vmtest" {
  guest_name         = "vmtest"
  disk_store         = "datastore1"

  ovf_source = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.ova"
  network_interfaces {
    virtual_network = "VM Network"
  }

  ovf_properties {
    key = "hostname"
    value = "vmtest"
  }
}
