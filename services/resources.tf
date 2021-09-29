
resource "google_project_iam_member" "build" {
  count  = length(local.build_roles)
  member = "serviceAccount:${var.project_number}@cloudbuild.gserviceaccount.com"
  role   = "roles/${local.build_roles[count.index]}"
}

resource "google_project_iam_member" "core" {
  count  = length(local.core_roles)
  member = "serviceAccount:${google_service_account.this.email}"
  role   = "roles/${local.core_roles[count.index]}"
}

resource "google_project_service" "this" {
  count                      = length(local.services)
  disable_dependent_services = true
  disable_on_destroy         = true
  service                    = "${local.services[count.index]}.googleapis.com"

  timeouts {
    create = local.timeout
    update = local.timeout
  }
}

resource "google_service_account" "this" {
  account_id   = "${var.domain}-svc"
  description  = "service account for ${var.domain}"
  display_name = "${var.domain}-svc"
}

resource "google_service_account_key" "this" {
  service_account_id = google_service_account.this.name
}
