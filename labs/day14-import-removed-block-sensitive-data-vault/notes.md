# Terraform Day 14 — Notes & Problems

## Notes

### 1. Terraform Import

Terraform Import is used to bring an **existing infrastructure resource** under Terraform management.

The resource already exists in AWS, but Terraform does not currently manage it.

```text
Existing AWS Resource
        ↓
     Import
        ↓
Terraform State
        ↓
Terraform Configuration
```

Example:

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

Import does not mean Terraform automatically understands the complete desired configuration.

You still need a proper Terraform resource configuration.

A useful way to think about it:

```text
Import
  ↓
Bring existing resource into State

Configuration
  ↓
Tell Terraform how the resource should be managed
```

---

### 2. Generate Configuration During Import

Terraform can generate resource configuration during planning:

```bash
terraform plan -generate-config-out=generated.tf
```

This is useful when importing existing infrastructure because Terraform can help generate the initial configuration.

Always review the generated configuration before using it as the final configuration.

---

### 3. Removed Blocks

A `removed` block tells Terraform to stop managing a resource without destroying the real infrastructure.

Example:

```hcl
removed {
  from = aws_instance.example

  lifecycle {
    destroy = false
  }
}
```

Result:

```text
Terraform State
      ↓
Resource removed from management
      ↓
AWS Resource remains
```

### Important Difference

`terraform destroy`:

```text
Terraform Resource
       ↓
Destroy
       ↓
AWS Resource deleted
```

`removed` with `destroy = false`:

```text
Terraform Resource
       ↓
Remove from Terraform management
       ↓
AWS Resource remains
```

---

### 4. Multiple Provider Configuration

Terraform can configure the same provider multiple times using aliases.

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

A resource can explicitly use the aliased provider:

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
   ├── aws       → us-east-1
   │
   └── aws.west  → us-west-1
```

This is useful for:

```text
Multiple AWS Regions
Multiple AWS Accounts
Cross-Region Infrastructure
```

---

### 5. Sensitive Parameters

Terraform allows variables and outputs to be marked as sensitive.

Example:

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

Output:

```hcl
output "db_password" {
  value     = var.db_password
  sensitive = true
}
```

The purpose is to prevent sensitive values from being displayed normally in Terraform CLI output.

### Important

`sensitive = true` does **not** mean the value is automatically encrypted or removed from Terraform State.

Think of it as:

```text
sensitive = true
        ↓
Hide from normal CLI output
```

Not:

```text
sensitive = true
        ↓
Completely secure / never stored
```

Terraform State still needs proper protection.

---

### 6. HashiCorp Vault

HashiCorp Vault is a dedicated system for managing secrets.

Examples:

```text
Passwords
API Keys
Tokens
Credentials
Certificates
```

Basic architecture:

```text
Terraform
    ↓
Vault
    ↓
Secret
```

Instead of hardcoding:

```hcl
password = "MySecret123"
```

Terraform can retrieve secrets from Vault.

---

### 7. Terraform + Vault Integration

Terraform can communicate with Vault through the Vault provider.

Example:

```hcl
provider "vault" {
  address = "https://vault.example.com"
}
```

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

The main benefit is centralizing secret management instead of hardcoding secrets inside Terraform configuration.

### Important

Using Vault does not automatically mean a secret can never appear in Terraform State.

If Terraform reads a secret and uses it in a resource attribute that is persisted in State, the value may still exist in State.

Therefore:

```text
Vault
  +
Secure Terraform State
```

are complementary controls.

---

### 8. Dependency Lock File

Terraform uses:

```text
.terraform.lock.hcl
```

to record selected provider versions and checksums.

Example:

```text
Terraform Configuration
        ↓
Required Provider
        ↓
Selected Version
        ↓
.terraform.lock.hcl
```

The lock file helps different machines use consistent provider versions.

### Important

Normally:

```text
.terraform.lock.hcl
→ Commit to Git
```

While:

```text
terraform.tfstate
→ Do NOT commit to Git
```

---

### 9. Ephemeral Values

Ephemeral values are intended for temporary values that should not be persisted in Terraform State or plan files.

Concept:

```text
Normal Value
    ↓
May be persisted

Ephemeral Value
    ↓
Temporary
    ↓
Not persisted in State / Plan
```

This is particularly useful for sensitive information that Terraform only needs temporarily.

The main goal is:

```text
Sensitive Data
      ↓
Use Temporarily
      ↓
Avoid Unnecessary Persistence
```

---

### 10. Write-Only Arguments

Write-only arguments allow Terraform to send a sensitive value to a resource without reading that value back.

Concept:

```text
Terraform
    ↓
Sensitive Value
    ↓
Resource
    ↓
Write Value
    ↓
Value is not read back
```

This is useful for values such as:

```text
Passwords
Credentials
Sensitive Tokens
```

The purpose is to reduce unnecessary exposure of sensitive values.

---

# Problems & Common Issues

## Problem 1 — Import Does Not Create Complete Configuration

### Problem

A resource was imported successfully, but the Terraform configuration does not contain all required arguments.

### Why?

Import primarily brings the existing resource into Terraform State.

It does not automatically mean the final desired configuration is complete.

### Solution

Generate or write the configuration and then compare it with the actual resource:

```bash
terraform plan
```

For configuration generation:

```bash
terraform plan -generate-config-out=generated.tf
```

Then review the generated file.

---

## Problem 2 — Import ID Is Incorrect

### Problem

Terraform fails during import because the resource ID is invalid or does not identify the expected resource.

### Example

```hcl
import {
  to = aws_security_group.app_sg
  id = "wrong-id"
}
```

### Solution

Use the actual cloud resource ID.

For AWS Security Groups, for example:

```text
sg-0123456789abcdef0
```

Always verify the resource ID in AWS before importing.

---

## Problem 3 — Removed Block Accidentally Destroys the Resource

### Problem

The intention is to stop Terraform managing a resource while keeping the real infrastructure.

### Correct configuration:

```hcl
removed {
  from = aws_instance.example

  lifecycle {
    destroy = false
  }
}
```

### Important

Do not confuse:

```text
destroy = false
```

with destroying the resource.

The goal is:

```text
Remove from Terraform management
+
Keep real infrastructure
```

---

## Problem 4 — Multiple Provider Configuration Error

### Problem

Terraform reports a duplicate provider configuration or an incorrect provider alias configuration.

### Common mistake:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  region = "us-west-1"
}
```

Both are default configurations.

### Correct approach:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-1"
}
```

Then:

```hcl
provider = aws.west
```

for resources that should use the second configuration.

---

## Problem 5 — Sensitive Value Still Appears in State

### Problem

A variable is marked:

```hcl
sensitive = true
```

but the value still exists in Terraform State.

### Why?

`sensitive` mainly controls how Terraform displays the value.

It does not automatically remove the value from State.

### Solution

Protect Terraform State using:

```text
Remote Backend
Encryption
IAM
Least Privilege
Access Control
State Security
```

Use ephemeral values or write-only arguments when the resource/provider supports them and the value does not need to be persisted.

---

## Problem 6 — Secret Hardcoded in Terraform

### Bad:

```hcl
password = "MySecretPassword"
```

### Why is this a problem?

The secret can become exposed through:

```text
Git
Terraform Configuration
Terraform State
Logs
Code Reviews
```

### Better approach

Use a dedicated secret-management solution such as Vault and minimize persistence of the secret.

---

## Problem 7 — `.terraform.lock.hcl` Deleted

### Problem

The dependency lock file is deleted or not committed, causing different environments to potentially select different provider versions.

### Solution

Keep:

```text
.terraform.lock.hcl
```

in the Git repository.

Run:

```bash
terraform init
```

when initializing the project.

### Remember

```text
.terraform.lock.hcl
→ Commit

.terraform/
→ Do not commit

terraform.tfstate
→ Do not commit
```

---

## Problem 8 — Confusing Vault With Terraform State Security

### Problem

Assuming that using Vault means Terraform State no longer needs protection.

### Reality

Vault protects and manages secrets, but Terraform State can still contain sensitive values depending on how those values are used.

Correct architecture:

```text
Vault
  ↓
Secret Management

Remote Backend
  ↓
Terraform State Protection
```

Both solve different problems.

---

## Problem 9 — Ephemeral Value Used Where Persistent Value Is Required

### Problem

An ephemeral value is used in a context where Terraform needs the value to persist or where the receiving resource does not support the required ephemeral behavior.

### Result

Terraform may reject the configuration because the value cannot be used in that context.

### Solution

Use ephemeral values only where supported and where the value genuinely does not need to be persisted.

---

## Problem 10 — Write-Only Argument Confused With Normal Argument

### Normal Argument

```text
Terraform
   ↓
Write Value
   ↓
Resource
   ↓
Read Value Back
```

### Write-Only Argument

```text
Terraform
   ↓
Write Value
   ↓
Resource
   ↓
Value not read back
```

Write-only arguments are specifically useful for sensitive values where reading the value back is unnecessary or undesirable.

---

# Important Comparisons

## Import vs Removed

```text
import
  ↓
Existing Resource
  ↓
Bring INTO Terraform Management


removed
  ↓
Terraform-managed Resource
  ↓
Take OUT of Terraform Management
  ↓
Infrastructure Can Remain
```

---

## Sensitive vs Ephemeral

```text
sensitive
  ↓
Hide value from normal CLI output


ephemeral
  ↓
Avoid persisting temporary value
```

They solve different problems.

---

## Vault vs Sensitive

```text
sensitive
  ↓
Terraform display protection


Vault
  ↓
Dedicated secret management
```

---

## State vs Lock File

```text
terraform.tfstate
  ↓
Infrastructure State
  ↓
Sensitive
  ↓
Do NOT commit


.terraform.lock.hcl
  ↓
Provider Versions + Checksums
  ↓
Normally commit
```

---

# Important Commands

```bash
# Import / Planning
terraform plan
terraform apply
terraform plan -generate-config-out=generated.tf

# Providers
terraform init
terraform providers

# Validation
terraform fmt
terraform validate
terraform plan

# Normal workflow
terraform apply
terraform destroy
```

---

# Best Practices

* Import existing infrastructure instead of recreating resources that already exist.
* Always review the configuration after importing a resource.
* Use `removed` with `destroy = false` when infrastructure must remain after Terraform stops managing it.
* Use provider aliases for multiple regions or accounts.
* Mark sensitive variables and outputs with `sensitive = true`.
* Never hardcode secrets in Terraform configuration.
* Use Vault or another dedicated secret-management system when appropriate.
* Protect Terraform State even when using Vault and sensitive values.
* Commit `.terraform.lock.hcl`.
* Do not commit `terraform.tfstate`.
* Use ephemeral values when sensitive temporary data does not need to be persisted.
* Use write-only arguments when supported for credentials and other sensitive values.
* Always run `terraform plan` before applying changes.

---

# Day 14 Quick Review

```text
Import
→ Existing infrastructure → Terraform management

Removed
→ Stop Terraform management → Keep infrastructure

Provider Alias
→ Multiple provider configurations

Sensitive
→ Hide sensitive values from normal CLI output

Vault
→ Centralized secret management

Lock File
→ Lock provider versions/checksums

Ephemeral
→ Temporary values without unnecessary persistence

Write-Only
→ Send sensitive value without reading it back
```

# Day 14 Scope

This file covers only the topics introduced in Day 14:

```text
Terraform Import
Terraform Import Practical
Removed Blocks
Multiple Provider Configuration
Sensitive Parameters
HashiCorp Vault
Terraform and Vault Integration
Dependency Lock File
Ephemeral Values
Write-Only Arguments
```
