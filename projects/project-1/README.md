# Terraform Mini Project 1 — AWS Infrastructure with Data Sources

## Overview

This project is a hands-on Terraform implementation focused on building a small AWS infrastructure while applying the core concepts covered in Day 07.

The project demonstrates how Terraform can retrieve existing AWS information dynamically using a Data Source instead of relying on hardcoded infrastructure values.

The infrastructure includes:

* Amazon VPC
* Subnet
* Security Group
* HTTP ingress rule
* SSH ingress rule
* Egress rule
* Three EC2 instances
* AWS AMI Data Source
* Local Values
* Input Variables
* Resource Attribute References

---

## Project Objectives

The main objectives of this project are to:

1. Build a small AWS infrastructure using Terraform.
2. Retrieve an Ubuntu AMI dynamically using a Data Source.
3. Use Resource Attribute References between AWS resources.
4. Use Local Values for reusable tags.
5. Use Variables instead of hardcoding configurable values.
6. Deploy multiple EC2 instances using `count`.
7. Practice reading and understanding the Terraform execution plan.

---

## Architecture

```text
                         AWS
                          │
                          ▼
                    ┌──────────┐
                    │   VPC    │
                    │10.0.0.0/16│
                    └─────┬────┘
                          │
                          ▼
                    ┌──────────┐
                    │  Subnet  │
                    │10.0.1.0/24│
                    └─────┬────┘
                          │
             ┌────────────┴────────────┐
             │                         │
             ▼                         ▼
       Security Group            Ubuntu AMI
             │                  Data Source
        ┌────┴────┐                  │
        │         │                  │
      HTTP       SSH                 │
        │         │                  │
        └────┬────┘                  │
             │                       │
             └───────────┬───────────┘
                         ▼
                 ┌────────────────┐
                 │  EC2 Instances │
                 │    count = 3   │
                 ├────────────────┤
                 │     web[0]     │
                 │     web[1]     │
                 │     web[2]     │
                 └────────────────┘
```

---

## Terraform Concepts Demonstrated

### 1. Data Sources

The project retrieves the latest matching Ubuntu Linux AMI dynamically.

The EC2 instances reference the AMI using:

```hcl
ami = data.aws_ami.latest_ubuntu_linux.id
```

This avoids hardcoding an AMI ID directly inside the EC2 resource.

---

### 2. Local Values

Reusable tags are defined using a `locals` block.

Example:

```hcl
locals {
  default_tags = {
    Environment  = "development"
    CreationDate = formatdate("DD/MM/YYYY", timestamp())
  }
}
```

The EC2 instances then use:

```hcl
tags = local.default_tags
```

This keeps common configuration centralized and reusable.

---

### 3. Resource Attribute References

The project uses references between resources instead of manually copying IDs.

Example:

```hcl
vpc_id = aws_vpc.main.id
```

The Security Group references the VPC:

```hcl
vpc_id = aws_vpc.main.id
```

The Subnet references the VPC:

```hcl
vpc_id = aws_vpc.main.id
```

The EC2 instances reference the Subnet:

```hcl
subnet_id = aws_subnet.main.id
```

The Security Group rules reference the Security Group:

```hcl
security_group_id = aws_security_group.web_sg.id
```

---

### 4. Using the VPC CIDR Dynamically

The ingress rules use:

```hcl
cidr_ipv4 = aws_vpc.main.cidr_block
```

If the VPC CIDR is:

```text
10.0.0.0/16
```

Terraform automatically passes:

```text
10.0.0.0/16
```

to the Security Group rule.

This avoids duplicating the VPC CIDR manually.

---

### 5. Count

The project creates three EC2 instances using:

```hcl
count = 3
```

Terraform represents them as:

```text
aws_instance.web[0]
aws_instance.web[1]
aws_instance.web[2]
```

The same configuration is therefore used to create multiple instances.

---

## Infrastructure Configuration

### VPC

```text
CIDR: 10.0.0.0/16
```

### Subnet

```text
CIDR: 10.0.1.0/24
```

### AWS Region

```text
us-east-1
```

### EC2 Instance Type

```text
t2.micro
```

### EC2 Count

```text
3
```

### Security Group

The Security Group allows:

```text
HTTP → TCP/80
SSH  → TCP/22
```

The ingress rules use the VPC CIDR as their IPv4 source.

The egress rule allows outbound IPv4 traffic.

---

## Data Source Result

During `terraform plan`, Terraform successfully queried the AMI Data Source:

```text
data.aws_ami.latest_ubuntu_linux: Read complete
```

The selected AMI was:

```text
ami-02ebdb11bae1b2486
```

This confirms that Terraform successfully resolved the AMI before creating the EC2 instances.

---

## Terraform Workflow

### 1. Initialize Terraform

```powershell
terraform init
```

### 2. Format the configuration

```powershell
terraform fmt
```

### 3. Validate the configuration

```powershell
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

### 4. Review the execution plan

```powershell
terraform plan
```

### 5. Apply the infrastructure

```powershell
terraform apply
```

### 6. Destroy the infrastructure

After completing the practical exercise:

```powershell
terraform destroy
```

---

## Terraform Plan Result

The final successful plan reported:

```text
Plan: 9 to add, 0 to change, 0 to destroy.
```

The planned resources included:

```text
1 × VPC
1 × Subnet
1 × Security Group
2 × Ingress Rules
1 × Egress Rule
3 × EC2 Instances
```

Total:

```text
9 resources
```

The three EC2 instances were represented as:

```text
aws_instance.web[0]
aws_instance.web[1]
aws_instance.web[2]
```

The plan completed successfully with no changes or destruction scheduled.

---

## Security Considerations

This project is a learning lab and intentionally keeps the infrastructure simple.

The SSH rule should not be considered production-ready if it allows a broad network range.

For production environments, SSH access should be restricted to a trusted source such as:

* A specific administrative IP range
* VPN
* Bastion host
* Controlled management network

The project should therefore be treated as a Terraform learning exercise rather than production infrastructure.

---

## Design Decisions

### Dynamic AMI Selection

**Decision:** Use an AWS AMI Data Source.

**Reason:**

The project should not depend on manually entering an AMI ID into the EC2 resource.

Terraform queries AWS and retrieves a matching AMI dynamically.

---

### Resource References

**Decision:** Reference attributes from existing Terraform resources.

Example:

```hcl
aws_vpc.main.cidr_block
```

**Reason:**

This keeps the configuration connected and reduces duplicated values.

---

### Local Values

**Decision:** Store reusable tags in `locals`.

**Reason:**

Common values can be maintained in one location and reused by resources.

---

### Multiple EC2 Instances

**Decision:** Use `count = 3`.

**Reason:**

The project requires multiple instances while keeping the resource definition concise.

---

## What This Project Demonstrates

The project demonstrates the following Terraform flow:

```text
Input Variables
       │
       ▼
Terraform Configuration
       │
       ├──────────────► Local Values
       │
       ├──────────────► Data Source
       │                     │
       │                     ▼
       │                  Ubuntu AMI
       │
       ▼
      VPC
       │
       ▼
     Subnet
       │
       ▼
 Security Group
       │
       ├── HTTP
       ├── SSH
       └── Egress
       │
       ▼
  EC2 Instances
    ├── web[0]
    ├── web[1]
    └── web[2]
```

---

## Key Lessons

* A Data Source reads information instead of creating the queried object.
* Data Sources can reduce hardcoded infrastructure values.
* Resource attributes can be referenced directly by other resources.
* `aws_vpc.main.cidr_block` dynamically retrieves the VPC CIDR.
* Local Values can centralize reusable configuration.
* `count` creates multiple instances of the same resource.
* `terraform plan` should always be reviewed before applying infrastructure.
* A successful plan does not mean the infrastructure has already been created.

---

## Project Status

```text
Status: Completed
Terraform Plan: Successful
Resources Planned: 9
Changes: 0
Destructions: 0
```

This project represents the practical implementation of the Day 07 Terraform learning objectives.
