#### Provisioning a globally load balanced, managed instance group behind an Identity Aware Proxy (IAP):

Please use [this](https://cloud.google.com/iap/docs/authentication-howto) page for instructions on how to generate Oauth2 credentials (client id and client secret) for the Identity Aware Proxy (IAP). Then copy over the client id and secret into main.tf when defining the backend service.

The script automates provisoning of the following network components:
![Components of load balancer](https://cloud.google.com/load-balancing/images/basic-http-load-balancer.svg)

If you want to use a managed instance group as the backend of the load balancer, use the main.tf script provided here. 
If you want to use an instance group with heterogeneous instances, please point the backend service to the instance group scripted in the 'additional.tf' file.

If you want to provision an autoscaler with the managed instance group, please refer to the autoscaler.tf for instructions. 

#### Google Cloud Platform Services and Concepts demonstrated:
[Cloud Identity-Aware Proxy](https://cloud.google.com/iap/)
[Google Cloud Load Balancing](https://cloud.google.com/load-balancing/)
[Managed instance group](https://cloud.google.com/compute/docs/instance-groups/creating-groups-of-managed-instances)
[Regional managed instance groups](https://cloud.google.com/compute/docs/instance-groups/distributing-instances-with-regional-instance-groups)

### CODE INTENDED FOR DEMO PURPOSES ONLY. 
