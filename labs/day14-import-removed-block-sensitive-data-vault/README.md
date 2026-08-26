# Terraform Day 14 — Import, Removed Blocks, Multiple Providers, Sensitive Data & Vault
import-removed-block-sensitive-data-vault
## Overview

Day 14 focuses on managing existing infrastructure with Terraform, safely removing resources from Terraform management, configuring multiple providers, handling sensitive values, integrating HashiCorp Vault, understanding the Terraform dependency lock file, and using ephemeral values and write-only arguments.

The main goal is to understand how Terraform handles **existing infrastructure, provider configurations, secrets, and provider dependencies**.

---

## Topics Covered

### 1. Terraform Import

Terraform Import allows an existing resource created outside Terraform to be brought under Terraform management.

Typical situation:

```text
Existing AWS Resource
        ↓
Terraform Import
        ↓
Terraform State
        ↓
Terraform Configuration
```

Example:

```hcl
resource "aws_security_group" "app_sg" {
  name = "app-sg"
}
```

Import block:

```hcl
import {
  to = aws_security_group.app_sg
  id = "sg-0123456789abcdef0"
}
```

Then:

```bash
terraform plan
terraform apply
```

### Important

Importing a resource does **not** automatically mean Terraform has a complete configuration for it.

The goal is:

```text
Existing Resource
      +
Terraform Configuration
      +
Terraform State
      ↓
Terraform manages the resource
```

Terraform can also generate configuration during import:

```bash
terraform plan -generate-config-out=generated.tf
```

---

## 2. Removed Blocks

A `removed` block tells Terraform to remove a resource from Terraform management **without destroying the real infrastructure**.

Example:

```hcl
removed {
  from = aws_instance.example

  lifecycle {
    destroy = false
  }
}
```

Conceptually:

```text
Terraform State
      ↓
Resource removed from management
      ↓
Real Infrastructure remains
```

### Important Difference

`terraform destroy`:

```text
Terraform Resource
      ↓
Removed from State
      ↓
Infrastructure Destroyed
```

`removed` block with `destroy = false`:

```text
Terraform Resource
      ↓
Removed from State
      ↓
Infrastructure Remains
```

Use this when Terraform should stop managing a resource while the actual infrastructure should continue to exist.

---

## 3. Multiple Provider Configuration

Terraform can configure the same provider multiple times using provider aliases.

Example:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-1"
}
```

A resource can use a specific provider configuration:

```hcl
resource "aws_instance" "west" {
  provider = aws.west

  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"
}
```

Architecture:

```text
Terraform
   │
   ├── aws → us-east-1
   │
   └── aws.west → us-west-1
```

This is useful when infrastructure must be deployed across multiple AWS regions or accounts.

---

## 4. Sensitive Parameters

Terraform supports marking values as sensitive.

Example:

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

Output can also be marked sensitive:

```hcl
output "db_password" {
  value     = var.db_password
  sensitive = true
}
```

This prevents Terraform CLI output from displaying the value normally.

### Important

`sensitive = true` is primarily about **preventing accidental display**.

It does not automatically mean the value is encrypted everywhere.

For example:

```text
Sensitive Variable
        ↓
Hidden from normal CLI output
```

The value can still exist in Terraform State depending on how it is used.

Therefore, Terraform State must still be protected.

---

## 5. HashiCorp Vault

HashiCorp Vault is a system designed for securely storing and managing secrets.

Examples of secrets:

```text
Passwords
API Keys
Tokens
Certificates
Credentials
```

Basic concept:

```text
Application / Terraform
        ↓
      Vault
        ↓
      Secret
```

Instead of placing secrets directly inside Terraform configuration:

```hcl
password = "my-secret-password"
```

Terraform can retrieve secrets from Vault.

---

## 6. Terraform and Vault Integration

Terraform can use the Vault provider to interact with Vault.

Example provider:

```hcl
provider "vault" {
  address = "https://vault.example.com"
}
```

Terraform can then retrieve secret information from Vault using Vault data sources.

Conceptually:

```text
Terraform
    ↓
Vault Provider
    ↓
HashiCorp Vault
    ↓
Secret
```

### Main Benefit

Secrets can be centralized in a dedicated secret-management system instead of hardcoding them in Terraform configuration.

However, care is still required because values retrieved by Terraform may potentially become part of Terraform State depending on how they are used.

---

## 7. Dependency Lock File

Terraform uses the dependency lock file:

```text
.terraform.lock.hcl
```

It records the selected provider versions and checksums.

Example concept:

```text
Terraform Configuration
        ↓
Required Provider
        ↓
Selected Version
        ↓
.terraform.lock.hcl
```

The lock file helps Terraform consistently use the same provider versions across machines and environments.

### Best Practice

The `.terraform.lock.hcl` file should normally be committed to Git.

Unlike Terraform State:

```text
terraform.tfstate
→ Do NOT commit

.terraform.lock.hcl
→ Normally COMMIT
```

---

## 8. Ephemeral Values

Ephemeral values are designed for temporary data that should not be persisted in Terraform State or plan files.

The concept is:

```text
Normal Value
    ↓
May be persisted

Ephemeral Value
    ↓
Temporary
    ↓
Not persisted in normal Terraform State
```

This is particularly useful when working with sensitive temporary information.

The goal is to reduce the amount of sensitive information that Terraform needs to persist.

---

## 9. Write-Only Arguments

Write-only arguments allow sensitive values to be sent to a resource without Terraform needing to read the value back.

Conceptually:

```text
Terraform
   ↓
Sensitive Value
   ↓
Resource
   ↓
Value written
   ↓
Value not read back
```

This is useful for credentials and other sensitive information that should not be exposed through normal resource reads.

### Important

Ephemeral values and write-only arguments address a common problem:

```text
Sensitive Data
       ↓
Avoid unnecessary persistence
       ↓
Reduce exposure
```

They complement, rather than replace, good secret-management practices.

---

## Important Differences

### Import vs Removed

| Feature   | Purpose                                                  |
| --------- | -------------------------------------------------------- |
| `import`  | Bring an existing resource under Terraform management    |
| `removed` | Stop Terraform managing a resource without destroying it |

### Sensitive vs Vault

| Feature            | Purpose                                                |
| ------------------ | ------------------------------------------------------ |
| `sensitive = true` | Hide sensitive values from normal Terraform CLI output |
| Vault              | Centralized secret management                          |

### State vs Lock File

| File                  | Purpose                           | Git               |
| --------------------- | --------------------------------- | ----------------- |
| `terraform.tfstate`   | Tracks infrastructure state       | ❌ Do not commit   |
| `.terraform.lock.hcl` | Locks provider versions/checksums | ✅ Normally commit |

---

## Common Configuration Examples

### Import

```hcl
import {
  to = aws_security_group.app_sg
  id = "sg-0123456789abcdef0"
}
```

### Removed

```hcl
removed {
  from = aws_instance.example

  lifecycle {
    destroy = false
  }
}
```

### Multiple Providers

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-1"
}
```

### Sensitive Variable

```hcl
variable "password" {
  type      = string
  sensitive = true
}
```

### Vault Provider

```hcl
provider "vault" {
  address = "https://vault.example.com"
}
```

---

## Important Commands

```bash
# Import / planning
terraform plan
terraform apply
terraform plan -generate-config-out=generated.tf

# Provider dependencies
terraform init
terraform providers
terraform lock

# Normal validation
terraform fmt
terraform validate
terraform plan
```

---

## Best Practices

* Use Terraform Import when bringing existing infrastructure under Terraform management.
* Review the generated or manually written configuration after import.
* Do not assume import automatically creates perfect production-ready configuration.
* Use `removed` when Terraform should stop managing infrastructure without destroying it.
* Use provider aliases for multi-region or multi-account deployments.
* Mark sensitive variables and outputs with `sensitive = true`.
* Never hardcode passwords, API keys, or other secrets in Terraform code.
* Use a dedicated secret-management solution such as Vault when appropriate.
* Protect Terraform State even when values are marked sensitive.
* Commit `.terraform.lock.hcl` to version control.
* Do not commit Terraform State to Git.
* Use ephemeral values when sensitive temporary data does not need to be persisted.
* Use write-only arguments when a provider/resource supports them for sensitive values.
* Minimize the amount of sensitive information persisted in Terraform State.

---

## Day 14 Video Progress

| #   | Topic                                     | Status                   |
| --- | ----------------------------------------- | ------------------------ |
| 140 | Overview of Terraform Import              | ✅ Completed              |
| 141 | Terraform Import Practical                | ✅ Completed              |
| 142 | Removed Blocks                            | ✅ Completed              |
| 143 | Multiple Provider Configuration           | ✅ Completed              |
| 144 | Sensitive Parameter                       | ✅ Completed              |
| 145 | Note — HashiCorp Vault                    | ✅ Completed              |
| 146 | Overview of HashiCorp Vault               | ✅ Completed              |
| 147 | Terraform and Vault Integration           | ✅ Completed              |
| 148 | Dependency Lock File                      | ✅ Completed              |
| 149 | Ephemeral Values and Write-Only Arguments | ⏳ Progress not specified |

---

## Key Takeaways

```text
Import
  ↓
Bring Existing Infrastructure into Terraform

Removed
  ↓
Stop Managing a Resource Without Destroying It

Provider Alias
  ↓
Use Multiple Provider Configurations

Sensitive
  ↓
Hide Sensitive Values from Normal CLI Output

Vault
  ↓
Centralized Secret Management

.terraform.lock.hcl
  ↓
Lock Provider Versions and Checksums

Ephemeral Values
  ↓
Temporary Values That Should Not Be Persisted

Write-Only Arguments
  ↓
Send Sensitive Values Without Reading Them Back
```

## Day 14 Scope

This day covers only:

```text
Terraform Import
Import Practical
Removed Blocks
Multiple Provider Configuration
Sensitive Parameters
HashiCorp Vault
Terraform + Vault Integration
Dependency Lock File
Ephemeral Values
Write-Only Arguments
```
