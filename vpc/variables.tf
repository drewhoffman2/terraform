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
variable "compartment_ocid" {
  default = "ocid1.compartment.oc1..aaaaaaaa4pmnhdrsfttpwvbyudc35t7l7ul2bdebd3trunrw4aj3x5hbplea"
}
variable "region" {
  default = "us-phoenix-1"
}
variable "publicAZ" {
  default = "PHX-AD-1"
}
variable "privateAZ" {
  default = "PHX-AD-1"
}

variable "profile" {
  default = "terraform"
}
variable "vpcCidr" {
  default = "10.0.0.0/16"
}
variable "privSubCidr" {
  default = "10.0.2.0/24"
}
variable "pubSubCidr" {
  default = "10.0.1.0/24"
}
variable "bastionSubCidr" {
   default = "10.0.3.0/28"
}
# whitelist of who can get to bastion
# work
variable "remoteAccessCidr" {
  default = "73.3.174.245/32"
}
# home
variable "remoteAccessCidr2" {
  default = "68.99.85.41/32"
}
variable "dnsLabel"  {
  default = "funnelcloud"
}

# this would be the public ip of this box that we run Terraform from 
# switching to hioe as we drive on mac
variable "terraformAdminCidr" {
  default = "68.99.85.41/32"
}
# this is not used but this is the default location for s3 Dynamo backend
variable "shared_credentials_file" {
  default = "/Users/shoffman/.aws/credentials"
}
