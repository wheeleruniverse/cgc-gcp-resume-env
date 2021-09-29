
# Services

## Resources

### IAM

* Role Mappings `build`
* Role Mappings `core`
* Service Account
* Service Account Key

### Enable GCP Services

* Cloud Build
* Cloud Compute
* Cloud DNS
* Cloud Domains
* Cloud Run
* Cloud Source Repositories
* Container Registry

## Outputs

service account json key
```
terraform output -raw service_account_json | base64 -d -
```
