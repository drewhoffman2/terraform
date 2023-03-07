provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

terraform {
  backend "s3" {
    #  backend cannot use variables...
    bucket         = "funnelcloud-terraform-state"
    key            = "fcsOci/bastion-host/terraform.tfstate"
    region         = "us-west-2"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    # Replace this with your bucket name!
    bucket = "funnelcloud-terraform-state"
    key    = "env:/${terraform.workspace}/fcsOci/vpc/terraform.tfstate"
    region = "us-west-2"
  }
}

resource "oci_core_instance" "bastion" {
  display_name = "${var.projectName} TF Bastion"
  compartment_id = "${var.compartment_ocid}"
  availability_domain = "${var.privateAZ}"
  shape = "${var.bastionShape}"
  freeform_tags = {
    "Name" = "${var.projectName} Bastion"
    "Billing" = "${var.projectName}"
  }
  create_vnic_details {
    subnet_id     = data.terraform_remote_state.vpc.outputs.bastion_subnet
  }
  
  source_details {
    source_id = "${var.bastionImage}"
    source_type = "image"
  }
  
  metadata = {
    ssh_authorized_keys = "${file("${var.runtime_public_key_path}")}"
  }

  connection {
    type        = "ssh"
    agent       = false
    private_key = "${file("${var.runtime_private_key_path}")}"
    host        = "${oci_core_instance.bastion.public_ip}"
    user        = "opc"
  }

  provisioner "file" {
    source = "${var.runtime_private_key_path}"
    destination = "/home/opc/.ssh/bastion"
  }

  provisioner "remote-exec" {
     inline = [
       "sudo chmod 600 /home/opc/.ssh/bastion"
     ]
  }
}

resource "oci_core_volume" "db_volume" {
    compartment_id = "${var.compartment_ocid}"
    availability_domain = "${var.privateAZ}"
    size_in_gbs = "50"
    vpus_per_gb = "100"
}

resource "oci_core_volume_attachment" "db_volume_attachment" {
    attachment_type = "paravirtualized"
    instance_id = oci_core_instance.bastion.id
    volume_id = oci_core_volume.db_volume.id
}
