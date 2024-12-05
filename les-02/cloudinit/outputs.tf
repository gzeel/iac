#
#  Outputs are a great way to output information about your apply.
#

output "db_ip" {
  value = esxi_guest.dbserver[0].ip_address
}
