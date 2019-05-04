
variable "region" {
  default = "us-west1"
}
variable "region_zone" {
  default = "us-west1-a"
}
variable "project_name" {
  default = "sgtest-229423"
  description = "The ID of the Google Cloud project"
}
/*
This example uses the default account credentials but you can also explicitly associate a new service account created using the console: IAM & Admin -> Service Accounts
variable "credentials_file_path" {
  description = "Path to the JSON file used to describe your account credentials"
  default     = "~/.gcloud/Terraform.json"
}
*/
