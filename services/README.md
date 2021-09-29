
# IaC Services

## Resources

* enables the following gcp services for the project:
  * Cloud DNS
  * Cloud Domains
* service account
* service account key 

## Outputs

service account json key
```
terraform output -raw service_account_json | base64 -d -
```
