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


output "bastion_ssh_command" {
  description = "gcloud command to ssh and port forward to the bastion host command"
  value       = format("gcloud beta compute ssh %s --tunnel-through-iap --project %s --zone %s -- -L8080:%s:80", module.bastion.hostname, var.project_id, "us-central1-a", google_compute_address.ghes_internal_ip_address.address)
}

output "ghes_internal_ip" {
  value = google_compute_address.ghes_internal_ip_address.address
}

output "ghes_external_ip" {
  value = var.enable_external_ip ? google_compute_address.ghes_external_ip_address[0].address : "n/a"
}
