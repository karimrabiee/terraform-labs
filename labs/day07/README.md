# Day 07 — Terraform Data Sources & AWS Mini Project 1

> A hands-on Terraform project demonstrating Local Values, Data Sources, dynamic AMI selection, variables, outputs, and basic AWS infrastructure provisioning.

## Project Overview

This project is the first complete Terraform mini project in the learning path.

The goal is to move from static infrastructure configuration toward a more dynamic and reusable Terraform configuration.

The project provisions:

* AWS VPC
* AWS Security Group
* Amazon EC2 instance
* Dynamic Ubuntu linux AMI selection using a Terraform Data Source

It also demonstrates:

* Input Variables
* Local Values
* Outputs
* Resource references
* Data Source references
* Basic Terraform project organization

---

## Architecture

```text
                    AWS
                     │
                     ▼
                  VPC
               10.0.0.0/16
                     │
                     ▼
              Security Group
                     │
                     ▼
                EC2 Instance
                     │
                     │
                     ▼
              Ubuntu Linux AMI
                     ▲
                     │
              Terraform Data Source
                     │
                     ▼
                AWS AMI Query
```

---

## Why This Project Uses a Data Source

A common Terraform mistake is to hardcode an AMI ID:

```hcl
ami = "ami-xxxxxxxx"
```

AMI IDs are region-specific and may change over time.

Instead, this project uses a Data Source to query AWS for a matching Ubuntu linux AMI:

```hcl
data "aws_ami" "ubuntu_linux" {
  most_recent = true

  owners = ["amazon"]

 filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
```

The EC2 instance then uses:

```hcl
ami = data.aws_ami.ubuntu_linux.id
```

This makes the configuration more dynamic and reduces hardcoded infrastructure information.

---

## Project Structure

```text
day07-data-sources/
│
├── main.tf
├── variables.tf
├── locals.tf
├── data.tf
├── outputs.tf
├── terraform.tfvars
├── .gitignore
└── README.md
```

### File Responsibilities

| File               | Purpose                                |
| ------------------ | -------------------------------------- |
| `main.tf`          | AWS resources                          |
| `variables.tf`     | Input variable declarations            |
| `locals.tf`        | Reusable internal values               |
| `data.tf`          | AWS Data Sources                       |
| `outputs.tf`       | Deployment outputs                     |
| `terraform.tfvars` | Variable values                        |
| `.gitignore`       | Ignore Terraform-generated/local files |
| `README.md`        | Project documentation                  |

---

## Core Terraform Concepts

### Local Values

Local Values provide reusable internal values:

```hcl
locals {
  project_name = "terraform-mini-project"
  environment  = "development"
}
```

Reference:

```hcl
local.project_name
```

---

### Data Sources

Data Sources retrieve information without creating the queried object:

```hcl
data "aws_ami" "ubuntu_linux" {
  ...
}
```

Reference:

```hcl
data.aws_ami.ubuntu_linux.id
```

---

### Resource

Resources create or manage infrastructure:

```hcl
resource "aws_instance" "app" {
  ...
}
```

Reference:

```hcl
aws_instance.app.id
```

---

## Example Flow

```text
terraform plan
      │
      ▼
Query AWS Data Source
      │
      ▼
Find matching Ubuntu linux AMI
      │
      ▼
Get AMI ID
      │
      ▼
Create EC2 using AMI ID
```

---

## Deployment

Initialize Terraform:

```powershell
terraform init
```

Validate the configuration:

```powershell
terraform validate
```

Review the execution plan:

```powershell
terraform plan
```

Apply the infrastructure:

```powershell
terraform apply
```

View outputs:

```powershell
terraform output
```

Destroy the infrastructure after completing the practical exercise:

```powershell
terraform destroy
```

---

## Expected Outputs

The project exposes useful infrastructure information such as:

```text
vpc_id
security_group_id
instance_id
ami_id
```

The AMI output is especially useful for confirming which AMI was selected by the Data Source.

---

## Security Considerations

The Security Group example contains an SSH rule for learning purposes.

For a real production environment, avoid:

```hcl
cidr_blocks = ["0.0.0.0/0"]
```

for SSH access.

SSH should normally be restricted to a trusted IP range, VPN, bastion host, or another controlled access mechanism.

This project intentionally keeps the infrastructure simple because its primary purpose is learning Terraform Data Sources and completing the first mini project.

---

## Design Decisions

### Dynamic AMI Selection

**Decision:** Use an AWS Data Source instead of hardcoding an AMI ID.

**Reason:**

* AMIs are region-specific.
* AMIs can change over time.
* Manual AMI management increases maintenance.
* Dynamic lookup makes the configuration more reusable.

---

### Local Values

**Decision:** Use Local Values for common project information and tags.

**Reason:**

* Avoid repetition.
* Improve readability.
* Centralize reusable internal values.

---

### Variables

**Decision:** Keep configurable values outside the main resource definitions.

**Reason:**

* Reduce hardcoded configuration.
* Make the project easier to reuse.
* Allow different values for different environments.

---

### Outputs

**Decision:** Expose important infrastructure identifiers.

**Reason:**

* Easier verification after deployment.
* Useful for troubleshooting and later integration.
* Makes the Terraform execution results easier to understand.

---

## What I Learned

This project demonstrates the difference between static and dynamic Terraform configurations.

### Before

```hcl
resource "aws_instance" "app" {
  ami = "ami-xxxxxxxx"
}
```

### After

```hcl
data "aws_ami" "ubuntu_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "app" {
  ami = data.aws_ami.ubuntu_linux.id
}
```

The second approach allows Terraform to retrieve the required AMI information dynamically.

---

## Key Takeaways

* Local Values provide reusable internal values.
* Variables provide configuration inputs.
* Data Sources retrieve external information.
* Resources create or manage infrastructure.
* Data Sources are useful for avoiding hardcoded infrastructure information.
* AMI IDs are region-specific.
* Data Source filters should be specific enough to return the intended object.
* Data Source attributes can be referenced by resources.
* Outputs make important Terraform results visible after deployment.

---

## Day 07 Checklist

* [ ] Understand Local Values
* [ ] Understand Data Sources
* [ ] Understand Resource vs Data Source
* [ ] Create an AWS AMI Data Source
* [ ] Retrieve the latest matching Ubuntu linux AMI
* [ ] Use the AMI ID in an EC2 resource
* [ ] Create the VPC
* [ ] Create the Security Group
* [ ] Create the EC2 instance
* [ ] Use variables
* [ ] Use local values
* [ ] Create outputs
* [ ] Run `terraform init`
* [ ] Run `terraform validate`
* [ ] Run `terraform plan`
* [ ] Run `terraform apply`
* [ ] Verify outputs
* [ ] Run `terraform destroy`

---

## Learning Milestone

Day 07 represents the first major practical milestone in the Terraform learning path.

The objective is not simply to make the configuration work.

The objective is to understand **why** each component exists and be able to explain the flow:

```text
Variables
   │
   ▼
Terraform Configuration
   │
   ├──────────────► Local Values
   │
   ├──────────────► Data Source
   │                       │
   │                       ▼
   │                  AWS AMI
   │                       │
   ▼                       ▼
VPC ───────────────► Security Group ─────────► EC2
                                                │
                                                ▼
                                             Outputs
```

---

## Final Learning Check

Before considering Day 07 complete, rebuild the project without copying the code.

You should be able to explain:

1. Why the project uses a Data Source.
2. Why the AMI is not hardcoded.
3. How Terraform finds the AMI.
4. How the EC2 resource receives the AMI ID.
5. What Local Values are used for.
6. The difference between a variable and a local value.
7. The difference between a resource and a data source.
8. How to verify the selected AMI through Terraform outputs.

---

## Result

A complete Terraform mini project demonstrating:

```text
AWS VPC
+
Security Group
+
EC2
+
Variables
+
Local Values
+
Data Source
+
Dynamic AMI Selection
+
Outputs
```

This project establishes the foundation for more advanced Terraform patterns introduced later in the learning path.
