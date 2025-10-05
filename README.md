# AWS Multi-Tier Serverless Web App (Terraform + Lambda + API Gateway + S3)

Secure, scalable serverless file manager: upload, download, list, and delete files via **API Gateway → Lambda (Python) → S3**, provisioned with **Terraform**. Terraform state is stored in **S3** with **DynamoDB** locking.

**Tech:** Terraform · AWS Lambda · API Gateway · S3 · DynamoDB · IAM · GitHub Actions 
 
---

## Demo (screenshots)
> Add these files in `/assets` and they’ll appear automatically (instructions below).

<p align="center">
  <img src="assets/terraform-plan.png" width="48%" alt="Terraform plan"/>
  <img src="assets/lambda-test.png" width="48%" alt="Lambda test"/>
</p>
<p align="center">
  <img src="assets/s3-object.png" width="48%" alt="S3 object"/>
  <img src="assets/curl-output.png" width="48%" alt="API curl output (optional)"/>
</p>

---

## Architecture & Project Structure

### Architecture
```mermaid
flowchart TD
  U[User / curl / Browser] -->|HTTPS| AGW[Amazon API Gateway]
  AGW -->|Lambda Proxy| L1[Lambda: upload_file]
  AGW -->|Lambda Proxy| L2[Lambda: download_file]
  AGW -->|Lambda Proxy| L3[Lambda: list_files]
  AGW -->|Lambda Proxy| L4[Lambda: delete_file]

  L1 -->|Presigned PUT| S3[(S3 - Files Bucket)]
  L2 -->|Presigned GET| S3
  L3 --> S3
  L4 --> S3

  subgraph Terraform_State
    TFS3[(S3 - tfstate bucket)]
    TFDDB[(DynamoDB - state lock)]
  end

  U <--> AGW
```

### Project Structure
```
aws-mtier-terraform/
│
├── infra/
│   ├── main.tf                  # Main Terraform configuration
│   ├── variables.tf             # Input variables
│   ├── providers.tf             # AWS provider configuration
│   ├── backend.hcl              # Backend state config (S3 + DynamoDB)
│   ├── hello.txt                # Test file for Lambda upload/download
│   ├── .terraform.lock.hcl      # Provider version lock
│   └── modules/                 # Networking, compute, and data modules
│
├── .gitignore                   # Ignore .terraform, tfstate, zip files
├── README.md                    # Documentation (this file)
```

 
 
 
