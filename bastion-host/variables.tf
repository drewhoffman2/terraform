variable "projectName" {
  default = "FCS"
}
variable "s3-management-bucket" {
  default = "funnelcloud-terraform-state"
}
variable "tenancy_ocid" {
  default = "ocid1.tenancy.oc1..aaaaaaaa36nk3eohlds5hpe7njfw32yzdckvpzt4abmuuwr6znykmgzpyhwa"
}
variable "user_ocid" {
  default = "ocid1.user.oc1..aaaaaaaau3csktqbvlt7hcirg2ggigo54g7e2qouqb2h3edmqnqq6w6zaeoa"
}
variable "fingerprint" {
  default = "4b:cb:14:63:9a:73:ef:77:1a:9a:96:1a:fd:d0:8f:84"
}
variable "private_key_path" {
  default = "/Users/shoffman/terraform/fcsOci/.oci/oci_api_fcs_key.pem"
}
variable "public_key_path" {
  default = "/Users/shoffman/terraform/fcsOci/.oci/oci_api_fcs_key_public.pem"
}
variable "runtime_private_key_path" {
  default = "/Users/shoffman/terraform/fcsOci/.oci/bastion"
}
variable "runtime_public_key_path" {
  default = "/Users/shoffman/terraform/fcsOci/.oci/bastion.pub"
}
variable "compartment_ocid" {
  default = "ocid1.compartment.oc1..aaaaaaaa4pmnhdrsfttpwvbyudc35t7l7ul2bdebd3trunrw4aj3x5hbplea"
}
variable "region" {
  default = "us-phoenix-1"
}
variable "publicAZ" {
  #default = "pzKl:PHX-AD-1"
  default = "IAEi:PHX-AD-1"
}
variable "privateAZ" {
  #default = "pzKl:PHX-AD-1"
  default = "IAEi:PHX-AD-1"
}

variable "profile" {
  default = "terraform"
}
variable "bastionImage" {
  default = "ocid1.image.oc1.phx.aaaaaaaanhtusuji7yyuss3y64yjgaexmnk4rgydwqrrobjzfncjyteh3h2a"
}
variable "bastionShape" {
  default = "VM.Standard.E2.1.Micro"
}
