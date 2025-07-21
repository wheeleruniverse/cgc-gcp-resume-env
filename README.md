# GCP Resume App - Infrastructure (IaC)

This repository contains the Infrastructure-as-Code (IaC) for the GCP Resume App, originally created for the [A Cloud Guru Community Challenge](https://www.pluralsight.com/resources/blog/cloud/cloudguruchallenge-your-resume-on-gcp).

This project uses Terraform to define, provision, and manage all the Google Cloud Platform resources required to run the [frontend](https://github.com/wheeleruniverse/cgc-gcp-resume-web) and [backend](https://github.com/wheeleruniverse/cgc-gcp-resume-app) applications.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Terraform Modules](#terraform-modules)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Configuration](#configuration)
  - [Deployment](#deployment)
- [Project Structure](#project-structure)
- [License](#license)

## Overview

The purpose of this repository is to provide a declarative, version-controlled definition of the cloud environment. By using Terraform, the entire infrastructure stack—from networking and storage to compute and security—can be deployed and managed repeatably and reliably.

The code is structured into two main modules, `core` and `services`, to create a logical separation between foundational resources and application-specific resources.

## Architecture

This Terraform code provisions the necessary infrastructure to support a fully serverless application on Google Cloud Platform. The key components created are:

* **Google Cloud Project Setup:** Enables required APIs and configures foundational settings.
* **IAM Service Accounts:** Creates dedicated service accounts with least-privilege permissions for different parts of the application.
* **Google Cloud Storage:** Provisions a bucket to host the static frontend assets (HTML, CSS, JS).
* **Google Cloud Run:** Deploys the containerized Flask backend API.
* **Google Firestore:** Sets up a NoSQL database in Datastore mode for the visitor counter.
* **External HTTPS Load Balancer:** Configures a global load balancer with an SSL certificate to route traffic to the frontend and backend services.
* **Cloud CDN:** Enables caching for the frontend assets to improve performance and reduce costs.
* **Cloud Build:** Creates triggers to automate the build and deployment pipelines for the frontend and backend applications.

![Core Architecture Diagram](https://github.com/wheeleruniverse/cgc-gcp-resume-env/raw/main/architecture/core/core.png)

## Terraform Modules

The infrastructure is organized into two distinct modules for better management and reusability.

* **`core` Module:** This module sets up the foundational infrastructure. It is responsible for creating the GCP project, enabling necessary APIs, and configuring service accounts and permissions. It should be applied first.
* **`services` Module:** This module builds upon the `core` infrastructure to deploy the application-specific resources. It defines the Cloud Run service, the Cloud Storage bucket for the frontend, and the Load Balancer that exposes the application to the internet.

## Getting Started

### Prerequisites

* [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli) (version 1.0 or newer).
* [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed and authenticated.
* A Google Cloud Project with billing enabled.
* Appropriate IAM permissions to create the resources defined in the `.tf` files.

### Configuration

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/wheeleruniverse/cgc-gcp-resume-env.git](https://github.com/wheeleruniverse/cgc-gcp-resume-env.git)
    cd cgc-gcp-resume-env
    ```
2.  **Create a `terraform.tfvars` file:**
    In both the `core` and `services` directories, you will need to provide values for the declared variables. Create a `terraform.tfvars` file in each directory or export the variables as environment variables.
    ```tf
    # Example for core/terraform.tfvars
    project_id = "your-gcp-project-id"
    region     = "us-central1"
    ```

### Deployment

The infrastructure should be deployed in two stages, starting with the `core` module.

1.  **Initialize and Deploy Core Infrastructure:**
    ```bash
    cd core
    terraform init
    terraform plan
    terraform apply
    ```
2.  **Initialize and Deploy Services:**
    Once the core infrastructure is successfully deployed, proceed with the `services` module.
    ```bash
    cd ../services
    terraform init
    terraform plan
    terraform apply
    ```

## Project Structure

```
.
├── architecture/             \# Contains Draw.io diagrams and PNG exports
├── core/                     \# Terraform module for foundational GCP resources
│   ├── providers.tf          \# Defines the GCP provider configuration
│   ├── resources.tf          \# Declares core resources (APIs, IAM, etc.)
│   └── variables.tf          \# Input variables for the core module
└── services/                 \# Terraform module for application services
├── outputs.tf            \# Outputs from the services module (e.g., URLs)
├── providers.tf          \# Provider configuration for this module
├── resources.tf          \# Declares service resources (Cloud Run, GCS, LB)
└── variables.tf          \# Input variables for the services module
```

## License

This project is licensed under the MIT License.
