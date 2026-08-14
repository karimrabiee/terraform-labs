# Terraform Day 08 — Debugging & Code Cleanup

## Overview

This project focuses on Terraform debugging, troubleshooting, code formatting, configuration validation, Dynamic Blocks, resource replacement, Splat Expressions, saved execution plans, Terraform settings, and resource targeting.

The purpose of this lab is to improve Terraform code quality and develop a systematic approach to identifying and resolving Terraform problems.

> This project is intentionally limited to Day 08 topics.

---

## Learning Objectives

By completing this lab, you should understand how to:

- Debug Terraform configurations using `TF_LOG`.
- Classify Terraform errors using the troubleshooting model.
- Format Terraform code with `terraform fmt`.
- Validate Terraform configurations with `terraform validate`.
- Understand Terraform configuration file loading and load order.
- Avoid duplicate configuration objects.
- Use Dynamic Blocks to generate repeatable nested blocks.
- Force resource replacement with `terraform apply -replace`.
- Use Splat Expressions to retrieve attributes from multiple resource instances.
- Save Terraform execution plans to files.
- Inspect saved plan files with `terraform show`.
- Apply a previously saved plan.
- Configure project-specific Terraform requirements.
- Understand when Resource Targeting can be useful.
- Recognize why Resource Targeting should not be part of the normal workflow.

---

## Day 08 Topics

| Topic | Purpose |
|---|---|
| Terraform Debugging | Find the root cause of Terraform problems |
| `TF_LOG` | Enable detailed Terraform logging |
| Troubleshooting Model | Classify Terraform errors |
| `terraform fmt` | Standardize Terraform formatting |
| Load Order | Understand how Terraform loads configuration files |
| Dynamic Blocks | Generate repeated nested blocks |
| `terraform validate` | Validate Terraform configuration |
| `-replace` | Force resource replacement |
| Splat Expressions | Retrieve attributes from multiple resource instances |
| Plan Files | Save and reuse execution plans |
| Terraform Settings | Define project-level requirements |
| Resource Targeting | Target specific resources when necessary |

---

## 1. Terraform Debugging

Terraform provides detailed logging that can help identify the root cause of problems.

The `TF_LOG` environment variable controls Terraform's logging level.

Available levels include:

- `TRACE`
- `DEBUG`
- `INFO`
- `WARN`
- `ERROR`

`TRACE` provides the most detailed output.

For PowerShell, enable detailed logging with:

`$env:TF_LOG="TRACE"`

Then run:

`terraform plan`

For a less verbose level:

`$env:TF_LOG="DEBUG"`

`terraform plan`

To remove the environment variable in PowerShell:

`Remove-Item Env:TF_LOG`

Terraform logs can also be written to a file using `TF_LOG_PATH`.

Example:

`$env:TF_LOG="TRACE"`

`$env:TF_LOG_PATH="terraform.log"`

`terraform plan`

Use detailed logging when the normal Terraform error message does not provide enough information.

---

## 2. Terraform Troubleshooting Model

Terraform problems can generally be classified into four categories:

1. Language Errors
2. State Errors
3. Core Errors
4. Provider Errors

### Language Errors

Language errors are related to the Terraform configuration itself.

Examples include:

- Syntax errors.
- Invalid references.
- Unsupported arguments.
- Undeclared variables.
- Invalid configuration.

The Terraform error message normally identifies the relevant file and line.

Useful commands include:

`terraform fmt`

`terraform validate`

`terraform plan`

### State Errors

State errors can occur when Terraform state is not synchronized correctly with infrastructure or when state is locked.

State-related problems should be handled carefully because Terraform relies on state to understand the relationship between configuration and infrastructure.

### Core Errors

Core errors are related to Terraform itself.

These errors may indicate a problem with Terraform rather than the configuration or provider.

### Provider Errors

Provider errors are related to provider plugins and their interaction with external platforms.

For AWS, possible causes include:

- AWS API errors.
- IAM permission problems.
- Provider behavior.
- Provider version issues.
- AWS service limitations.

---

## 3. Terraform Formatting

Terraform provides the `terraform fmt` command to rewrite configuration files into Terraform's canonical format and style.

Run:

`terraform fmt`

To format Terraform files recursively:

`terraform fmt -recursive`

To check formatting without modifying files:

`terraform fmt -check`

To display formatting differences:

`terraform fmt -diff`

Formatting is important because consistent code improves:

- Readability.
- Code reviews.
- Git diffs.
- Collaboration.
- Maintenance.
- Troubleshooting.

### Recommended Formatting Workflow

Run:

`terraform fmt`

Then verify:

`terraform fmt -check`

For projects containing Terraform configuration in subdirectories:

`terraform fmt -recursive`

---

## 4. Terraform Configuration Load Order

Terraform normally loads configuration files ending in `.tf` and `.tf.json` from the working directory.

For example:

    main.tf
    network.tf
    security.tf
    compute.tf
    outputs.tf

These files are treated as one Terraform configuration.

Terraform loads configuration files in the directory alphabetically, but infrastructure dependencies should not be designed around file order.

Terraform determines dependencies from references between resources and configuration objects.

### Important Rule

Do not think of:

`network.tf`

and:

`compute.tf`

as separate execution stages.

They are parts of the same Terraform configuration.

---

## 5. Duplicate Configuration Objects

Because Terraform loads all `.tf` files in the same directory, duplicate configuration objects can cause errors.

For example, defining:

`resource "aws_instance" "web" { ... }`

in one file and defining the same:

`resource "aws_instance" "web" { ... }`

in another file creates a duplicate configuration object.

Terraform identifies both resources as:

`aws_instance.web`

Only one resource with that address should exist in the configuration.

---

## 6. Terraform Subdirectories

Terraform does not automatically load `.tf` files from subdirectories.

For example:

    project/
    ├── main.tf
    └── network/
        └── vpc.tf

The root configuration does not automatically include `network/vpc.tf`.

Subdirectories are separate Terraform working directories unless they are explicitly used through the appropriate Terraform configuration structure.

---

## 7. Dynamic Blocks

Dynamic Blocks are used to dynamically generate repeatable nested blocks.

They are useful when a resource contains nested blocks that need to be generated from a collection.

Without Dynamic Blocks, repeated nested configuration can require copying the same structure multiple times.

A Dynamic Block follows this general structure:

`dynamic "BLOCK_NAME" {`

`    for_each = COLLECTION`

`    content {`

`        # generated nested configuration`

`    }`

`}`

The `for_each` expression determines how many nested blocks are generated.

The current item can be accessed using:

`BLOCK_NAME.value`

---

## 8. Dynamic Block Example

A variable can contain a collection of rules.

Example structure:

`variable "ingress_rules" {`

`  type = list(object({`

`    port        = number`

`    protocol    = string`

`    cidr_blocks = list(string)`

`    description = string`

`  }))`

`}`

Example values:

`ingress_rules = [`

`  {`

`    port        = 80`

`    protocol    = "tcp"`

`    cidr_blocks = ["0.0.0.0/0"]`

`    description = "HTTP"`

`  },`

`  {`

`    port        = 443`

`    protocol    = "tcp"`

`    cidr_blocks = ["0.0.0.0/0"]`

`    description = "HTTPS"`

`  }`

`]`

The Dynamic Block can then generate the nested configuration for each item.

The important concepts are:

- `dynamic`
- `for_each`
- `content`
- `.value`

---

## 9. Dynamic Block Best Practice

Dynamic Blocks should be used when they provide a real benefit.

Do not use Dynamic Blocks simply because Terraform supports them.

If a resource contains only a small number of simple static blocks, explicitly defining those blocks may be easier to understand.

The goal is:

> Reduce unnecessary repetition without making the configuration harder to read.

---

## 10. Terraform Validate

Use:

`terraform validate`

to check whether the Terraform configuration is valid.

It can detect configuration problems such as:

- Unsupported arguments.
- Undeclared variables.
- Invalid configuration.
- Other Terraform configuration errors.

A typical workflow is:

`terraform init`

then:

`terraform validate`

then:

`terraform plan`

---

## 11. `terraform fmt` vs `terraform validate`

These commands have different purposes.

`terraform fmt`

means:

> Format the Terraform configuration.

`terraform validate`

means:

> Validate the Terraform configuration.

`terraform plan`

means:

> Generate an execution plan showing what Terraform intends to change.

A clean workflow is:

`terraform fmt`

then:

`terraform validate`

then:

`terraform plan`

---

## 12. Resource Replacement

Terraform can force a resource to be replaced using the `-replace` option.

Example:

`terraform apply -replace="aws_instance.web"`

This tells Terraform to replace the specified resource.

Conceptually:

    Existing Resource
           ↓
        Destroy
           ↓
         Create

This is useful when a resource needs to be recreated even though the current configuration does not normally require replacement.

---

## 13. Why Use `-replace`?

One possible situation is when a resource has been manually modified or when the resource needs to be recreated.

The modern Terraform approach is:

`terraform apply -replace="RESOURCE_ADDRESS"`

For example:

`terraform apply -replace="aws_instance.web"`

Older Terraform workflows used `terraform taint` for similar behavior.

For modern Terraform, prefer `-replace`.

---

## 14. Splat Expressions

Splat Expressions provide a convenient way to retrieve attributes from multiple resource instances.

For example, if a resource uses `count`:

`resource "aws_instance" "web" {`

`  count = 3`

`}`

The following Splat Expression can retrieve the public IP addresses:

`aws_instance.web[*].public_ip`

Conceptually, this represents:

`aws_instance.web[0].public_ip`

`aws_instance.web[1].public_ip`

`aws_instance.web[2].public_ip`

The result is a collection of public IP addresses.

---

## 15. Splat Expression and `for_each`

Resources created using `count` are represented as a list of instances.

Splat Expressions work naturally with this structure.

Resources created using `for_each` are represented as a map of objects.

Therefore, Splat Expressions cannot be used with `for_each` resources in exactly the same way.

When working with `for_each`, expressions such as `for` expressions are commonly used to transform or retrieve values.

---

## 16. Saving Terraform Execution Plans

Terraform can save an execution plan to a file.

Example:

`terraform plan -out=ec2.plan`

This saves the generated plan as:

`ec2.plan`

The saved plan can later be inspected and applied.

---

## 17. Inspecting a Saved Plan

Terraform plan files are binary files.

Do not open them as normal text files.

Use:

`terraform show ec2.plan`

to inspect the contents of a saved plan.

---

## 18. Applying a Saved Plan

After reviewing the saved plan, it can be applied using:

`terraform apply ec2.plan`

A common workflow is:

`terraform plan -out=ec2.plan`

then:

`terraform show ec2.plan`

then review the changes.

Finally:

`terraform apply ec2.plan`

This workflow helps ensure that the reviewed plan is the plan that gets applied.

---

## 19. Terraform Settings

Terraform project settings are defined inside a `terraform` block.

Example:

`terraform {`

`  ...`

`}`

Terraform settings can define requirements such as:

- Terraform version.
- Required providers.
- Provider version constraints.

---

## 20. Required Terraform Version

The project can specify a Terraform version constraint using `required_version`.

Example:

`terraform {`

`  required_version = ">= 1.8"`

`}`

This allows the project to define which Terraform versions are supported.

---

## 21. Required Providers

Provider requirements are defined using `required_providers`.

Example:

`terraform {`

`  required_providers {`

`    aws = {`

`      source  = "hashicorp/aws"`

`      version = "~> 5.0"`

`    }`

`  }`

`}`

This defines:

- Provider name.
- Provider source.
- Provider version constraint.

---

## 22. Provider Configuration

The `provider` block is different from `required_providers`.

Example:

`provider "aws" {`

`  region = "us-east-1"`

`}`

The `provider` block configures how the provider is used.

It can contain configuration such as:

- Region.
- Credentials.
- Alias.

The provider requirement belongs inside `required_providers`.

The provider configuration belongs inside the `provider` block.

---

## 23. Version Constraints

Terraform supports version constraints.

Examples:

`>= 1.0`

Means greater than or equal to version `1.0`.

`<= 1.0`

Means less than or equal to version `1.0`.

`~> 2.0`

Allows versions within the compatible `2.x` range.

`>= 2.10, <= 2.30`

Allows versions between `2.10` and `2.30`.

Version constraints help keep infrastructure projects predictable and controlled.

---

## 24. Resource Targeting

Normally Terraform evaluates the complete configuration when creating a plan.

Resource Targeting allows a specific resource or subset of resources to be targeted.

Example:

`terraform plan -target=aws_instance.web`

Or:

`terraform apply -target=aws_instance.web`

This limits the operation to the targeted resource and its relevant dependencies.

---

## 25. When Resource Targeting Can Be Useful

Resource Targeting may be useful in exceptional situations such as:

- Troubleshooting.
- State becoming out of sync.
- Network failures.
- Provider problems.
- Upstream cloud platform issues.
- Situations where only a specific part of the infrastructure needs to be addressed.

---

## 26. Resource Targeting Warning

Resource Targeting should not be part of the normal Terraform workflow.

Avoid using:

`terraform apply -target=...`

simply because the complete plan is large or inconvenient.

Terraform is designed to evaluate the infrastructure as a complete configuration and determine dependencies automatically.

Targeting should be reserved for exceptional situations where there is a specific reason to limit the operation.

---

## 27. Large Infrastructure and API Limits

Cloud providers have API limits.

Large Terraform configurations can cause a high number of provider API calls during operations such as:

`terraform plan`

This can potentially result in API throttling.

The issue becomes more important as the number of managed resources increases.

---

## 28. Managing Large Configurations

Large infrastructure configurations can sometimes be divided into smaller independently managed configurations.

For example:

    networking/
    ├── vpc.tf
    └── subnets.tf

    security/
    ├── security-groups.tf
    └── iam.tf

    compute/
    └── instances.tf

The exact project structure depends on the architecture and operational requirements.

The objective is to keep infrastructure manageable and avoid unnecessary operational complexity.

Resource targeting may reduce provider calls in specific exceptional situations, but it should not replace proper infrastructure design.

---

## 29. Recommended Day 08 Workflow

Start by formatting the configuration:

`terraform fmt`

Then check formatting:

`terraform fmt -check`

Validate the configuration:

`terraform validate`

Create a plan:

`terraform plan`

Review the planned changes.

If everything is correct:

`terraform apply`

After completing the practical lab and verifying the resources:

`terraform destroy`

---

## 30. Debugging Workflow

When Terraform returns an error, follow a systematic process.

    Terraform Error
          ↓
    Read Complete Error
          ↓
    Identify File + Line
          ↓
    Identify Error Category
          ↓
    Inspect Configuration
          ↓
    terraform fmt
          ↓
    terraform validate
          ↓
    terraform plan
          ↓
    TF_LOG if Required
          ↓
    Fix Root Cause
          ↓
    Validate Again
          ↓
    Plan Again

Do not randomly change configuration until the error disappears.

The goal is to identify and fix the root cause.

---

## 31. Day 08 Best Practices

### Formatting

- Always run `terraform fmt`.
- Use `terraform fmt -check` to verify formatting.
- Use `terraform fmt -recursive` when the project contains nested Terraform directories.

### Validation

- Run `terraform validate` before planning.
- Fix validation errors before continuing.

### Debugging

- Read the complete Terraform error.
- Check the referenced file and line.
- Classify the error.
- Use `TF_LOG` only when additional information is required.
- Use `TRACE` when deep debugging is necessary.

### Dynamic Blocks

- Use Dynamic Blocks when they reduce meaningful repetition.
- Keep Dynamic Blocks readable.
- Avoid unnecessary abstraction.

### Resource Replacement

- Use `-replace` when a resource must be recreated.
- Prefer modern `-replace` usage over the older taint workflow.

### Plan Files

- Save plans when review and approval are required.
- Inspect saved plans with `terraform show`.
- Apply the reviewed plan using the saved plan file.

### Terraform Settings

- Define supported Terraform versions.
- Define required providers.
- Use controlled provider version constraints.

### Resource Targeting

- Understand `-target`.
- Use targeting only for exceptional situations.
- Do not make resource targeting part of the standard workflow.

---

## 32. Git and Repository Hygiene

Terraform-generated files should not be committed blindly.

Common files that should be reviewed before committing include:

- `.terraform/`
- Terraform state files.
- Terraform backup state files.
- Saved plan files.
- Debug logs.

Sensitive values should never be committed to a public repository.

The `.gitignore` file should be configured appropriately for the project.

---

## 33. Recommended Verification Before Commit

Run:

`terraform fmt -recursive`

Then:

`terraform fmt -check`

Then:

`terraform validate`

Then:

`terraform plan`

Review:

`git status`

Check the changes before committing.

Example commit:

`git add .`

`git commit -m "chore(day08): format terraform configurations"`

`git push`

The commit message should accurately describe the actual changes.

---

## 34. Day 08 Command Reference

### Formatting

`terraform fmt`

`terraform fmt -recursive`

`terraform fmt -check`

`terraform fmt -diff`

### Validation

`terraform validate`

### Debugging — PowerShell

`$env:TF_LOG="DEBUG"`

`terraform plan`

`$env:TF_LOG="TRACE"`

`terraform plan`

`$env:TF_LOG_PATH="terraform.log"`

`Remove-Item Env:TF_LOG`

### Saved Plans

`terraform plan -out=ec2.plan`

`terraform show ec2.plan`

`terraform apply ec2.plan`

### Resource Replacement

`terraform apply -replace="aws_instance.web"`

### Resource Targeting

`terraform plan -target=aws_instance.web`

`terraform apply -target=aws_instance.web`

---

## 35. Day 08 Checklist

### Terraform Formatting

- [ ] Run `terraform fmt`.
- [ ] Run `terraform fmt -check`.
- [ ] Run `terraform fmt -recursive` when required.

### Terraform Validation

- [ ] Run `terraform validate`.
- [ ] Fix configuration errors.

### Debugging

- [ ] Understand `TF_LOG`.
- [ ] Understand `TF_LOG_PATH`.
- [ ] Understand the four troubleshooting categories.
- [ ] Know when to use `TRACE`.

### Configuration

- [ ] Understand `.tf` file loading.
- [ ] Avoid duplicate configuration objects.
- [ ] Understand subdirectory behavior.

### Dynamic Blocks

- [ ] Understand `dynamic`.
- [ ] Understand `for_each`.
- [ ] Understand `content`.
- [ ] Understand `.value`.
- [ ] Avoid unnecessary Dynamic Blocks.

### Resource Replacement

- [ ] Understand `-replace`.
- [ ] Know the difference between modern `-replace` and the older taint workflow.

### Splat Expressions

- [ ] Understand `[*]`.
- [ ] Understand Splat Expressions with `count`.
- [ ] Understand why `for_each` resources are handled differently.

### Plan Files

- [ ] Create a saved plan.
- [ ] Inspect the plan.
- [ ] Apply the saved plan.

### Terraform Settings

- [ ] Understand `required_version`.
- [ ] Understand `required_providers`.
- [ ] Understand provider configuration.
- [ ] Understand version constraints.

### Resource Targeting

- [ ] Understand `-target`.
- [ ] Know why it should not be used as the normal workflow.

---

## 36. Key Takeaways

The most important commands from Day 08 are:

`terraform fmt`

`terraform fmt -check`

`terraform fmt -recursive`

`terraform validate`

`terraform plan`

`terraform plan -out=ec2.plan`

`terraform show ec2.plan`

`terraform apply ec2.plan`

`terraform apply -replace="RESOURCE_ADDRESS"`

`terraform plan -target=RESOURCE_ADDRESS`

`terraform apply -target=RESOURCE_ADDRESS`

The most important concepts are:

- Terraform Debugging.
- `TF_LOG`.
- Terraform Troubleshooting Model.
- Terraform Formatting.
- Configuration Load Order.
- Duplicate Configuration Objects.
- Dynamic Blocks.
- Terraform Validation.
- Resource Replacement.
- Splat Expressions.
- Saved Execution Plans.
- Terraform Settings.
- Provider Requirements.
- Resource Targeting.
- Provider API Limits.

---

## 37. Final Mental Model

Day 08 should be remembered as the Terraform debugging and code-quality day.

The core workflow is:

    FORMAT
       ↓
    VALIDATE
       ↓
    PLAN
       ↓
    REVIEW
       ↓
    APPLY
       ↓
    VERIFY

When something fails:

    IDENTIFY
       ↓
    CLASSIFY
       ↓
    DEBUG
       ↓
    FIX
       ↓
    VALIDATE
       ↓
    PLAN AGAIN

The main troubleshooting categories are:

    LANGUAGE
    STATE
    CORE
    PROVIDER

Dynamic Blocks follow this model:

    COLLECTION
        ↓
    for_each
        ↓
    dynamic block
        ↓
    content
        ↓
    GENERATED NESTED BLOCKS

Saved Plans follow this model:

    terraform plan -out=ec2.plan
                ↓
    terraform show ec2.plan
                ↓
              REVIEW
                ↓
    terraform apply ec2.plan

Resource Replacement follows this model:

    terraform apply -replace="RESOURCE"
                ↓
             DESTROY
                ↓
              CREATE

---

## 38. Final Rule

The objective of Day 08 is not to memorize Terraform commands.

The objective is to develop a systematic Terraform troubleshooting and code-quality mindset:

    Identify the problem
            ↓
    Classify the problem
            ↓
    Inspect the configuration
            ↓
    Use the appropriate Terraform command
            ↓
    Fix the root cause
            ↓
    Validate
            ↓
    Plan
            ↓
    Review
            ↓
    Apply

A professional Terraform workflow should produce infrastructure that is not only functional, but also readable, consistent, valid, maintainable, and easier to troubleshoot.