output "bastion_public_ip" {
  value       = oci_core_instance.bastion.public_ip
  description = "Public IP of bastion"
}
