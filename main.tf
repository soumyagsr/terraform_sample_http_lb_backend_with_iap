  GNU nano 2.7.4                                                                                                                                                                                                                         File: main.tf                                                                                                                                                                                                                                    
# References:
# https://cloud.google.com/compute/docs/load-balancing/http/content-based-example
# https://github.com/Cidan/terraform-provider-google/blob/master/examples/content-based-load-balancing/main.tf

provider "google" {
  region = "${var.region}"
  project = "${var.project_name}"
}

# Create a GCE instance that serves as the template for the managed instance group
# Created an instance with ephemeral IP
resource "google_compute_instance" "default" {
  name = "tf-test-instance"
  machine_type = "f1-micro"
  zone = "${var.region_zone}"
  tags = ["http-tag"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }
}

# Create a global address (single anycast IP)
# Use static IP address if you created one
resource "google_compute_global_address" "external-address" {
  name = "tf-external-address"
}

# Create a managed instance group similar to the default GCE instance defined above
resource "google_compute_instance_group" "default" {
  name = "tf-mig1"
  zone = "${var.region_zone}"

  instances = ["${google_compute_instance.default.self_link}"]

  named_port {
    name = "http"
    port = "80"
  }
}

# Create a health check
resource "google_compute_health_check" "health-check" {
  name = "tf-health-check"

  http_health_check {
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
    group = "${google_compute_instance_group.default.self_link}"
  }

  iap   = {
      oauth2_client_id = "417969429103-b0ia0u26bssfse9ei5ciuku563kq75pc.apps.googleusercontent.com"
      oauth2_client_secret = "VD_JOw9KuCgKnf9a4fVEYYMe"
  }

  health_checks = ["${google_compute_health_check.health-check.self_link}"]
}

# Define the url map
# In this example, all requests go to default backend
# Please refer to the github repo referenced above for more detailed url map
resource "google_compute_url_map" "default" {
  name = "tf-web-map"
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
  name = "tf-www-firewall-allow-internal-only"
  network = "default"

  allow {
    protocol = "tcp"
    ports = ["80"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags = ["http-tag"]
}
