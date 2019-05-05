variable "region" {
  default = "us-west1"
}
variable "zone" {
  default = "us-west1-a"
}
variable "project_name" {
  default = "XXXX"
  description = "The ID of the Google Cloud project"
}
# Associate the service account created using the console: IAM & Admin -> Service Accounts
variable "credentials_file_path" {
  description = "Path to the JSON file used to describe your account credentials"
  default     = "~/tfkey.json"     # Put the .json key file in your home directory or specify the path if you created subdirs
}
