# Terraform Day 13 — Notes

## 1. Terraform Workspaces

Terraform Workspace allows the same Terraform configuration to use different state files.

```bash
terraform workspace list
terraform workspace show
terraform workspace new dev
terraform workspace select dev
terraform workspace delete dev
```

Example:

```bash
terraform workspace new dev
terraform workspace new prod

terraform workspace select dev
terraform workspace show
```

### Important

Workspace separates **Terraform State**, not the Terraform code itself.

```text
Same Terraform Code
        │
        ├── dev  → dev state
        │
        └── prod → prod state
```

Workspaces can be useful for simple environment separation, but they are not a replacement for proper project/environment architecture.

---

## 2. Git for Team Collaboration

Git is used to version-control Terraform configuration and allow multiple developers to work together.

Typical workflow:

```text
Terraform Code
      ↓
     Git
      ↓
 Pull Request
      ↓
 Code Review
      ↓
    Merge
```

Terraform code can be stored in Git, but Terraform State should not normally be committed to the repository.

---

## 3. Terraform State Security

Terraform State can contain sensitive infrastructure information and values.

Examples:

```text
Resource IDs
IP Addresses
Database Information
Sensitive Attributes
Passwords / Secrets
```

Therefore, `terraform.tfstate` must be treated as sensitive data.

Never commit:

```text
terraform.tfstate
terraform.tfstate.*
```

to Git.

---

## 4. .gitignore

Terraform projects should use `.gitignore` to prevent generated and sensitive files from being committed.

```gitignore
# Terraform state
*.tfstate
*.tfstate.*

# Terraform working directory
.terraform/

# Terraform crash logs
crash.log
crash.*.log

# Terraform plan files
*.tfplan
*.plan

# Variable files
*.tfvars
*.tfvars.json
```

The purpose is to keep the Git repository focused on Terraform source code rather than local state and generated files.

---

## 5. Terraform Backend

A Terraform Backend defines where Terraform stores its state.

### Local Backend

By default, Terraform can store state locally:

```text
terraform.tfstate
```

### Remote Backend

With a remote backend:

```text
Terraform
    ↓
Remote Backend
    ↓
Remote State
```

A remote backend is important when multiple people or automation systems need to work with the same Terraform state.

---

## 6. State Locking

State locking prevents multiple Terraform operations from modifying the same state at the same time.

Without locking:

```text
Developer A ──┐
              ├──→ Same State
Developer B ──┘
```

This can result in conflicting operations.

With locking:

```text
Developer A
     ↓
Acquire Lock
     ↓
Modify State
     ↓
Release Lock
     ↓
Developer B
```

State locking is important in team environments.

---

## 7. S3 Backend

Amazon S3 can be used as a remote backend for Terraform state.

Example:

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "project/terraform.tfstate"
    region = "us-east-1"
  }
}
```

Architecture:

```text
Terraform
    ↓
AWS S3
    ↓
Terraform State
```

The S3 bucket should be protected using appropriate security controls such as:

```text
Encryption
IAM
Least Privilege
Versioning
Access Control
```

---

## 8. Terraform State Management

Terraform provides commands for inspecting and managing state.

### List Resources

```bash
terraform state list
```

Shows resources currently tracked in Terraform State.

### Show Resource

```bash
terraform state show aws_instance.example
```

Displays detailed state information for a specific resource.

### Pull State

```bash
terraform state pull
```

Retrieves the current state.

### Move Resource

```bash
terraform state mv <source> <destination>
```

Changes the address of a resource inside Terraform State.

### Remove Resource

```bash
terraform state rm <resource>
```

Removes a resource from Terraform State without directly destroying the real infrastructure.

### Important

State manipulation commands should be used carefully because incorrect state changes can make Terraform lose track of existing infrastructure.

---

## 9. Remote State Data Source

`terraform_remote_state` allows one Terraform project to read outputs from another Terraform project's state.

Example:

```hcl
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "my-terraform-state"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}
```

If the Network project exposes:

```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}
```

Another Terraform project can consume it:

```hcl
data.terraform_remote_state.network.outputs.vpc_id
```

---

## 10. Cross-Project Collaboration

Terraform projects can be separated according to their responsibilities.

Example:

```text
Network Project
    │
    ├── VPC
    ├── Subnets
    ├── Route Tables
    └── Internet Gateway
             │
             ↓
      Remote State Output
             │
             ↓
Application Project
    │
    ├── EC2
    ├── Load Balancer
    └── Application Resources
```

The Application project does not need to recreate the Network resources. It can consume required outputs from the Network project's remote state.

---

## 11. Important Difference

### Git

Used primarily for:

```text
Terraform Configuration
Modules
Variables Definitions
Documentation
.gitignore
```

### Terraform State

Contains:

```text
Current Infrastructure State
Resource Information
Resource IDs
Tracked Attributes
```

### Backend

Provides:

```text
Remote State Storage
Team Access
State Management
State Locking
```

The main idea:

```text
Git
 ↓
Terraform Code

Backend
 ↓
Terraform State
```

---

## 12. Important Commands

```bash
# Workspaces
terraform workspace list
terraform workspace show
terraform workspace new dev
terraform workspace select dev
terraform workspace delete dev

# Backend / initialization
terraform init

# State inspection
terraform state list
terraform state show <resource>
terraform state pull

# State management
terraform state mv <source> <destination>
terraform state rm <resource>

# Standard workflow
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

---

## 13. Best Practices

* Do not commit `terraform.tfstate` to Git.
* Do not store secrets directly in Terraform code.
* Use `.gitignore` for Terraform-generated files.
* Use a remote backend for shared Terraform environments.
* Use state locking in team environments.
* Secure the remote state using IAM and least privilege.
* Encrypt remote Terraform State.
* Enable S3 versioning when using S3 for state storage.
* Avoid unnecessary manual state manipulation.
* Review Terraform plans before applying changes.
* Use `terraform_remote_state` when projects need outputs from another Terraform project.
* Keep Terraform projects logically separated when the architecture requires it.

---

## 14. Key Concepts

```text
Workspace
    ↓
Separate State per Workspace

Git
    ↓
Version Control for Terraform Code

.gitignore
    ↓
Prevent State and Generated Files from Git

Backend
    ↓
Where Terraform State Is Stored

State Locking
    ↓
Prevent Concurrent State Modification

S3 Backend
    ↓
Remote Terraform State Storage

terraform state
    ↓
Inspect / Modify Terraform State

terraform_remote_state
    ↓
Consume Outputs from Another Terraform Project
```

---

## Day 13 Scope

This day covers only:

```text
Terraform Workspaces
Git Collaboration
Terraform State Security
.gitignore
Terraform Backend
State Locking
S3 Backend
Terraform State Management
Remote State Data Source
Cross-Project Collaboration
```

