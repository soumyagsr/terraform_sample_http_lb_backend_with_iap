Terraform script to programmatically create IAP for a Compute Engine instance
Please use the following page for instructions on how to generate Oauth2 client id and client secret:
https://cloud.google.com/iap/docs/authentication-howto
Then copy over the client id and secret into the .tf 

The script automates provisoning of the following network components:
![Components of load balancer](https://cloud.google.com/load-balancing/images/basic-http-load-balancer.svg)

If you want to use a managed instance group as the backend of the load balancer, use the main.tf script provided here. 
If you want to use an instance group with heterogeneous instances, please point the backend service to the instance group scripted in the 'additional.tf' file.

If you want to provision an autoscaler with the managed instance group, please refer to the autoscaler.tf for instructions. 
