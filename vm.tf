/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

data "google_compute_image" "ghes" {
  name    = "github-enterprise-2-22-0"
  project = "github-enterprise-public"
}

resource "google_compute_address" "ghes_external_ip_address" {
  count   = var.enable_external_ip ? 1 : 0
  project = module.project-services.project_id
  region  = var.region
  name    = "ghes-external-ip-address"
}

resource "google_compute_address" "ghes_internal_ip_address" {
  project      = module.project-services.project_id
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = module.gcp-network.subnets_names[0]
  name         = "ghes-internal-ip-address"
}

resource "google_service_account" "ghes_sa" {
  project      = module.project-services.project_id
  account_id   = "ghes-sa"
  display_name = "SA for GHES VM"
}

module "instance_template" {
  source       = "terraform-google-modules/vm/google//modules/instance_template"
  project_id   = module.project-services.project_id
  region       = var.region
  machine_type = "n1-standard-8"
  disk_type    = "pd-ssd"
  disk_size_gb = "300"
  additional_disks = [
    {
      disk_size_gb = 100
      disk_type    = "pd-ssd"
      auto_delete  = "false"
      boot         = "false"
    }
  ]
  source_image         = "github-enterprise-2-22-0"
  source_image_project = "github-enterprise-public"
  subnetwork           = module.gcp-network.subnets_names[0]
  source_image_family  = ""
  subnetwork_project   = module.project-services.project_id
  service_account = {
    email  = google_service_account.ghes_sa.email
    scopes = ["cloud-platform"]
  }
  name_prefix = "ghes"
}

module "compute_instance" {
  source             = "terraform-google-modules/vm/google//modules/compute_instance"
  region             = var.region
  subnetwork         = module.gcp-network.subnets_names[0]
  subnetwork_project = module.project-services.project_id
  static_ips         = [google_compute_address.ghes_internal_ip_address.address]
  hostname           = "ghes-instance"
  instance_template  = module.instance_template.self_link
  access_config = var.enable_external_ip ? [{
    nat_ip       = google_compute_address.ghes_external_ip_address[0].address
    network_tier = "PREMIUM"
  }] : []
}
