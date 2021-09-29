
locals {

  // https://cloud.google.com/build/docs/securing-builds/configure-access-for-cloud-build-service-account
  // order matters to avoid re-creation
  build_roles = [
    "iam.serviceAccountUser",
    "run.admin",
  ]

  // https://cloud.google.com/iam/docs/understanding-roles
  // order matters to avoid re-creation
  core_roles = [
    "compute.loadBalancerAdmin",
    "containerregistry.ServiceAgent",
    "iam.serviceAccountUser",
    "run.admin",
    "storage.admin",
    "storage.objectAdmin"
  ]

  // order matters to avoid re-creation
  services = [
    "domains",
    "dns",
    "compute",
    "containerregistry",
    "run",
    "sourcerepo",
    "cloudbuild"
  ]

  timeout = "60m"
}

variable "domain" {
  default     = "wheelersadvice"
  description = "domain name"
  type        = string
}

variable "location_region" {
  default     = "US-CENTRAL1"
  description = "a specific geographic place, such as São Paulo"
  type        = string

  validation {
    condition     = contains(["US-CENTRAL1", "US-EAST1", "US-EAST4", "US-WEST1", "US-WEST2", "US-WEST3", "US-WEST4"], var.location_region)
    error_message = "Variable location_region is invalid."
  }
}

variable "project" {
  default     = "cloudguruchallenge-2108"
  description = "project id"
  type        = string
}

variable "project_number" {
  default     = "98767786228"
  description = "project number"
  type        = string
}
