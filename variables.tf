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

variable "project_id" {
  type        = string
  description = "The GCP project to deploy GHES."
}

variable "network" {
  type        = string
  description = "The VPC network to create for GHES."
  default     = "ghes-network"
}

variable "subnet" {
  type        = string
  description = "The subnet to create for GHES"
  default     = "ghes-subnet"
}

variable "region" {
  type        = string
  description = "The region for GHES VM"
  default     = "us-central1"
}

variable "enable_external_ip" {
  type        = bool
  description = "Whether to create an external ip address for the GHES instance."
  default     = false
}

variable "bastion_members" {
  type        = list(string)
  description = "The list of members who have access to bastion host to access GHES."
}
