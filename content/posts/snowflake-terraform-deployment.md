---
title: "Deploy Snowflake Assets with Terraform and GitHub Actions"
date: 2025-09-17T05:44:22Z
author:
authorLink:
description: "Learn how to automate Snowflake infrastructure deployment using Terraform and GitHub Actions. Complete tutorial with code examples for Infrastructure as Code, CI/CD pipelines, and best practices for data warehouse automation."
tags:
- Snowflake
- Terraform
- GitHub Actions
- Infrastructure as Code
- Continuous Deployment
categories:
- Tutorial
draft: false
---

***
#### Want to learn how to use Terraform, GitHub Actions, and the Snowflake Provider to deploy assets directly to Snowflake? This walk-through shows you step by step how to set up automated Snowflake deployments using Infrastructure as Code principles.

***
[Access the GitHub repo here](https://github.com/lmcconnell1665/snow-terraform)

***
## Introduction

Using Terraform with the Snowflake Provider and GitHub Actions, you can automate the deployment of Snowflake databases, schemas, stages, and other assets directly from your source control repository. This tutorial demonstrates how to set up a complete Infrastructure as Code (IaC) pipeline for Snowflake deployments, ensuring your data warehouse infrastructure is versioned, repeatable, and consistent across environments.

***
## Step 1: Set up Terraform with the Snowflake Provider

First, create your Terraform configuration to define your Snowflake resources. The Snowflake Provider allows you to manage databases, schemas, stages, users, and more through declarative configuration.

Create a `main.tf` file with your provider configuration:

```hcl
provider "snowflake" {
  account  = var.snowflake_account
  username = var.snowflake_username
  password = var.snowflake_password
  role     = var.snowflake_role
  preview_features_enabled = ["snowflake_database_datasource"]
}

locals {
  create_shared_raw_db = var.deployment_env == "staging"
}
```

***
## Step 2: Define your Snowflake Resources

Define the databases, schemas, and stages you want to create. This example shows a typical data lakehouse architecture with bronze, silver, and gold layers:

```hcl
resource "snowflake_database" "raw_database" {
  count = local.create_shared_raw_db ? 1 : 0
  name  = upper("${var.database_id}_raw")
}

data "snowflake_database" "raw_database" {
  count = local.create_shared_raw_db ? 0 : 1
  name  = upper("${var.database_id}_raw")
}

resource "snowflake_database" "clean_database" {
  name = upper("${var.database_id}_${var.deployment_env}")
}

resource "snowflake_schema" "bronze_schema" {
  name     = "BRONZE"
  database = snowflake_database.clean_database.name
}

resource "snowflake_schema" "silver_schema" {
  name     = "SILVER"
  database = snowflake_database.clean_database.name
}

resource "snowflake_schema" "gold_schema" {
  name     = "GOLD"
  database = snowflake_database.clean_database.name
}

resource "snowflake_stage" "db_output_stage" {
  name     = "DB_OUTPUT"
  database = snowflake_database.clean_database.name
  schema   = snowflake_schema.gold_schema.name
  comment  = "Internal storage stage for output files"

  directory = "ENABLE = true"
}
```

This configuration creates:
- A conditional raw database (only in staging environments)
- A clean database with environment-specific naming
- Bronze, Silver, and Gold schemas following medallion architecture
- An internal stage for output files

***
## Step 3: Configure Variables and Backend

Create a `variables.tf` file to define your input variables:

```hcl
variable "snowflake_account" {
  description = "Snowflake account identifier"
  type        = string
}

variable "snowflake_username" {
  description = "Snowflake username"
  type        = string
}

variable "snowflake_password" {
  description = "Snowflake user password"
  type        = string
  sensitive   = true
}

variable "snowflake_role" {
  description = "Snowflake role to use for operations"
  type        = string
}

variable "database_id" {
  description = "Database identifier prefix"
  type        = string
}

variable "deployment_env" {
  description = "Deployment environment (staging/production)"
  type        = string
}
```

Set up your backend configuration for remote state management with state locking:

```hcl
terraform {
  backend "s3" {
    # Configuration will be provided via backend config files
    # DynamoDB table for state locking will be configured in backend config files
  }
}
```

**Important**: For state locking, you'll need to create a DynamoDB table in your AWS account. This table will be used to prevent concurrent modifications to your Terraform state.

Create the DynamoDB table using AWS CLI or the AWS Console:

```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

***
## Step 4: Create Backend Configuration Files

Create environment-specific backend configuration files:

`backend_configs/staging_example.conf`:
```
bucket         = "your-terraform-state-bucket"
key            = "snowflake/staging/example/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-state-lock"
encrypt        = true
```

`backend_configs/production_example.conf`:
```
bucket         = "your-terraform-state-bucket"
key            = "snowflake/production/example/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-state-lock"
encrypt        = true
```

***
## Step 5: Set up GitHub Actions Workflow

Create a `.github/workflows/snowflake-deployment.yml` file to automate your deployments:

```yaml
name: Snowflake Terraform Deployment

on:
  push:
    branches: [main, production]
  pull_request:
    branches: [main, production]

jobs:
  deploy:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment:
          - env_name: example
            account_id: AWS_ACCOUNT_ID_SECRET
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set environment variables
        run: |
          if [[ "${{ github.ref }}" == "refs/heads/production" ]]; then
            echo "TF_VAR_deployment_env=production" >> $GITHUB_ENV
            echo "BASE_BRANCH=production" >> $GITHUB_ENV
          else
            echo "TF_VAR_deployment_env=staging" >> $GITHUB_ENV
            echo "BASE_BRANCH=main" >> $GITHUB_ENV
          fi
          echo "TF_VAR_database_id=${{ matrix.environment.env_name }}" >> $GITHUB_ENV

      - name: Set Snowflake credentials
        run: |
          echo "TF_VAR_snowflake_account=${{ secrets.SNOWFLAKE_ACCOUNT }}" >> $GITHUB_ENV
          echo "TF_VAR_snowflake_username=${{ secrets.SNOWFLAKE_USERNAME }}" >> $GITHUB_ENV
          echo "TF_VAR_snowflake_password=${{ secrets.SNOWFLAKE_PASSWORD }}" >> $GITHUB_ENV
          echo "TF_VAR_snowflake_role=${{ secrets.SNOWFLAKE_ROLE }}" >> $GITHUB_ENV

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ secrets[matrix.environment.account_id] }}:role/terraform-deployment-role
          role-session-name: Terraform_Deployment
          aws-region: us-east-1
          role-duration-seconds: 3600

      - name: Terraform Init
        run: terraform init -backend-config=backend_configs/${{ env.TF_VAR_deployment_env }}_${{ matrix.environment.env_name }}.conf

      - name: Terraform Format
        run: terraform fmt -check

      - name: Terraform Plan
        run: |
          terraform plan -input=false

      - name: Terraform Apply
        if: ${{ github.event_name == 'push' && (env.BASE_BRANCH == 'main' || env.BASE_BRANCH == 'production') }}
        run: |
          terraform apply \
          -auto-approve \
          -input=false
```

***
## Step 6: Configure GitHub Secrets

In your GitHub repository settings, add the following secrets:
- `SNOWFLAKE_ACCOUNT`: Your Snowflake account identifier (e.g., `abc12345.us-east-1`)
- `SNOWFLAKE_USERNAME`: Username for your Snowflake service account
- `SNOWFLAKE_PASSWORD`: Password for your Snowflake service account
- `SNOWFLAKE_ROLE`: Role to use for Snowflake operations (e.g., `ACCOUNTADMIN` or `SYSADMIN`)
- `AWS_ACCOUNT_ID_SECRET`: AWS account ID for cross-account role assumption

***
## Step 7: Test Your Deployment Pipeline

1. **Create a Pull Request**: Make changes to your Terraform configuration and create a pull request. This will trigger a `terraform plan` to show you what changes will be made.

2. **Review the Plan**: Check the Terraform plan output in the GitHub Actions logs to ensure the changes are what you expect.

3. **Merge to Deploy**: When you merge your pull request to the main branch, the workflow will automatically run `terraform apply` and deploy your changes to Snowflake.

***
## Best Practices

- **Use Environment-Specific Configurations**: Separate your staging and production environments with different backend configurations and variable values.

- **Implement Proper State Management**: Store your Terraform state in a remote backend (like AWS S3) with state locking to prevent conflicts.

- **Secure Credential Management**: Use GitHub secrets and AWS IAM roles instead of hardcoding credentials.

- **Plan Before Apply**: Always run `terraform plan` in pull requests to review changes before deployment.

- **Use Descriptive Resource Names**: Include environment and purpose in resource names for better organization.

***
## Troubleshooting Common Issues

**Authentication Errors**: Ensure your Snowflake credentials are correctly set in GitHub secrets and that the service account has appropriate permissions.

**State Lock Issues**: If you encounter state lock errors, make sure you're using a backend that supports locking (like S3 with DynamoDB). Ensure your DynamoDB table exists and your AWS credentials have the necessary permissions to read/write to both the S3 bucket and DynamoDB table.

**Resource Conflicts**: Use Terraform's import functionality to manage existing Snowflake resources that weren't originally created with Terraform.

***
## Conclusion

By combining Terraform with GitHub Actions, you can create a robust, automated deployment pipeline for your Snowflake infrastructure. This approach provides version control for your data warehouse assets, ensures consistent deployments across environments, and enables collaborative development of your data platform.

The declarative nature of Terraform makes it easy to understand what resources exist in your Snowflake environment, while GitHub Actions provides the automation to keep everything in sync with your source code.