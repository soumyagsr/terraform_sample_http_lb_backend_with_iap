rovider "google" {
  region = "${var.region}"
  project = "${var.project_name}"
  credentials = "${file("${var.credentials_file_path}")}"
}
# Create a static global address (single anycast IP)
resource "google_compute_global_address" "external-address" {
  name = "tf-external-address"
}
# Create a managed instance group template
resource "google_compute_instance_template" "mig-template" {
  name        = "tf-mig-template"
  description = "Template used to create the instances within the managed instance group."
  instance_description = "description assigned to instances"
  machine_type         = "n1-standard-1"
  can_ip_forward       = false
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
  // Create a new boot disk from an image
  disk {
    source_image = "debian-cloud/debian-9"
    auto_delete  = true
    boot         = true
  }
  network_interface {
    network = "default"
  }
  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
# Create a managed instance group using the template defined above
# This is zonal MIG, use google_compute_region_instance_group_manager is you want a regional MIG
resource "google_compute_instance_group_manager" "mig-mgr" {
  name = "tf-mig-mgr"
  base_instance_name = "tf-mig-instance"
  zone               = "${var.zone}"
  instance_template  = "${google_compute_instance_template.mig-template.self_link}"
  # target_pools = ["${google_compute_target_pool..self_link}"]
  target_size  = 3
  named_port {
    name = "custom-http"
    port = "80"
  }
}
output "instance_group_manager" {
  value = "${google_compute_instance_group_manager.mig-mgr.instance_group}"
}
output "health_check" {
  value = "${google_compute_health_check.health-check.self_link}"
}
resource "google_compute_health_check" "health-check" {
  name                = "tf-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10             # 50 seconds
  http_health_check {
    request_path = "/healthz"
    port         = "8080"
  }
}
/* Create a backend service pointing to the managed instance group defined above.
The backend service definition is where the IAP provisioning happens.
The OAuth2 client id and secret cannot be generated in Terrafom, you have to use the console.
In the console, go to API& Services -> Credentials to create the client id and client secret and copy it in the code below.
*/
resource "google_compute_backend_service" "default" {
  name = "tf-backend-svc"
  protocol = "HTTP"
  backend {
    group = "${google_compute_instance_group_manager.mig-mgr.instance_group}"
  }
  iap   = {
      oauth2_client_id = "XXXX.apps.googleusercontent.com"
      oauth2_client_secret = "XXXX"
  }
  health_checks = ["${google_compute_health_check.health-check.self_link}"]
}
# Define the url map - use the path matcher to point to different backend services
# Example of content based load balancing to different backends is contained in the repo listed in References
resource "google_compute_url_map" "default" {
  name = "tf-test-url-map"
  default_service = "${google_compute_backend_service.default.self_link}"
  host_rule {
    hosts = ["*"]
    path_matcher = "tf-allpaths"
  }
  path_matcher {
    name = "tf-allpaths"
    default_service = "${google_compute_backend_service.default.self_link}"
  }
}
# Define the HTTP(S) proxy where the forwarding rule forwards requests
resource "google_compute_target_http_proxy" "http-lb-proxy" {
  name = "tf-http-lb-proxy"
  url_map = "${google_compute_url_map.default.self_link}"
}
# Define the load balancer forwarding rule that sends traffic to the proxy defined above
resource "google_compute_global_forwarding_rule" "default" {
  name = "tf-http-content-gfr"
  target = "${google_compute_target_http_proxy.http-lb-proxy.self_link}"
  ip_address = "${google_compute_global_address.external-address.address}"
  port_range = "80"
}

# Define firewall rule to allow traffic from the load balancer
resource "google_compute_firewall" "default" {
  name = "tf-test-firewall-allow-internal-only"
  network = "default"
  allow {
    protocol = "tcp"    # No port number specified which means all ports are allowed
  }
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
}
