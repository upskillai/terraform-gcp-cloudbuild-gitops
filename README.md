# terraform-gcp-cloudbuild-gitops
Sample Code for Automating Deployments of Google Cloud Run Functions with Terraform and Cloud Build

## Overview

This repository uses Terraform to manage the CI/CD pipeline for Google Cloud Functions. The code within the `src` folder is automatically built and deployed to Google Cloud Functions whenever there is a push to the repository. This setup ensures that the latest code is always running in your cloud environment without manual intervention.

## Workflow

1. **Code Management:**  
   - Place your Cloud Function code in the `src` folder. Each function should be contained within its respective folder inside `src`.
   - Inside the folder, name the code file as `main.py`, and add `requirements.txt`.

2. **Automatic Build and Deployment:**  
   - Any push to the `prod` or `dev` branch triggers the CI/CD pipeline.
   - The pipeline will automatically rebuild and deploy the Google Cloud Functions with the latest code from the `src` folder.
   - Terraform is used to manage the infrastructure, ensuring that the cloud resources are correctly provisioned and configured before deployment.

3. **Terraform Configuration:**
   - The core infrastructure setup and configurations are managed via Terraform scripts located in the `cloudbuild.yaml` and `environments/[branchName]/main.tf` file. 
   - Note that no `_` is allowed in google cloud function names, use `-` instead.
   - Before initiating a build, ensure that all necessary function build details, such as memory allocation, timeout settings, and environment variables, are defined in the `main.tf` file.
   - It is crucial to correctly configure the Terraform scripts to match the requirements of your Cloud Functions, including resource naming, triggers, and permissions.

### Continuous Integration/Continuous Deployment (CI/CD)

- Every time you push changes to the repository, the CI/CD pipeline is triggered.
- The pipeline rebuilds and redeploys the Cloud Functions with the latest code from the `src` directory.
- Monitor the build and deployment process through the Google Cloud Console or your CI/CD tool to ensure successful deployment.

## Set Up

A few steps are needed to set up the connection between GCP, Terraform, and GitHub.

1. [Setting up GCP Project and GitHub repository](https://cloud.google.com/docs/terraform/resource-management/managing-infrastructure-as-code#prerequisites)
2. [Configuring Terraform to store state in a Cloud Storage bucket](https://cloud.google.com/docs/terraform/resource-management/managing-infrastructure-as-code#configuring_terraform_to_store_state_in_a_cloud_storage_bucket)
3. [Granting permissions to your Cloud Build service account](https://cloud.google.com/docs/terraform/resource-management/managing-infrastructure-as-code#granting_permissions_to_your_cloud_build_service_account)
4. [Directly connecting Cloud Build to your GitHub repository](https://cloud.google.com/docs/terraform/resource-management/managing-infrastructure-as-code#directly_connecting_cloud_build_to_your_github_repository)

## Common Errors

- 2nd Gen Google Cloud Run Functions can output misleading error messages. So after successful deployment in Cloud Build, if there is an error in the function console, try debugging by deploying the code locally. See: [StackOverflow Discussion](https://stackoverflow.com/a/75632728)

- If deploying locally shows no error, try changing the function name in `[branch_name]/main.tf`. This forces Cloud Build to reset deployment settings.

## See More At:

1. [Google: Managing infrastructure as code with Terraform, Cloud Build, and GitOps](https://cloud.google.com/docs/terraform/resource-management/managing-infrastructure-as-code) — Note the sample code repo is broken.
2. [Google: Cloud Functions, Terraform Tutorial](https://cloud.google.com/functions/docs/tutorials/terraform)
