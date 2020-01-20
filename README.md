# Deploying GitHub Enterprise Server to Azure with Terraform

## What is this repository for?

On this repository, you can install GitHub Enterprise Server with Terraform. To maintain the terraform state, we use Azure Storage.

## Set up

### Azure authentication

To authenticate Azure from terraform, see [here](https://www.terraform.io/docs/providers/azurerm/guides/azure_cli.html) and configure the authentication in Terraform.

### Terraform backend

The terraform configuration uses Azure backend to store its state. To initialize Azure backend, run the following commands:

```sh
$ cd azure-storage-blob-backend
$ terraform init
$ terraform apply
```

### Deploy GitHub Enterprise Server instance from local

Then run the following commands:

```sh
$ cd ghes
$ terraform init
$ terraform apply
```

### Deploy GitHub Enterprise Server instance with GitHub Actions

To deploy a new GitHub Enterprise Server instance with GitHub Actions, you need to fork this repository first.

Then you need to create a service principal to authenticate on Azure. To create a new service principal, see [here](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest).

Then specify the following secrets at your repository's Secrets setting page. You can get all of the following values on creating a service principal.

| Secret name         | description     |
| ------------------- | --------------- |
| ARM_CLIENT_ID       | Client ID       |
| ARM_CLIENT_SECRET   | Client secret   |
| ARM_SUBSCRIPTION_ID | Subscription ID |
| ARM_TENANT_ID       | Tenant ID       |

[The deploy job](https://github.com/yuichielectric/deploy-github-enterprise-server/blob/master/.github/workflows/deploy.yml) will be triggered on push to `master` branch.
