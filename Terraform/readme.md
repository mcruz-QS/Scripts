## Notes on setting up Terraform & Azure

## Create a Service Principal
This is in 'Laso Development'
AZ Login
az account set --subscription="6a59dd77-24d9-43a3-86f5-64870e6d4881"
**Az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/3ed490ae-eaf5-4f04-9c86-448277f5286e"**
Az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/6a59dd77-24d9-43a3-86f5-64870e6d4881"
<<
PS C:\Users\m.cruz\Documents\git\Scripts> Az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/6a59dd77-24d9-43a3-86f5-64870e6d4881"
Retrying role assignment creation: 1/36
Retrying role assignment creation: 2/36
{
  "appId": "",
  "displayName": "azure-cli-2018-06-15-16-44-04",
  "name": "http://azure-cli-2018-06-15-16-44-04",
  "password": "",
  "tenant": ""
}
<<
Create files - You can use one file but easier to separate them out
variables.tf
  - Create you variables here
terraform.tfvars
  - Store Secrets and use .gitignore
providers.tf
  - define your connection to a provider (Resource)
main.tf
  - define what you are creating in Azure
in the dir terraform
terraform init
  - initializes the directory
terraform plan
  - creates an execution plan
terraform apply
  - Apply the configuration
terraform destroy
  - Destroy remove