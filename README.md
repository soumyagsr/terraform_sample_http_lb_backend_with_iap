Terraform script to programmatically create IAP for a Compute Engine instance
Please use the following page for instructions on how to generate Oauth2 client id and client secret:
https://cloud.google.com/iap/docs/authentication-howto
Then copy over the client id and secret into the .tf 

The script automates provisoning of the following network components:
![Components of load balancer](https://cloud.google.com/load-balancing/images/basic-http-load-balancer.svg)
