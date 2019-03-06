// Terraform Variables
variable "gcp_credentials" {
  description = "GCP credentials needed by google provider"
}

variable "gcp_project" {
  description = "GCP project name"
}

variable "gcp_region" {
 description = "GCP region"
 default = "us-central1"
}

// Google Provider Configuration
provider "google" {
  credentials = "${var.gcp_credentials}"
  project     = "${var.gcp_project}"
  region      = "${var.gcp_region}"
}

//--------------------------------------------------------------------
//--------------------------------------------------------------------
//--------------------------------------------------------------------
// Variables
variable "compute_instance_count" {}
variable "compute_instance_disk_image" {}
variable "compute_instance_disk_size" {}
variable "compute_instance_machine_type" {}




//--------------------------------------------------------------------
// Modules
module "compute_instance" {
  source  = "app.terraform.io/aworkman/compute-instance/google"
  version = "0.1.4"

  count = "1"
  disk_image = "${var.compute_instance_disk_image}"
  disk_size = "${var.compute_instance_disk_size}"
  machine_type = "${var.compute_instance_machine_type}"
  name_prefix = "aworkman-demo"
  subnetwork = "${module.network_subnet.self_link}"
}

module "network_firewall" {
  source  = "app.terraform.io/aworkman/network-firewall/google"
  version = "0.1.5"

  description = "Demo Firewall Rule - Allow TCP 80"
  name = "allow-tcp-80"
  network = "${module.network.self_link}"
  ports = [80]
  priority = 100
  protocol = "TCP"
  source_ranges = ["0.0.0.0/0"]
}

module "network_subnet" {
  source  = "app.terraform.io/aworkman/network-subnet/google"
  version = "0.1.2"

  description = "Demo Subnet"
  ip_cidr_range = "172.16.0.0/16"
  name = "demo-subnet"
  vpc = "${module.network.self_link}"
}

module "network" {
  source  = "app.terraform.io/aworkman/network/google"
  version = "0.1.3"

  auto_create_subnetworks = "false"
  description = "Demo Network"
  name = "demo-network"
}
  
// Terraform outputs
output "network_name" {
  value = "${module.network.name}"
}
  
output "subnet_gateway_address" {
  value = "${module.network_subnet.gateway_address}"
} 
  
output "firewall_self_link" {
  value = "${module.network_firewall.self_link}"
}
  
output "compute_instance_addresses" {
  value = "${module.compute_instance.addresses}"
}
