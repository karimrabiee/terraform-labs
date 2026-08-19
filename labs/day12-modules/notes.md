# Terraform Day 12 — Modules Notes

## Overview

Quick-reference notes and common problems for **Day 12 — Terraform Modules** only.

Covered:

- Module Basics
- Using Modules with EC2
- Choosing Modules
- Custom Module Structure
- Module Sources
- Local Module Paths
- Module Code Improvements
- Module Variables
- Hardcoded Values → Variables
- Provider Configuration in Modules
- Module Outputs
- Root vs Child Modules
- Standard Module Structure
- Multiple Provider Configurations
- Terraform Registry Publishing Requirements

---

# 1. Terraform Modules

A **module** is a reusable collection of Terraform configuration files.

Instead of keeping all resources in one large configuration, related resources can be packaged into a reusable module.

```text
Root Module
    |
    +── VPC Module
    |
    +── EC2 Module
    |
    +── Security Group Module
```

### Key Concept

Every Terraform configuration is technically a module.

```text
Root Module
    = Current working directory

Child Module
    = Module called by another module
```

---

# 2. Basic Module Structure

A simple custom module can contain:

```text
modules/
└── ec2/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

### Responsibilities

| File | Purpose |
|---|---|
| `main.tf` | Resources and main module logic |
| `variables.tf` | Module inputs |
| `outputs.tf` | Module outputs |

Additional files can be added when needed.

---

# 3. Calling a Module

A module is called using a `module` block.

```hcl
module "ec2" {
  source = "./modules/ec2"
}
```

Terraform then evaluates the configuration inside the child module.

```text
Root Module
    |
    | module "ec2"
    v
Child Module
    |
    +── aws_instance
    +── aws_security_group
    +── ...
```

---

# 4. Module Source

The `source` argument tells Terraform where the module comes from.

Example:

```hcl
module "ec2" {
  source = "./modules/ec2"
}
```

The source can represent different module locations such as:

```text
Local path
Registry
Git repository
Other supported module sources
```

---

# 5. Local Module Paths

For a module stored inside the same project:

```hcl
module "ec2" {
  source = "./modules/ec2"
}
```

### Relative Path

```text
./modules/ec2
```

means:

```text
Current Directory
    |
    └── modules
         |
         └── ec2
```

### Common Mistake

Wrong path:

```hcl
source = "./module/ec2"
```

when the actual directory is:

```text
modules/ec2
```

Always verify the directory structure.

---

# 6. Module Initialization

After adding or changing a module source, initialize Terraform:

```bash
terraform init
```

Terraform downloads or initializes the required module.

If Terraform reports that a module is not installed, run:

```bash
terraform init
```

---

# 7. Creating a Custom EC2 Module

A custom EC2 module should avoid embedding environment-specific values directly into the module.

Avoid:

```hcl
resource "aws_instance" "this" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"
}
```

Prefer configurable inputs:

```hcl
resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type
}
```

This makes the module reusable.

---

# 8. Module Variables

Variables allow the caller to provide values to the child module.

### Child Module

```hcl
variable "instance_type" {
  type = string
}
```

### Root Module

```hcl
module "ec2" {
  source        = "./modules/ec2"
  instance_type = "t3.micro"
}
```

### Data Flow

```text
Root Module
    |
    | instance_type
    v
Child Module Variable
    |
    v
Resource
```

---

# 9. Converting Hardcoded Values to Variables

Hardcoded:

```hcl
resource "aws_instance" "this" {
  instance_type = "t3.micro"
}
```

Reusable:

```hcl
variable "instance_type" {
  type = string
}

resource "aws_instance" "this" {
  instance_type = var.instance_type
}
```

### Rule

If a value is expected to vary between module consumers or environments, consider making it an input variable.

---

# 10. Hardcoding Values — Common Problem

### Problem

A module contains values tied to one specific environment:

```hcl
instance_type = "t3.micro"
```

This limits reuse.

### Better

```hcl
variable "instance_type" {
  type = string
}

resource "aws_instance" "this" {
  instance_type = var.instance_type
}
```

### Important

Do not convert **every single value** into a variable.

Only expose values that should reasonably be configurable.

Too many variables make a module unnecessarily complicated.

---

# 11. Module Outputs

Outputs expose values from a child module to its caller.

### Child Module

```hcl
output "instance_id" {
  value = aws_instance.this.id
}
```

### Root Module

```hcl
module "ec2" {
  source = "./modules/ec2"
}
```

The output can then be referenced as:

```hcl
module.ec2.instance_id
```

### Data Flow

```text
Resource
    |
    v
Child Module Output
    |
    v
Root Module
```

---

# 12. Common Output Mistake

Wrong:

```hcl
output "instance_id" {
  value = aws_instance.id
}
```

Correct resource reference:

```hcl
output "instance_id" {
  value = aws_instance.this.id
}
```

The resource address must match the actual resource declared in the child module.

---

# 13. Root Module vs Child Module

### Root Module

The configuration Terraform is executing from.

```text
terraform plan
      |
      v
Root Module
```

### Child Module

A module called by another module.

```text
Root Module
    |
    └── module.ec2
          |
          └── Child Module
```

### Important

The child module should not be treated as an independent copy of the root configuration.

The root module consumes the child module through its interface:

```text
Inputs → Module → Outputs
```

---

# 14. Module Interface

A professional module should have a clear interface.

```text
                Module
                  |
        +---------+---------+
        |                   |
      Inputs              Outputs
        |                   |
        v                   v
      Variables          Output Values
```

### Good Module Design

- Clear inputs
- Sensible defaults where appropriate
- Minimal unnecessary variables
- Useful outputs
- No environment-specific assumptions

---

# 15. Provider Configuration in Modules

Provider configuration and module logic should be separated conceptually.

The module defines resources and accepts required inputs.

The caller determines the provider configuration appropriate for the deployment.

Example root provider:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

Module:

```hcl
resource "aws_instance" "this" {
  instance_type = var.instance_type
}
```

---

# 16. Provider Configuration — Common Problems

### Problem: Provider Configuration Is Hardcoded Inside the Module

This can make the module less reusable.

For example:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

inside a reusable module can unnecessarily tie the module to a specific region.

### Better Approach

Keep the reusable module independent from environment-specific provider settings when possible.

---

# 17. Multiple Provider Configurations

Terraform can have multiple configurations of the same provider using aliases.

Example:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "secondary"
  region = "us-west-2"
}
```

A resource can use the aliased provider:

```hcl
resource "aws_s3_bucket" "secondary" {
  provider = aws.secondary

  bucket = "example-secondary-bucket"
}
```

### Key Concept

```text
aws
    → Default Provider

aws.secondary
    → Aliased Provider
```

---

# 18. Multiple Providers with Modules

When a child module needs a specific provider configuration, the provider mapping must be handled correctly by the caller.

Conceptually:

```text
Root Module
    |
    +── aws
    |
    +── aws.secondary
    |
    v
Child Module
```

### Common Problems

- Alias name does not match.
- Module expects a provider configuration that was not passed.
- Resource uses the wrong provider alias.
- Region is different from the intended deployment region.

Always verify provider aliases and module provider requirements.

---

# 19. Choosing the Right Module

Before using an existing module, evaluate:

```text
Is it maintained?
Is it trustworthy?
Does it solve the actual requirement?
Are inputs/outputs appropriate?
Is documentation available?
Is the source version controlled?
Does it introduce unnecessary complexity?
```

### Avoid

Choosing a module simply because it already exists.

The goal is:

```text
Right Module
    +
Right Source
    +
Right Version
    +
Right Configuration
```

---

# 20. Custom Module vs Existing Module

| Situation | Preferred Approach |
|---|---|
| Repeated internal infrastructure pattern | Custom module |
| Common standardized infrastructure | Existing trusted module |
| Organization-specific requirements | Custom module |
| Simple resource used once | Direct resource may be enough |
| Existing module does not fit requirements | Custom module |

A module is useful when it improves reuse and consistency.

Do not create modules purely for the sake of creating modules.

---

# 21. Standard Module Structure

A standard reusable module commonly follows:

```text
terraform-aws-example/
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
└── versions.tf
```

Depending on the module, additional files may be included.

For example:

```text
examples/
tests/
LICENSE
```

### Important

The exact structure should support maintainability and usability rather than adding unnecessary files.

---

# 22. Module Version Requirements

Reusable modules may depend on specific Terraform or provider versions.

A module can define requirements through a Terraform settings block.

Example:

```hcl
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}
```

### Purpose

Prevent the module from being used with incompatible versions.

---

# 23. Module Source and Version

For registry modules, a version can be specified:

```hcl
module "example" {
  source  = "namespace/module/provider"
  version = "1.0.0"
}
```

This provides predictable module behavior.

### Important

A module source and its version are separate concepts:

```text
source
    → Where is the module?

version
    → Which module version should be used?
```

---

# 24. Terraform Registry Publishing

A module intended for the Terraform Registry must follow the Registry's naming and repository conventions.

Typical naming follows:

```text
terraform-<PROVIDER>-<NAME>
```

For example:

```text
terraform-aws-example
```

### Professional Requirements

A publishable module should have:

- Correct repository naming
- Appropriate module structure
- Documentation
- Versioned releases
- Valid Terraform configuration
- Clear inputs
- Clear outputs
- Provider requirements

---

# 25. Module Registry Problems

### Problem: Module Not Found

Possible causes:

- Incorrect source.
- Incorrect namespace.
- Incorrect module name.
- Incorrect provider name.
- Module is not published.
- Typographical error.

Check the exact module source.

---

### Problem: Version Not Found

Example:

```text
No available releases match the given constraints
```

Possible causes:

- Requested version does not exist.
- Version constraint is incompatible.
- Registry has no matching release.

Verify the available module versions.

---

# 26. Module Source Problems

### Error

```text
Module not installed
```

### Solution

Run:

```bash
terraform init
```

---

### Error

```text
Failed to download module
```

Check:

```text
Source address
Network connectivity
Authentication
Module availability
Version constraint
```

---

# 27. Local Module Path Problems

### Problem

```text
Unreadable module directory
```

### Check

```text
modules/
└── ec2/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

Verify:

- Directory exists.
- Path is correct.
- Terraform files use `.tf`.
- Source points to the correct directory.

---

# 28. Module Variable Problems

### Problem

```text
Missing required argument
```

Cause:

The child module requires a variable but the caller did not provide it.

Child module:

```hcl
variable "instance_type" {
  type = string
}
```

Caller:

```hcl
module "ec2" {
  source = "./modules/ec2"
}
```

### Solution

Provide the value:

```hcl
module "ec2" {
  source        = "./modules/ec2"
  instance_type = "t3.micro"
}
```

---

# 29. Variable Name Mismatch

Child module:

```hcl
variable "instance_type" {
  type = string
}
```

Caller:

```hcl
module "ec2" {
  source = "./modules/ec2"

  instance_size = "t3.micro"
}
```

This is incorrect because:

```text
instance_size
```

does not match:

```text
instance_type
```

Use the exact variable name.

---

# 30. Module Output Problems

### Problem

The root module cannot access the desired value.

Check that the child module defines:

```hcl
output "instance_id" {
  value = aws_instance.this.id
}
```

Then reference:

```hcl
module.ec2.instance_id
```

### Rule

```text
Child Resource
      ↓
Child Output
      ↓
module.<name>.<output>
```

---

# 31. Circular Module Design

Avoid unnecessary circular dependencies.

Bad design:

```text
Module A
   ↓
Module B
   ↓
Module A
```

Prefer a clear dependency direction:

```text
Root
 ├── VPC Module
 │
 └── EC2 Module
        ↓
      VPC Outputs
```

Modules should have clear responsibilities and predictable dependencies.

---

# 32. Module Coupling

### High Coupling

A module assumes:

```text
specific VPC
specific subnet
specific region
specific security group
specific naming
```

This makes reuse difficult.

### Better

Pass required values through variables:

```hcl
variable "subnet_id" {
  type = string
}
```

Then:

```hcl
subnet_id = var.subnet_id
```

---

# 33. Module Improvements

A module should progressively move from:

```text
Hardcoded Values
        ↓
Variables
        ↓
Reusable Interface
        ↓
Outputs
        ↓
Reusable Module
```

The goal is not maximum abstraction.

The goal is **useful abstraction**.

---

# 34. Common Day 12 Errors

| Problem | Likely Cause | Prevention |
|---|---|---|
| Module not found | Incorrect source | Verify `source` |
| Module not installed | Initialization missing | Run `terraform init` |
| Missing required argument | Variable not supplied | Pass required input |
| Unsupported argument | Wrong variable name | Match child variable |
| Output not found | Missing child output | Define `output` |
| Invalid output reference | Wrong resource address | Verify child resource |
| Local module unreadable | Wrong path | Check directory |
| Provider configuration error | Wrong provider/alias | Verify provider mapping |
| Version conflict | Incompatible constraint | Check versions |
| Registry module unavailable | Wrong source/version | Verify Registry reference |
| Module too rigid | Hardcoded values | Convert appropriate values to variables |
| Module too complex | Excessive abstraction | Keep interface minimal |

---

# 35. Troubleshooting Workflow

When a module fails:

```text
terraform fmt
      ↓
terraform validate
      ↓
terraform init
      ↓
terraform plan
      ↓
Read exact error
      ↓
Check module source
      ↓
Check variables
      ↓
Check outputs
      ↓
Check provider configuration
      ↓
Check module directory structure
      ↓
terraform plan again
```

---

# 36. Module Debugging Checklist

```text
[ ] Correct module source
[ ] Correct local path
[ ] terraform init completed
[ ] Child module files exist
[ ] Required variables are provided
[ ] Variable names match
[ ] Variable types match
[ ] Outputs are declared
[ ] Output references are correct
[ ] Provider configuration is valid
[ ] Provider aliases are correct
[ ] Terraform/provider versions are compatible
[ ] Module has no unnecessary hardcoded values
[ ] terraform validate passes
[ ] terraform plan is reviewed
```

---

# 37. Professional Module Design Rules

```text
Reusable
    ↓
Clear Inputs
    ↓
Clear Outputs
    ↓
Minimal Hardcoding
    ↓
Minimal Coupling
    ↓
Predictable Provider Requirements
    ↓
Documented Structure
```

### Remember

A good module should hide implementation details while exposing only what the caller needs.

---

# 38. Quick Revision

```text
Module
→ Reusable Terraform configuration

source
→ Location of the module

Variable
→ Input to the module

Output
→ Value exposed by the module

Root Module
→ Module Terraform is executed from

Child Module
→ Module called by another module

local source
→ Local filesystem module

Provider Alias
→ Multiple configurations of the same provider

Standard Structure
→ main.tf + variables.tf + outputs.tf + supporting files

Registry Module
→ Reusable published module
```

---

# 39. Most Important Relationships

```text
Root Module
    |
    | source
    v
Child Module
    |
    +── variables
    |       ↑
    |       |
    |     Inputs
    |
    +── resources
    |
    +── outputs
            |
            v
      Root Module
```

---

# 40. Day 12 Scope

This notes file covers only:

```text
113. Basics of Terraform Modules
114. Creating EC2 instance using Modules
115. Choosing the Right Terraform Module
116. Creating Base Module Structure for Custom Module
117. Creating Custom Module for EC2
118. Module Sources - Calling a Module
119. Using Local Paths to Call Custom Module
120. Improvements in Custom Module Code
121. Variables in Terraform Modules
122. Converting Hardcoded Values to Variables in Custom Module
123. Improvements in Provider Configuration in Custom Module
124. Module Outputs
125. Root Module vs Child Module
126. Standard Module Structure
127. Multiple Provider Configuration in Modules
128. Requirement for Publishing Modules in Terraform Registry
```

