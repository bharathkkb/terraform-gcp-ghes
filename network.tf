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

module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 2.5"
  project_id   = module.project-services.project_id
  network_name = var.network

  subnets = [
    {
      subnet_name   = var.subnet
      subnet_ip     = "10.0.0.0/17"
      subnet_region = var.region
    }
  ]
}

resource "google_compute_firewall" "ghes_fw" {
  name           = "allow-ingress-ghes"
  network        = module.gcp-network.network_name
  project        = module.project-services.project_id
  direction      = "INGRESS"
  enable_logging = true
  priority       = 900

  source_ranges = ["10.0.0.0/17"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "25", "80", "122", "443", "8080", "8443", "9418"]
  }

  allow {
    protocol = "udp"
    ports    = ["161", "1194"]
  }

  target_service_accounts = [google_service_account.ghes_sa.email]

}

module "cloud-nat" {
  source        = "terraform-google-modules/cloud-nat/google"
  version       = "~> 1.2"
  project_id    = module.project-services.project_id
  region        = var.region
  router        = "ghes-router"
  network       = module.gcp-network.network_self_link
  create_router = true
}
