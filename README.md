# Deploying GitHub Enterprise Server to Azure with Terraform

## What is this repository for?

On this repository, you can install GitHub Enterprise Server with Terraform. To maintain the terraform state, we use Azure Storage.

## Setting up

### Terraform backend

The terraform configuration uses backend to store its state on Azure Storage.

```sh
$ cd azure-storage-blob-backend
$ terraform init
$ terraform apply
```

### Credentials for Azure
