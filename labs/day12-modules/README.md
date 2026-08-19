# Terraform Day 12 — Modules

## Overview

This project covers **Terraform Modules** and how to design, consume, improve, and publish reusable Terraform modules.

The focus is on:

- Using existing modules
- Creating custom modules
- Module sources
- Local module paths
- Module variables and outputs
- Provider configuration
- Root vs Child Modules
- Standard Module Structure
- Multiple Provider Configurations
- Terraform Registry publishing requirements

---

## Learning Objectives

By the end of this day, you should understand how to:

- Reuse Terraform code through modules.
- Create a custom EC2 module.
- Call local and remote modules.
- Replace hardcoded module values with variables.
- Expose useful values through module outputs.
- Understand Root and Child Modules.
- Configure provider requirements correctly.
- Use multiple provider configurations.
- Evaluate existing Terraform modules before using them.
- Understand the requirements for publishing a module to the Terraform Registry.

---

# 1. What Is a Terraform Module?

A Terraform module is a reusable collection of Terraform configuration.

Instead of repeating the same infrastructure code across multiple projects, the configuration can be centralized into a module.

Without modules:

```text
Team 1 → EC2 Code
Team 2 → EC2 Code
Team 3 → EC2 Code
Team 4 → EC2 Code
```

This creates:

- Code duplication
- Difficult maintenance
- Inconsistent configurations
- Repeated changes

With modules:

```text
                 EC2 Module
                     |
        +------------+------------+
        |            |            |
      Team 1       Team 2       Team 3
```

The module provides a standardized implementation that multiple projects can reuse.

---

# 2. Why Use Modules?

Modules help organizations achieve:

- **Reusability**
- **Standardization**
- **Centralized configuration**
- **Reduced duplication**
- **Easier maintenance**

A module allows a team to define infrastructure once and allow multiple consumers to use it.

---

# 3. Multiple Modules in a Project

A project can consume multiple modules.

Example:

```text
Infrastructure
│
├── VPC Module
├── Security Group Module
├── EC2 Module
└── IAM Module
```

This allows infrastructure to be divided into logical and reusable components.

---

# 4. Using an Existing Module

Terraform modules can come from different sources, including:

- Terraform Registry
- GitHub
- Generic Git repositories
- HTTP URLs
- S3
- Local filesystem paths

A module is called using a `module` block.

```hcl
module "ec2" {
  source = "./modules/ec2"
}
```

The `source` argument identifies where Terraform should obtain the module.

---

# 5. Module Documentation

Do not assume that calling a module automatically creates the required infrastructure.

Some modules require specific inputs.

Before using a module, check its documentation for:

- Required inputs
- Optional inputs
- Outputs
- Provider requirements
- Supported versions
- Usage examples
- Module structure

A module may also contain multiple sub-modules, so verify that you are referencing the correct module.

---

# 6. Choosing the Right Terraform Module

The Terraform Registry can contain multiple modules for the same infrastructure requirement.

Do not select a module only because it exists.

Evaluate the module before using it.

### Check:

1. Total downloads
2. GitHub repository
3. Contributors
4. Reported issues
5. Documentation
6. Version history
7. Source code quality
8. Community feedback
9. Maintenance activity
10. Whether it is maintained by a HashiCorp Partner

A module should be actively maintained, understandable, documented, and appropriate for the use case.

---

# 7. Security Consideration When Choosing Modules

Terraform modules execute Terraform configuration with access to the infrastructure being managed.

Using an untrusted module can therefore introduce security risks.

Avoid blindly using random modules, especially modules that:

- Are poorly maintained
- Have unclear ownership
- Contain suspicious code
- Lack documentation
- Have no meaningful version history

Always inspect the source before using third-party modules in important environments.

---

# 8. Base Custom Module Structure

A common organization structure is:

```text
modules/
├── ec2/
├── vpc/
├── iam/
└── sg/
```

Each module directory contains the Terraform configuration for that specific reusable component.

Example:

```text
modules/
└── ec2/
    └── main.tf
```

Teams can then consume these modules according to their requirements.

---

# 9. Practical Organization Structure

A larger organization can separate reusable modules from team configurations:

```text
terraform-project/
│
├── modules/
│   ├── ec2/
│   ├── vpc/
│   ├── iam/
│   └── sg/
│
└── teams/
    ├── team-a/
    ├── team-b/
    └── team-c/
```

Conceptually:

```text
                    Modules
                       |
        +--------------+--------------+
        |              |              |
      Team A         Team B         Team C
```

The module is maintained centrally while teams consume it.

---

# 10. Creating a Custom EC2 Module

A simple EC2 module may initially contain:

```hcl
resource "aws_instance" "this" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"
}
```

The root module can call it:

```hcl
module "ec2" {
  source = "./modules/ec2"
}
```

The module creates the EC2 resource according to its configuration.

---

# 11. Module Sources

The module `source` specifies where the module is located.

General syntax:

```hcl
module "example" {
  source = "MODULE_SOURCE"
}
```

Possible sources include:

```text
Local path
Terraform Registry
GitHub
Generic Git repository
HTTP URL
S3
```

---

# 12. Local Module Paths

A local module is referenced using a relative filesystem path.

Example:

```hcl
module "ec2" {
  source = "./modules/ec2"
}
```

A local path must begin with:

```text
./
```

or:

```text
../
```

Examples:

```hcl
source = "./modules/ec2"
```

```hcl
source = "../modules/ec2"
```

### Important

Modules sourced from local paths do **not** support module version constraints.

---

# 13. Generic Git Repository

A Git repository can be used as a module source.

The `git::` prefix identifies the source as a generic Git repository.

Example:

```hcl
module "ec2" {
  source = "git::https://example.com/terraform-modules.git"
}
```

A specific Git reference can also be selected when required.

The important distinction is:

```text
Local module
    → Filesystem path

Git module
    → Git repository
```

---

# 14. Module Versioning

A module can have multiple versions.

For registry modules, a version can be specified:

```hcl
module "ec2" {
  source  = "namespace/ec2/aws"
  version = "1.0.0"
}
```

Version constraints help prevent unexpected module changes.

For reusable and production modules, explicitly constraining acceptable versions is recommended.

---

# 15. Hardcoded Values in Modules

A major problem with a simple module is hardcoded values.

Example:

```hcl
resource "aws_instance" "this" {
  instance_type = "t2.micro"
}
```

Every consumer is forced to use:

```text
t2.micro
```

The caller cannot override it.

This reduces module flexibility.

---

# 16. Converting Hardcoded Values to Variables

Instead of:

```hcl
resource "aws_instance" "this" {
  instance_type = "t2.micro"
}
```

Use:

```hcl
variable "instance_type" {
  type = string
}

resource "aws_instance" "this" {
  instance_type = var.instance_type
}
```

The root module can then provide the value:

```hcl
module "ec2" {
  source        = "./modules/ec2"
  instance_type = "t2.micro"
}
```

Another team can use:

```hcl
module "ec2" {
  source        = "./modules/ec2"
  instance_type = "m5.large"
}
```

The same module can therefore support different requirements.

---

# 17. Variables in Terraform Modules

Module variables create the interface between the caller and the child module.

```text
Root Module
     |
     | Input
     v
Child Module
     |
     v
Resource
```

Example:

```hcl
variable "instance_type" {
  type = string
}
```

Caller:

```hcl
module "ec2" {
  source        = "./modules/ec2"
  instance_type = "t3.micro"
}
```

---

# 18. Module Code Improvements

A professional module should avoid unnecessary hardcoding.

Common improvements include:

```text
Hardcoded values
       ↓
Variables
       ↓
Reusable configuration
       ↓
Outputs
       ↓
Clean module interface
```

The objective is not to expose every possible argument.

The objective is to expose the values that consumers reasonably need to control.

---

# 19. Provider Configuration in Modules

Avoid unnecessarily hardcoding the provider's environment-specific configuration inside a reusable module.

For example, avoid tying a reusable module to a specific region unless there is a specific requirement.

Instead, define provider requirements appropriately and allow the caller to determine the provider configuration.

Example requirement:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}
```

Provider requirements define what the module needs.

They do not replace the provider configuration itself.

---

# 20. `required_providers` vs `provider`

### `required_providers`

Defines provider requirements and constraints.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}
```

### `provider`

Defines an actual provider configuration.

```hcl
provider "aws" {
  region = "us-east-1"
}
```

Think:

```text
required_providers
    → What provider does the module require?

provider
    → How is that provider configured?
```

---

# 21. Module Outputs

Outputs expose information from a child module.

Example:

```hcl
output "instance_id" {
  value = aws_instance.this.id
}
```

The root module can access it using:

```hcl
module.ec2.instance_id
```

General format:

```text
module.<MODULE_NAME>.<OUTPUT_NAME>
```

Example:

```text
module.ec2.instance_id
```

---

# 22. Why Module Outputs Matter

Suppose the EC2 module creates an instance.

Another resource outside the module may need the instance ID.

Without an output, the parent module cannot directly access the child module's internal resource attributes.

With an output:

```text
EC2 Resource
     |
     v
Child Module Output
     |
     v
Root Module
```

Outputs make modules easier to integrate with other infrastructure.

---

# 23. Root Module vs Child Module

### Root Module

The root module is the Terraform configuration in the main working directory.

It is the entry point for the infrastructure definition.

```text
terraform plan
      |
      v
Root Module
```

### Child Module

A module called by another module is a child module.

```text
Root Module
      |
      └── module.ec2
              |
              └── Child Module
```

---

# 24. Root → Child Module Communication

The normal module interface is:

```text
Root Module
    |
    | Variables
    v
Child Module
    |
    | Outputs
    v
Root Module
```

This creates a clean separation between:

- What the module needs
- What the module creates
- What the module exposes

---

# 25. Standard Module Structure

For reusable modules distributed separately, a standard structure is recommended.

A common structure is:

```text
terraform-aws-example/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── README.md
└── examples/
```

The exact files may vary according to the module's requirements.

The important objective is a predictable and maintainable structure.

---

# 26. `versions.tf`

A reusable module can define Terraform and provider requirements.

Example:

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}
```

This documents the dependencies required by the module.

---

# 27. Multiple Provider Configurations

Terraform allows multiple configurations of the same provider.

Example:

```hcl
provider "aws" {
  region = "ap-southeast-1"
}

provider "aws" {
  alias  = "secondary"
  region = "ap-south-1"
}
```

There is:

```text
aws
    → Default configuration

aws.secondary
    → Alternate configuration
```

---

# 28. Provider Alias

The `alias` argument creates an alternate provider configuration.

```hcl
provider "aws" {
  alias  = "secondary"
  region = "ap-south-1"
}
```

A resource can select the alternate configuration:

```hcl
resource "aws_s3_bucket" "secondary" {
  provider = aws.secondary

  bucket = "example-secondary-bucket"
}
```

The `provider` meta-argument selects which provider configuration the resource should use.

---

# 29. Multiple Providers and Modules

A module may need to work with different provider configurations.

The important concept is:

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

Provider aliases must be configured and passed correctly when the child module requires a specific provider configuration.

### Common Issues

- Wrong alias name
- Missing provider mapping
- Resource using the wrong provider
- Resources deployed to the wrong region

Always verify provider configuration before applying.

---

# 30. Terraform Registry

The Terraform Registry is a public repository of reusable Terraform modules.

Modules published there support features such as:

- Versioning
- Documentation
- Version history
- Examples
- README display

A module has an address used to reference it.

General Registry module address:

```text
hostname/namespace/name/provider
```

The hostname is optional for the public Terraform Registry.

---

# 31. Publishing Modules to Terraform Registry

The public Terraform Registry has specific requirements.

### Main Requirements

```text
GitHub
    ↓
Public Repository
    ↓
Correct Repository Name
    ↓
Standard Module Structure
    ↓
Semantic Version Tags
    ↓
Registry Publication
```

---

# 32. Repository Naming Requirement

For a public Registry module, the repository should follow:

```text
terraform-<PROVIDER>-<NAME>
```

Example:

```text
terraform-aws-example
```

The naming convention allows the Registry to identify the provider and module name.

---

# 33. GitHub Requirement

For the public Terraform Registry:

- The module repository must be hosted on GitHub.
- The repository must be public.

The repository description is also used as the module's short description.

---

# 34. Semantic Versioning

Registry releases use semantic version tags.

Examples:

```text
v1.0.4
```

or:

```text
0.9.2
```

The version tag identifies the module release.

Use consistent versioning for predictable module consumption.

---

# 35. Standard Structure for Registry Modules

A Registry module should follow the standard module structure.

A typical layout:

```text
terraform-aws-example/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── README.md
│
└── examples/
```

The structure should make the module easy to understand and consume.

---

# 36. Common Module Problems

| Problem | Cause | Solution |
|---|---|---|
| Module not found | Incorrect source | Verify `source` |
| Module not installed | Initialization not completed | Run `terraform init` |
| Wrong local module | Incorrect path | Check `./` or `../` |
| Required variable missing | Caller did not provide input | Pass required variable |
| Unsupported module argument | Variable name mismatch | Match child variable name |
| Output unavailable | Output not defined | Add child module output |
| Hardcoded module behavior | Values embedded in module | Convert appropriate values to variables |
| Provider error | Incorrect provider configuration | Check provider requirements/configuration |
| Wrong region | Incorrect provider/alias | Verify provider configuration |
| Version issue | Invalid version constraint | Check module/provider versions |
| Registry module unavailable | Incorrect source/version | Verify Registry address and release |
| Module is difficult to reuse | High coupling/hardcoding | Improve module interface |

---

# 37. Module Troubleshooting Workflow

When a module does not work:

```text
terraform fmt
      ↓
terraform init
      ↓
terraform validate
      ↓
terraform plan
      ↓
Check module source
      ↓
Check module variables
      ↓
Check module outputs
      ↓
Check provider configuration
      ↓
Check versions
      ↓
Review plan
```

---

# 38. Module Debugging Checklist

```text
[ ] Correct module source
[ ] Correct local path
[ ] terraform init completed
[ ] Module directory exists
[ ] Required variables provided
[ ] Variable names match
[ ] Variable types match
[ ] Outputs are defined
[ ] Output references are correct
[ ] Provider requirements are valid
[ ] Provider aliases are correct
[ ] Correct region/provider is being used
[ ] Module version is valid
[ ] Registry requirements are satisfied
[ ] terraform validate passes
[ ] terraform plan reviewed
```

---

# 39. Professional Module Design

A good reusable module should have:

```text
Clear Purpose
     ↓
Minimal Hardcoding
     ↓
Well-Defined Inputs
     ↓
Useful Outputs
     ↓
Controlled Provider Requirements
     ↓
Clear Documentation
     ↓
Versioning
```

### Avoid

```text
Huge Module
     +
Too Many Variables
     +
Hardcoded Environment Details
     +
Unclear Outputs
     +
Strong Coupling
```

The goal is **reusable abstraction**, not unnecessary complexity.

---

# 40. Recommended Project Structure

For a practical module project:

```text
day12-modules/
│
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
│
└── modules/
    └── ec2/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── versions.tf
```

This separates:

```text
Root Configuration
        ↓
Module Interface
        ↓
Reusable Infrastructure
```

---

# 41. Useful Terraform Commands

Initialize modules and providers:

```bash
terraform init
```

Format configuration:

```bash
terraform fmt
```

Validate configuration:

```bash
terraform validate
```

Create an execution plan:

```bash
terraform plan
```

Apply the configuration:

```bash
terraform apply
```

Upgrade module/provider selections when appropriate:

```bash
terraform init -upgrade
```

---

# 42. Day 12 Key Takeaways

```text
Module
→ Reusable Terraform configuration

source
→ Location of the module

Variable
→ Input to a module

Output
→ Information exposed by a module

Root Module
→ Main working directory

Child Module
→ Module called by another module

Local Source
→ ./ or ../ filesystem path

Provider Alias
→ Alternate provider configuration

Standard Module
→ Predictable reusable structure

Registry Module
→ Published reusable module

Versioning
→ Controls module release selection
```

---

# 43. Module Mental Model

```text
                    ROOT MODULE
                         |
                         |
                    module "ec2"
                         |
              +----------+----------+
              |                     |
           Inputs                Provider
              |                     |
              v                     v
                    CHILD MODULE
                         |
                  +------+------+
                  |             |
             Resources       Outputs
                  |             |
                  +------+------+
                         |
                         v
                    ROOT MODULE
```

---

# 44. Day 12 Video Scope

This README intentionally covers only the Day 12 curriculum:

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

No topics from Day 10, Day 11, or later course sections are intentionally included.

---

# Conclusion

Day 12 focuses on turning Terraform configuration into **reusable, maintainable modules**.

The core design pattern is:

```text
Reusable Infrastructure
        ↓
      Module
        ↓
   Variables + Outputs
        ↓
   Provider Requirements
        ↓
    Versioned Module
        ↓
 Reusable Across Projects
```

The most important professional principle is:

> **A module should provide a clear interface, avoid unnecessary hardcoding, expose useful outputs, and remain reusable across different consumers and environments.**