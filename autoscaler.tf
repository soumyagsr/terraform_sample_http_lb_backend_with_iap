# Terraform support for google_compute_autoscaler is in Beta, so you will have to use google-beta 
# as provider as described below.
provider "google-beta" {
  credentials = "${file("account.json")}"
  project     = "my-project-id"
  region      = "us-central1"
}

# You can add the following resource definition to add an autoscaler associated with the managed instance group in main.tf
resource "google_compute_autoscaler" "autoscaler" {
  name   = "tf-autoscaler"
  target = "${google_compute_instance_group_manager.mig-mgr.self_link}"
  autoscaling_policy = {
    max_replicas    = 3
    min_replicas    = 1
    cooldown_period = 60
    cpu_utilization {
      target = 0.5
    }
  }
  zone = "${var.zone}"
}
