# Michael_Challenge

Here are instructions to run ensure the terraform and ansible run correctly. This terraform creates two external subnets, an internal subnet, network security rules restricted to the operator's IP, a load balancer, and a WAF. Without the certificate infrastructure I can't terminate an HTTPS listener on the load balancer so it won't redirect. However, the apache server it creates does redirect to HTTPS.

1. In the AWS console, create a key pair to use. Save the .pem for your public key to the repo directory.
2. In the AWS console, create an IAM user with the ability to edit security groups, create instances, load balancers, and wafs.
3. Create an Access Key for the IAM user you created. Make note of the access key ID and the access key secret in a secure way.
4. Create a file in the downloaded repo called 'secure.auto.tfvars'. It should contain the following.

```
 access_key         = Access key for an IAM user you created  
 secret_key         = Secret key for an IAM user you created  
 private_key        = NAME of the private key you created
 private_key_file   = The private key you created  you created
```
The CC number checker should be pretty self explanatory.
