# Deploying GitHub Enterprise Server to Azure with Terraform

## What is this repository for?

On this repository, you can install GitHub Enterprise Server with Terraform. To maintain the terraform state, we use Azure Storage.

## Setting up

### Terraform backend

The terraform configuration uses Azur backend to store its state. To initialize Azure backend, run the following commands:

```sh
$ cd azure-storage-blob-backend
$ terraform init
$ terraform apply
```

### Deploy GitHub Enterprise Server instance from local

There are four ways to authenticate on Azure:

- [Using Azure CLI](https://www.terraform.io/docs/providers/azurerm/guides/azure_cli.html)
- [Using Managed Service Identity](https://www.terraform.io/docs/providers/azurerm/guides/managed_service_identity.html)
- [Using a Service Principal with a Client Certificate](https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_certificate.html)
- [Using a Service Principal with a Client Secret](https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html)

Configure the authentication using one of those four methods. Then run the following commands:

```sh
$ cd ghes
$ terraform init
$ terraform apply
```

### Deploy GitHub Enterprise Server instance with GitHub Actions

To deploy a new GitHub Enterprise Server instance with GitHub Actions, you need to create a service principal to authenticate on Azure. To create a new service principal, see [here](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest).

Then specify the secrets at [Secrets setting page](settings/secrets).

[The deploy job](blob/master/.github/workflows/deploy.yml) will be triggered on push to `master` branch.
