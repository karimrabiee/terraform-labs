# Day 07 — Local Values, Data Sources & Mini Project 1

## Overview

Day 07 focuses on two important Terraform concepts:

* Local Values
* Data Sources

These concepts are used to make Terraform configurations more reusable, dynamic, and less dependent on hardcoded infrastructure information.

The practical goal of this day is to build a small AWS infrastructure project using:

* VPC
* Security Group
* EC2
* Variables
* Outputs
* AWS Data Source to dynamically retrieve an AMI

---

# 1. Local Values

## What are Local Values?

Local Values allow us to assign a reusable name to an expression or value inside a Terraform configuration.

They are useful when the same value or expression is used multiple times.

Local values are defined using a `locals` block.

### Basic Syntax

```hcl
locals {
  environment = "development"
  project     = "terraform-mini-project"
}
```

The value can then be referenced using:

```hcl
local.environment
```

or:

```hcl
local.project
```

---

## Example

```hcl
locals {
  environment = "development"
  project     = "terraform-mini-project"
}

resource "aws_instance" "app" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"

  tags = {
    Name        = "${local.project}-server"
    Environment = local.environment
  }
}
```

Terraform evaluates the local values and uses them wherever they are referenced.

---

## Why use Local Values?

Without locals:

```hcl
resource "aws_instance" "app" {
  tags = {
    Name        = "terraform-mini-project-server"
    Environment = "development"
  }
}
```

If the same values are required in multiple places, they may be repeated.

With locals:

```hcl
locals {
  project     = "terraform-mini-project"
  environment = "development"
}
```

We can reuse them:

```hcl
tags = {
  Name        = "${local.project}-server"
  Environment = local.environment
}
```

This improves readability and reduces repetition.

---

## Local Values vs Variables

A variable is normally used to provide input to a Terraform configuration.

A local value is normally used to calculate or reuse a value internally.

### Variable

```hcl
variable "environment" {
  type = string
}
```

The value can come from outside the configuration.

Example:

```hcl
environment = "production"
```

### Local

```hcl
locals {
  resource_name = "app-${var.environment}"
}
```

The local value is derived from existing configuration values.

### Simple Rule

```text
variable → input

local     → internal reusable value
```

---

# 2. Data Sources

## What is a Data Source?

A Data Source allows Terraform to retrieve information that already exists outside the resources managed by the current Terraform configuration.

A data source does NOT create the resource.

Instead, Terraform queries information and makes it available to the configuration.

---

## Resource vs Data Source

### Resource

A resource creates or manages infrastructure.

```hcl
resource "aws_instance" "app" {
  ...
}
```

Terraform is responsible for managing that EC2 instance.

### Data Source

A data source reads existing information.

```hcl
data "aws_ami" "latest" {
  ...
}
```

Terraform queries AWS and retrieves information about an AMI.

### Important Difference

```text
resource → create/manage infrastructure

data     → read/query existing information
```

---

# 3. Why Data Sources are Important

A common problem in Terraform is hardcoding infrastructure information.

For example:

```hcl
resource "aws_instance" "app" {
  ami           = "ami-0123456789abcdef"
  instance_type = "t3.micro"
}
```

This can become a problem because AMI IDs:

* differ between AWS regions
* can change over time
* may become outdated
* are difficult to maintain manually

The course demonstrates this problem using operating system images.

Instead of manually finding an AMI and hardcoding its ID, Terraform can query AWS and retrieve the required AMI dynamically.

---

# 4. Data Source Syntax

The general structure is:

```hcl
data "<PROVIDER>_<DATA_SOURCE>" "<NAME>" {
  # Query filters
}
```

Example:

```hcl
data "aws_ami" "latest" {
  ...
}
```

The data source is referenced using:

```hcl
data.aws_ami.latest
```

A specific attribute can be accessed using:

```hcl
data.aws_ami.latest.id
```

---

# 5. Fetching the Latest AMI

For the Mini Project, Terraform should dynamically find an AMI instead of using a hardcoded AMI ID.

Example:

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

The important parts are:

### `most_recent`

```hcl
most_recent = true
```

Requests the most recent matching AMI.

### `owners`

```hcl
owners = ["amazon"]
```

Restricts the search to AMIs owned by Amazon.

### `filter`

Filters control which AMIs Terraform considers.

Example:

```hcl
filter {
  name   = "state"
  values = ["available"]
}
```
Only available AMIs are considered.

filter based on ubuntu ami 

```hcl
filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*"]
  }
```
Only ubuntu AMIs are considered.

---

# 6. Using the Data Source in an EC2 Resource

After Terraform retrieves the AMI, the EC2 resource can use the returned ID.

```hcl
resource "aws_instance" "app" {
  ami           = data.aws_ami.ubuntu_linux.id
  instance_type = var.instance_type

  tags = {
    Name = "terraform-mini-project"
  }
}
```

The flow is:

```text
AWS
 │
 │ Query AMI
 ▼
Data Source
 │
 │ AMI ID
 ▼
EC2 Resource
 │
 ▼
EC2 Instance
```

This removes the need to manually hardcode the AMI ID.

---

# 7. Why AMI IDs Should Not Be Hardcoded

AMI IDs are region-specific.

For example:

```text
us-east-1 → ami-xxxx
us-east-2 → ami-yyyy
eu-west-1 → ami-zzzz
```

A hardcoded AMI may work in one region but fail when the configuration is deployed somewhere else.

Using a data source allows Terraform to query AWS for a matching AMI in the selected region.

This makes the configuration more portable.

---

# 8. Data Source Attributes

A data source can expose different attributes.

For example:

```hcl
data.aws_ami.ubuntu_linux.id
```

returns the AMI ID.

Other data sources expose different attributes depending on the provider documentation.

The correct approach is:

1. Identify the required data source.
2. Check its provider documentation.
3. Identify the required filters.
4. Identify the output attributes.
5. Reference those attributes in resources.

---

# 9. Mini Project 1

## Project Goal

Build a small AWS infrastructure using Terraform:

```text
AWS
│
└── VPC
    │
    └── Security Group
          │
          └── EC2
               │
               └── AMI retrieved dynamically
```

The project should demonstrate:

* VPC
* Security Group
* EC2
* Variables
* Outputs
* Local Values
* Data Source
* Dynamic AMI selection

---

# 10. Recommended Project Structure

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

Each file has a clear responsibility.

### `main.tf`

Main AWS resources.

### `variables.tf`

Input variables.

### `locals.tf`

Reusable internal values.

### `data.tf`

Data sources.

### `outputs.tf`

Useful values displayed after deployment.

### `terraform.tfvars`

Environment-specific variable values.

### `.gitignore`

Prevents Terraform state and local files from being committed.

---

# 11. Example — Variables

```hcl
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}
```

Example values:

```hcl
aws_region   = "us-east-1"
instance_type = "t3.micro"
```

---

# 12. Example — Provider

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

---

# 13. Example — Local Values

```hcl
locals {
  project_name = "terraform-mini-project"
  environment = "development"

  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}
```

The tags can then be reused:

```hcl
tags = local.common_tags
```

---

# 14. Example — Data Source

```hcl
data "aws_ami" "ubuntu_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
```

---

# 15. Example — VPC

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-vpc"
    }
  )
}
```

---

# 16. Example — Security Group

```hcl
resource "aws_security_group" "app" {
  name        = "${local.project_name}-sg"
  description = "Security group for the application instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}
```

> For a production environment, SSH should not normally be open to the entire internet. Restrict the source CIDR to a trusted network.

---

# 17. Example — EC2

```hcl
resource "aws_instance" "app" {
  ami           = data.aws_ami.ubuntu_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.app.id
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-ec2"
    }
  )
}
```

Notice that the AMI is not hardcoded:

```hcl
ami = data.aws_ami.ubuntu_linux.id
```

Terraform gets the AMI from the data source.

---

# 18. Example — Outputs

```hcl
output "vpc_id" {
  description = "ID of the project VPC"
  value       = aws_vpc.main.id
}

output "security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app.id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app.id
}

output "ami_id" {
  description = "AMI selected by the data source"
  value       = data.aws_ami.ubuntu_linux.id
}
```

This makes it easy to verify what Terraform selected and created.

---

# 19. Terraform Workflow

From the project directory:

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

After deployment, inspect the outputs:

```powershell
terraform output
```

When the practical work is complete:

```powershell
terraform destroy
```

---

# 20. What to Verify

After `terraform plan`, verify that:

* Terraform successfully finds an AMI.
* The selected AMI belongs to the expected owner.
* The AMI is available.
* The EC2 instance uses the data source AMI.
* The VPC is created.
* The Security Group is associated with the EC2 instance.
* The expected outputs are displayed.

---

# 21. Common Mistakes

## Mistake 1 — Hardcoding the AMI

Avoid:

```hcl
ami = "ami-123456789"
```

Prefer:

```hcl
ami = data.aws_ami.ubuntu_linux.id
```

---

## Mistake 2 — Incorrect Data Source Reference

Incorrect:

```hcl
ami = aws_ami.ubuntu_linux.id
```

Correct:

```hcl
ami = data.aws_ami.ubuntu_linux.id
```

Data sources use the `data.` prefix.

---

## Mistake 3 — Data Source Filters Are Too Broad

A data source that matches too many AMIs can return an unexpected result.

Use appropriate filters:

```hcl
filter {
  name   = "state"
  values = ["available"]
}
```

and:

```hcl
filter {
  name   = "name"
  values = ["al2023-ami-*-x86_64"]
}
```

---

## Mistake 4 — Wrong Region

An AMI available in one AWS region may not exist in another.

Make sure the configured provider region is the region where you expect the AMI to exist.

---

# 22. Data Source vs Hardcoded Value

### Hardcoded

```text
Terraform
   │
   └── Hardcoded AMI ID
           │
           ▼
         EC2
```

Problem:

```text
Region-specific
Outdated
Manual maintenance
Less reusable
```

### Data Source

```text
Terraform
   │
   ▼
Data Source
   │
   ├── Query AWS
   │
   └── Find matching AMI
          │
          ▼
         EC2
```

Benefits:

```text
Dynamic
Reusable
Region-aware
Less manual maintenance
```

---

# 23. Key Concepts to Remember

### Local Values

```hcl
locals {
  name = "example"
}
```

Reference:

```hcl
local.name
```

---

### Data Source

```hcl
data "aws_ami" "latest" {
  ...
}
```

Reference:

```hcl
data.aws_ami.latest.id
```

---

### Resource

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

# 24. Interview Questions

## Q1: What is a Terraform Data Source?

A Data Source allows Terraform to read information from an external system or provider without managing the lifecycle of that object as a Terraform resource.

---

## Q2: What is the difference between a resource and a data source?

A resource creates or manages infrastructure.

A data source retrieves information about existing infrastructure or external data.

---

## Q3: Why use a Data Source for AMIs?

AMI IDs are region-specific and can change over time. A data source allows Terraform to dynamically query AWS and select a matching AMI.

---

## Q4: How do you reference a data source?

Using:

```hcl
data.<type>.<name>.<attribute>
```

Example:

```hcl
data.aws_ami.ubuntu_linux.id
```

---

## Q5: What are Local Values?

Local Values are named expressions or values that can be reused inside a Terraform module.

---

## Q6: What is the difference between a variable and a local value?

A variable represents input to the configuration.

A local value represents an internal reusable value or expression.

---

## Q7: Does a Data Source create an AWS resource?

No.

It reads information from AWS or another external system.

---

# 25. Day 07 Summary

Today introduced an important transition from static Terraform configurations to more dynamic configurations.

The main concepts are:

```text
Local Values
     ↓
Reusable internal values

Data Sources
     ↓
Retrieve external information

AMI Data Source
     ↓
Find suitable AMI dynamically

Mini Project
     ↓
VPC + Security Group + EC2
```

The key practical lesson is:

> Do not hardcode infrastructure information when Terraform can safely retrieve it dynamically.

---

# 26. Memory Check

Without opening your notes, explain:

1. What is a Local Value?
2. What is a Data Source?
3. Resource vs Data Source?
4. Why should AMI IDs generally not be hardcoded?
5. How do you reference a Data Source?
6. How does the EC2 resource receive the AMI ID?
7. Why are Data Source filters important?

If you can answer these and rebuild the Mini Project from scratch, the Day 07 objectives are complete.
