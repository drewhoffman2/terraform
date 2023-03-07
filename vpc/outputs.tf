output "vpc" {
  value       = oci_core_vcn.two_tier.id
  description = "VPC of project"
}
output "public_subnet" {
  value       = oci_core_subnet.public.id
  description = "The public subnet"
}
output "bastion_subnet" {
  value       = oci_core_subnet.bastion_subnet.id
  description = "The public subnet"
}
output "private_subnet" {
  value       = oci_core_subnet.private.id
  description = "The private subnet"
}
output "bastion_front_sg" {
  value       = oci_core_security_list.bastion_front.id
  description = "Firewall rules in front of bastion"
}

output "bastion_back_sg" {
  value       = oci_core_security_list.bastion_back.id
  description = "Firewall rules in back of bastion"
}
output "public_sg" {
  value       = oci_core_security_list.public_face.id
  description = "Public Firewall rules"
}
