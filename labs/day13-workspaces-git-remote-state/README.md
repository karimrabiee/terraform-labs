# Terraform Day 13 — Workspaces, Git Collaboration & Remote State

## Overview

Day 13 focuses on **Terraform Workspaces, Git collaboration, Terraform State security, Backends, State Locking, S3 Backend, State Management, and Remote State Data Sources**.

The main goal is to understand how Terraform state is managed safely in **team environments and multi-project architectures**, instead of treating `terraform.tfstate` as a local project file.

---

## Topics Covered

### 1. Terraform Workspaces

Terraform Workspaces allow multiple state files to be managed from the same Terraform configuration.

Each workspace has its own Terraform state while using the same Terraform code.

Common commands:

```bash
terraform workspace list
terraform workspace show
terraform workspace new dev
terraform workspace new prod
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

### Important Concept

Workspaces separate **state**, not necessarily the infrastructure configuration.

For example:

```text
Same Terraform Code
       |
       +---- dev workspace  → dev state
       |
       +---- prod workspace → prod state
```

Workspaces can be useful for simple environment separation, but they should not automatically be considered a complete environment-management strategy.

---

## 2. Git for Team Collaboration

Git is used to collaborate on Terraform code between team members.

Typical workflow:

```text
Developer
   ↓
Terraform Code
   ↓
Git Repository
   ↓
Pull Request
   ↓
Code Review
   ↓
Merge
```

Terraform configuration files such as:

```text
*.tf
*.tfvars
```

can be version-controlled when they do not contain sensitive values.

However, Terraform state requires special attention.

---

## 3. Terraform State Security

Terraform state can contain sensitive infrastructure information and sometimes sensitive values.

Examples include:

```text
Resource IDs
IP addresses
Database information
Secrets
Passwords
Sensitive attributes
Provider information
```

Therefore:

```text
terraform.tfstate
terraform.tfstate.*
```

should generally **not be committed to Git**.

Never solve state sharing by simply pushing `terraform.tfstate` to a public or shared Git repository.

---

## 4. Terraform and `.gitignore`

Terraform projects should use `.gitignore` to prevent local Terraform-generated files from being committed.

Example:

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

# Variable files that may contain secrets
*.tfvars
*.tfvars.json
```

If a `.tfvars` file contains only non-sensitive example values, it can be handled differently, but secret-containing variable files should not be committed.

A safe repository should contain:

```text
Terraform Code
      +
.gitignore
      |
      ↓
Sensitive / Generated Files excluded
```

---

## 5. Terraform Backend

A Terraform backend determines **where Terraform stores its state**.

Without a remote backend, state is normally stored locally:

```text
terraform.tfstate
```

With a remote backend:

```text
Terraform
   ↓
Backend
   ↓
Remote State
```

The backend provides a centralized location for Terraform state and is important for team collaboration.

---

## 6. State Locking

State locking prevents multiple Terraform operations from modifying the same state simultaneously.

Without locking:

```text
Developer A ──┐
              ├──→ Same State
Developer B ──┘
```

This can cause conflicting state operations.

With locking:

```text
Developer A → Lock → Modify State → Unlock
Developer B → Wait
```

State locking is especially important when multiple engineers or automation pipelines work with the same infrastructure.

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

The important idea is:

```text
Local Terraform
      ↓
AWS S3
      ↓
Remote Terraform State
```

A remote S3 backend provides centralized state storage instead of keeping the state only on the developer's machine.

### Important

The S3 bucket should be properly secured using appropriate:

* IAM permissions
* Encryption
* Versioning
* Access controls
* Least privilege

---

## 8. Terraform State Management

Terraform provides commands for inspecting and managing state.

Useful commands:

```bash
terraform state list
terraform state show <resource>
terraform state pull
terraform state push <file>
terraform state mv <source> <destination>
terraform state rm <resource>
```

Examples:

```bash
terraform state list
```

Shows resources currently tracked by Terraform.

```bash
terraform state show aws_instance.example
```

Displays detailed information about a resource in the state.

```bash
terraform state rm aws_instance.example
```

Removes the resource from Terraform state without necessarily destroying the real infrastructure.

### Important

State commands must be used carefully because incorrect state manipulation can cause Terraform to lose track of infrastructure.

---

## 9. Remote State Data Source

The `terraform_remote_state` data source allows one Terraform project to read outputs from another Terraform project's state.

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

Then another project can consume an output:

```hcl
vpc_id = data.terraform_remote_state.network.outputs.vpc_id
```

---

## 10. Cross-Project Collaboration

Remote state is useful when infrastructure is separated into multiple Terraform projects.

Example:

```text
Network Project
      |
      | VPC ID
      ↓
Application Project
      |
      | Subnet ID
      ↓
EC2 / Application Resources
```

The Network project manages:

```text
VPC
Subnets
Route Tables
Internet Gateway
NAT Gateway
```

The Application project can consume selected outputs from the Network project.

Example:

```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}
```

Another project:

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

Then:

```hcl
data.terraform_remote_state.network.outputs.vpc_id
```

---

## Terraform State Architecture

A typical team architecture can look like:

```text
                 Git Repository
                       |
                       ↓
                Terraform Code
                       |
                       ↓
                 Terraform CLI
                       |
                       ↓
                Remote Backend
                       |
                       ↓
                  S3 State
                       |
                State Locking
                       |
                       ↓
             Shared Team State
```

For multiple projects:

```text
              Network Project
                    |
                    ↓
              Network State
                    |
             Remote State
                    |
                    ↓
            Application Project
                    |
                    ↓
             Application State
```

---

## Important Commands

```bash
# Workspace
terraform workspace list
terraform workspace show
terraform workspace new <name>
terraform workspace select <name>
terraform workspace delete <name>

# Initialization
terraform init

# State inspection
terraform state list
terraform state show <resource>
terraform state pull

# State management
terraform state mv <source> <destination>
terraform state rm <resource>

# Normal workflow
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

---

## Best Practices

* Never commit `terraform.tfstate` to Git.
* Never store Terraform secrets directly in source code.
* Use `.gitignore` for Terraform-generated files.
* Use a remote backend for shared environments.
* Enable state locking where supported.
* Protect the backend using least-privilege IAM.
* Encrypt remote Terraform state.
* Enable S3 versioning for state recovery.
* Keep Terraform projects logically separated when appropriate.
* Use `terraform_remote_state` when one Terraform project must consume outputs from another.
* Avoid unnecessary manual modification of Terraform state.
* Review Terraform plans before applying changes.
* Treat Terraform state as sensitive infrastructure data.

---

## Day 13 Video Progress

| #   | Topic                                                      | Status          |
| --- | ---------------------------------------------------------- | --------------- |
| 129 | Overview of Terraform Workspace                            | ✅ Completed     |
| 130 | Terraform Workspace Practical                              | ✅ Completed     |
| 131 | Git for Team Collaboration                                 | ✅ Completed     |
| 132 | Security Risks of Storing Terraform State File in Git      | ✅ Completed     |
| 133 | Terraform and `.gitignore`                                 | ✅ Completed     |
| 134 | Terraform Backend                                          | ✅ Completed     |
| 135 | State Locking                                              | ✅ Completed     |
| 136 | S3 Backend                                                 | ❌ Not Completed |
| 137 | Terraform State Management                                 | ✅ Completed     |
| 138 | Cross-Project Collaboration using Remote State Data Source | ✅ Completed     |
| 139 | Remote State Data Source Practical                         | ✅ Completed     |

---

## Key Takeaways

```text
Workspace
   ↓
Separate Terraform States

Git
   ↓
Version Control for Terraform Code

.gitignore
   ↓
Prevent State / Generated / Sensitive Files from Git

Backend
   ↓
Centralized Terraform State

State Locking
   ↓
Prevent Concurrent State Modifications

S3 Backend
   ↓
Remote Terraform State Storage

terraform state
   ↓
Inspect and Manage Terraform State

terraform_remote_state
   ↓
Share Outputs Between Terraform Projects
```

The most important concept from Day 13 is that **Terraform code and Terraform state are different things**.

Git should primarily manage the **Terraform configuration**, while a properly secured **remote backend** should manage shared Terraform state.
