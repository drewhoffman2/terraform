provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.30"
    }
  }
  backend "s3" {
   #  backend cannot use variables...
    bucket         = "funnelcloud-terraform-state"
    key            = "fcsOci/vpc/terraform.tfstate"
    region         = "us-west-2"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

resource "oci_core_vcn" "two_tier" {
  cidr_block     = "${var.vpcCidr}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "vcn ${var.projectName}"
  dns_label      = "${var.dnsLabel}"
  
  freeform_tags = {
     "Name" = "${var.projectName} VCN",
     "Billing" = "${var.projectName}",
  }

}

resource "oci_core_internet_gateway" "gw" {
  vcn_id     = "${oci_core_vcn.two_tier.id}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "${var.projectName} IGW"

  freeform_tags = {
    "Name" = "${var.projectName} IGW",
    "Billing" = "${var.projectName}"
  }
}
# firewall to bastion
resource "oci_core_security_list" "bastion_front" {
  display_name        = "${var.projectName} SL bastion front"
  vcn_id     = "${oci_core_vcn.two_tier.id}"
  compartment_id = "${var.compartment_ocid}"

  ingress_security_rules {
    protocol    = "6"
    source = "${var.remoteAccessCidr}"
    tcp_options {
        min = 22
        max = 22
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source = "${var.remoteAccessCidr2}"
    tcp_options {
        min = 22
        max = 22
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source = "${var.terraformAdminCidr}"
    tcp_options {
        min = 22
        max = 22
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  freeform_tags = {
    "Name" = "${var.projectName} Bastion SL",
    "Billing" = "${var.projectName}"
  }

}

# firewall from bastion
resource "oci_core_security_list" "bastion_back" {
  display_name        = "${var.projectName} SL bastion back"
  vcn_id     = "${oci_core_vcn.two_tier.id}"
  compartment_id = "${var.compartment_ocid}"

  ingress_security_rules {
    protocol    = "6"
    # cannot tie to security list,  may want a bastion subnet....
    source = "${var.bastionSubCidr}"
    tcp_options {
        min = 22
        max = 22
    }
  }

  ingress_security_rules {
    protocol    = "6"
    # cannot tie to security list,  may want a bastion subnet....
    source = "${var.bastionSubCidr}"
    tcp_options {
        min = 1521
        max = 1521
    }
  }
  ingress_security_rules {
    protocol    = "6"
    # cannot tie to security list,  may want a bastion subnet....
    source = "${var.privSubCidr}"
    tcp_options {
        min = 1521
        max = 1521
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  freeform_tags = {
    "Name" = "${var.projectName} Bastion Back SL",
    "Billing" = "${var.projectName}"
  }

}

resource "oci_core_security_list" "public_face" {
  display_name        = "${var.projectName} SL Public"
  vcn_id     = "${oci_core_vcn.two_tier.id}"
  compartment_id = "${var.compartment_ocid}"

  ingress_security_rules {
    protocol    = "6"
    source = "0.0.0.0/0"
    tcp_options {
        min = 80
        max = 80
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source = "0.0.0.0/0"
    tcp_options {
        min = 443
        max = 443
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
  freeform_tags = {
    "Name" = "${var.projectName} Public SL",
    "Billing" = "${var.projectName}"
  }

}

# public IP is implied for NAT vs set in AWS
resource "oci_core_nat_gateway" "ngw" {
  vcn_id     = "${oci_core_vcn.two_tier.id}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "${var.projectName} NAT"
  freeform_tags = {
    "Name" = "${var.projectName} NAT",
    "Billing" = "${var.projectName}"
  }
}

resource "oci_core_route_table" "r_pub" {
  vcn_id     = "${oci_core_vcn.two_tier.id}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "${var.projectName} public route"

  freeform_tags = {
    "Name" = "${var.projectName} public route",
    "Billing" = "${var.projectName}"
  }

  route_rules {
    network_entity_id = "${oci_core_internet_gateway.gw.id}"
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "public" {
  vcn_id     = "${oci_core_vcn.two_tier.id}"
  cidr_block = "${var.pubSubCidr}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "Public subnet ${var.projectName}"
  prohibit_public_ip_on_vnic = "false"
  security_list_ids = ["${oci_core_security_list.public_face.id}", "${oci_core_security_list.bastion_back.id}"]
  dns_label      = "pu${var.dnsLabel}"

  freeform_tags = {
     "Name" = "${var.projectName} Public",
     "Billing" = "${var.projectName}",
  }
}

resource "oci_core_subnet" "private" {
  vcn_id     = "${oci_core_vcn.two_tier.id}"
  cidr_block = "${var.privSubCidr}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "Private subnet ${var.projectName}"
  prohibit_public_ip_on_vnic = "true"
  security_list_ids = ["${oci_core_security_list.bastion_back.id}"]
  dns_label      = "pv${var.dnsLabel}"

  freeform_tags = {
     "Name" = "${var.projectName} Private",
     "Billing" = "${var.projectName}",
  }
}

resource "oci_core_subnet" "bastion_subnet" {
  vcn_id     = "${oci_core_vcn.two_tier.id}"
  cidr_block = "${var.bastionSubCidr}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "Bastion subnet ${var.projectName}"
  prohibit_public_ip_on_vnic = "false"
  security_list_ids = ["${oci_core_security_list.bastion_front.id}"]

  freeform_tags = {
     "Name" = "${var.projectName} Bastion",
     "Billing" = "${var.projectName}",
  }
}

resource "oci_core_route_table_attachment" "ma_bast" {
  subnet_id = "${oci_core_subnet.bastion_subnet.id}"
  route_table_id ="${oci_core_route_table.r_pub.id}"
}

resource "oci_core_route_table_attachment" "ma_pub" {
  subnet_id = "${oci_core_subnet.public.id}"
  route_table_id ="${oci_core_route_table.r_pub.id}"
}

resource "oci_core_route_table" "r_priv" {
  vcn_id     = "${oci_core_vcn.two_tier.id}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "${var.projectName} private route"

  freeform_tags = {
    "Name" = "${var.projectName} private route",
    "Billing" = "${var.projectName}"
  }

  route_rules {
    network_entity_id = "${oci_core_nat_gateway.ngw.id}"
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

resource "oci_core_route_table_attachment" "ma_priv" {
  subnet_id = "${oci_core_subnet.private.id}"
  route_table_id ="${oci_core_route_table.r_priv.id}"
}
