resource "google_compute_instance" "default" {
  project      = "<project_id>"
  name         = "terraform-instance1"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  network_interface {
    network = "default"
    access_config {
    }
  }
}
resource "google_compute_backend_service" "default" {
  name  = "backend1"
  health_checks = ["${google_compute_http_health_check.default.self_link}"]
  iap   = {
       oauth2_client_id = "XXX"
       oauth2_client_secret = "XXX"
  }
}
resource "google_compute_http_health_check" "default" {
  name               = "health-check"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}
