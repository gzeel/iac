terraform {
  required_version = ">= 0.13"
  required_providers {
    esxi = {
      source = "registry.terraform.io/josenk/esxi"
    }
  }
}

provider "esxi" {
  esxi_hostname      = var.esxi_hostname
  esxi_hostport      = var.esxi_hostport
  esxi_hostssl       = var.esxi_hostssl
  esxi_username      = var.esxi_username
  esxi_password      = var.esxi_password
}

resource "esxi_guest" "vmtest" {
  guest_name         = var.vm_hostname
  disk_store         = var.disk_store
  ovf_source         = var.ovf_file
  network_interfaces {
    virtual_network  = var.virtual_network
  }

  ovf_properties {
    key = "hostname"
    value = "vmtest"
  }
}

output "ip" {
  value = [esxi_guest.vmtest.ip_address]
}