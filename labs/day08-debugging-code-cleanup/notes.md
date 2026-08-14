# Terraform Day 08 — Notes & Troubleshooting

## Scope

Day 08 focuses on Terraform debugging, troubleshooting, code formatting, configuration validation, Dynamic Blocks, resource replacement, Splat Expressions, saved execution plans, Terraform settings, Resource Targeting, and considerations for larger Terraform configurations.

These notes are intended as a practical reference for the concepts covered in Day 08.

---

# 1. Terraform Debugging

## Definition

Debugging is the process of identifying the root cause of a specific problem.

Terraform provides detailed logging through the `TF_LOG` environment variable.

Available log levels:

- `TRACE`
- `DEBUG`
- `INFO`
- `WARN`
- `ERROR`

`TRACE` provides the highest level of detail.

---

# 2. TF_LOG

`TF_LOG` controls the amount of diagnostic information Terraform produces.

For PowerShell:

`$env:TF_LOG="TRACE"`

Then run:

`terraform plan`

For less verbose logging:

`$env:TF_LOG="DEBUG"`

Then:

`terraform plan`

To remove the environment variable:

`Remove-Item Env:TF_LOG`

---

# 3. TF_LOG_PATH

Terraform logs can be written to a file using `TF_LOG_PATH`.

Example:

`$env:TF_LOG="TRACE"`

`$env:TF_LOG_PATH="terraform.log"`

`terraform plan`

This is useful when Terraform produces a large amount of diagnostic output.

---

# 4. Debugging Best Practice

Do not immediately start with `TRACE`.

Use a systematic approach:

    Read the Error
          ↓
    Identify File + Line
          ↓
    Understand the Problem
          ↓
    Check Configuration
          ↓
    terraform fmt
          ↓
    terraform validate
          ↓
    terraform plan
          ↓
    TF_LOG if Required

The objective is to understand the root cause instead of randomly changing configuration.

---

# 5. Terraform Troubleshooting Model

Terraform problems can be grouped into four categories:

1. Language Errors
2. State Errors
3. Core Errors
4. Provider Errors

This classification helps determine where to investigate.

---

# 6. Language Errors

Language errors are related to the Terraform configuration.

Examples:

- Syntax errors.
- Invalid references.
- Unsupported arguments.
- Undeclared variables.
- Invalid configuration.

Terraform normally provides the file and line where the problem was detected.

Useful commands:

`terraform fmt`

`terraform validate`

`terraform plan`

---

# 7. State Errors

State errors can occur when:

- Terraform state is out of sync.
- Terraform state is locked.
- Terraform cannot safely perform a state-changing operation.

State is important because Terraform uses it to understand the relationship between configuration and infrastructure.

State-related problems should be handled carefully.

---

# 8. Core Errors

Core errors are related to Terraform itself.

They may indicate an issue with Terraform rather than:

- The configuration.
- The provider.
- The infrastructure platform.

When investigating a possible core issue, collect enough information to reproduce the problem.

---

# 9. Provider Errors

Provider errors are related to provider plugins and their communication with external platforms.

For AWS, possible causes include:

- AWS API errors.
- IAM permissions.
- Provider behavior.
- Provider version issues.
- AWS service limitations.

Do not assume that every error returned during an AWS operation is a Terraform configuration error.

---

# 10. Terraform Formatting

The command:

`terraform fmt`

formats Terraform configuration using Terraform's canonical formatting style.

Formatting improves:

- Readability.
- Code reviews.
- Git diffs.
- Collaboration.
- Maintainability.
- Troubleshooting.

---

# 11. terraform fmt Commands

Format the current directory:

`terraform fmt`

Format recursively:

`terraform fmt -recursive`

Check formatting without changing files:

`terraform fmt -check`

Show formatting differences:

`terraform fmt -diff`

---

# 12. terraform fmt -check

Use:

`terraform fmt -check`

to verify whether Terraform files are correctly formatted.

The command does not modify the files.

This is especially useful for automated checks and CI/CD workflows.

---

# 13. terraform fmt -recursive

Use:

`terraform fmt -recursive`

when Terraform configuration exists in nested directories that should also be formatted.

Without `-recursive`, `terraform fmt` operates on the current directory.

---

# 14. terraform fmt -diff

Use:

`terraform fmt -diff`

to see the formatting changes Terraform would make.

This is useful when reviewing formatting differences before modifying the files.

---

# 15. Terraform File Loading

Terraform normally loads configuration files ending with:

- `.tf`
- `.tf.json`

from the current working directory.

Example:

    main.tf
    network.tf
    security.tf
    compute.tf
    outputs.tf

Terraform treats these files as one configuration.

---

# 16. Terraform File Order

Terraform loads configuration files in alphabetical order within the working directory.

However, infrastructure dependencies should not depend on file order.

Terraform understands relationships through configuration references.

For example, a resource referencing another resource creates a dependency based on the reference itself.

Therefore:

    network.tf
    compute.tf

does not mean Terraform executes the entire `network.tf` file first and then executes `compute.tf`.

---

# 17. Duplicate Configuration Objects

All `.tf` files in the same directory belong to the same configuration.

Therefore, avoid defining the same configuration object more than once.

Example:

`resource "aws_instance" "web" { ... }`

If another `.tf` file contains the same resource address:

`aws_instance.web`

Terraform will report a duplicate configuration problem.

---

# 18. Terraform Subdirectories

Terraform does not automatically load `.tf` files from subdirectories.

Example:

    project/
    ├── main.tf
    └── network/
        └── vpc.tf

The root configuration does not automatically include:

`network/vpc.tf`

The subdirectory is treated separately unless it is explicitly used as part of the Terraform structure.

---

# 19. Dynamic Blocks

Dynamic Blocks are used to dynamically generate repeatable nested blocks.

They are useful when a resource contains repeated nested configuration.

General structure:

`dynamic "BLOCK_NAME" {`

`  for_each = COLLECTION`

`  content {`

`    # generated nested block`

`  }`

`}`

---

# 20. Dynamic Block Components

A Dynamic Block contains three important parts:

### Dynamic Block Name

Example:

`dynamic "ingress"`

This identifies the nested block that Terraform should generate.

### for_each

Example:

`for_each = var.ingress_rules`

This determines the collection that Terraform will iterate over.

### content

The `content` block defines the generated nested configuration.

The current item can be accessed using:

`BLOCK_NAME.value`

---

# 21. Dynamic Block Example

Example variable:

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

Dynamic Block:

`dynamic "ingress" {`

`  for_each = var.ingress_rules`

`  content {`

`    from_port   = ingress.value.port`

`    to_port     = ingress.value.port`

`    protocol    = ingress.value.protocol`

`    cidr_blocks = ingress.value.cidr_blocks`

`    description = ingress.value.description`

`  }`

`}`

---

# 22. Dynamic Block Mental Model

Think of Dynamic Blocks as:

    Collection
        ↓
    for_each
        ↓
    Dynamic Block
        ↓
    content
        ↓
    Generated Nested Blocks

For example, two items in `var.ingress_rules` can result in two generated `ingress` blocks.

---

# 23. Dynamic Block Best Practice

Do not use Dynamic Blocks everywhere.

Use them when they reduce meaningful repetition.

If a resource contains only a small number of simple static blocks, explicitly defining those blocks may be easier to understand.

The objective is:

> Reduce repetition without reducing readability.

---

# 24. terraform validate

Use:

`terraform validate`

to check whether the Terraform configuration is valid.

It can identify configuration problems such as:

- Unsupported arguments.
- Undeclared variables.
- Invalid configuration.
- Other configuration errors.

---

# 25. terraform validate Workflow

A typical workflow is:

`terraform init`

then:

`terraform validate`

then:

`terraform plan`

Initialization may be required before validation when providers or modules need to be installed or referenced.

---

# 26. fmt vs validate vs plan

Remember the difference:

`terraform fmt`

→ Formats Terraform code.

`terraform validate`

→ Checks Terraform configuration validity.

`terraform plan`

→ Creates an execution plan.

A clean workflow is:

    terraform fmt
          ↓
    terraform validate
          ↓
    terraform plan

---

# 27. Resource Replacement

Terraform can force a resource to be replaced using:

`terraform apply -replace="RESOURCE_ADDRESS"`

Example:

`terraform apply -replace="aws_instance.web"`

The conceptual operation is:

    Existing Resource
          ↓
        Destroy
          ↓
         Create

---

# 28. Why Use -replace?

`-replace` is useful when a resource needs to be recreated even though Terraform does not normally detect a configuration change that requires replacement.

For example, a resource may have been manually modified and need to be recreated.

Use:

`terraform apply -replace="aws_instance.web"`

---

# 29. Taint vs Replace

Older Terraform workflows used:

`terraform taint`

for similar behavior.

For modern Terraform, use:

`terraform apply -replace="RESOURCE_ADDRESS"`

The `-replace` workflow is the preferred modern approach.

---

# 30. Splat Expressions

Splat Expressions provide a convenient way to retrieve attributes from multiple resource instances.

Example:

`resource "aws_instance" "web" {`

`  count = 3`

`}`

Retrieve all public IP addresses:

`aws_instance.web[*].public_ip`

This represents the public IP attribute from each instance.

Conceptually:

    aws_instance.web[0].public_ip
    aws_instance.web[1].public_ip
    aws_instance.web[2].public_ip

---

# 31. Splat Expressions with count

Splat Expressions work naturally with resources created using `count`.

For example:

`aws_instance.web[*].public_ip`

returns the public IP values from the instances represented by:

`aws_instance.web`

---

# 32. Splat Expressions and for_each

Resources created with `for_each` are represented as a map of objects.

Therefore, Splat Expressions cannot be used with `for_each` resources in exactly the same way as they are used with `count`.

When working with `for_each`, other expressions such as `for` expressions can be used to retrieve or transform values.

---

# 33. Saved Terraform Plans

Terraform can save an execution plan to a file.

Example:

`terraform plan -out=ec2.plan`

This creates a saved plan file:

`ec2.plan`

---

# 34. Inspecting a Saved Plan

Terraform saved plan files are binary.

Do not open them as normal text files.

Use:

`terraform show ec2.plan`

to inspect the saved plan.

---

# 35. Applying a Saved Plan

After reviewing the plan, apply it using:

`terraform apply ec2.plan`

Recommended workflow:

    terraform plan -out=ec2.plan
              ↓
    terraform show ec2.plan
              ↓
           Review
              ↓
    terraform apply ec2.plan

This helps ensure that the reviewed plan is the plan that gets applied.

---

# 36. Terraform Settings

Terraform project-level settings are defined inside:

`terraform {`

`}`

Common settings include:

- `required_version`
- `required_providers`

---

# 37. required_version

Example:

`terraform {`

`  required_version = ">= 1.8"`

`}`

This defines a Terraform version constraint for the project.

It helps make the Terraform environment predictable and compatible with the project configuration.

---

# 38. required_providers

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

# 39. provider Block

The `provider` block configures how the provider is used.

Example:

`provider "aws" {`

`  region = "us-east-1"`

`}`

The provider block can contain configuration such as:

- Region.
- Credentials.
- Alias.

---

# 40. required_providers vs provider

Do not confuse these two concepts.

`required_providers`

Defines:

- Which provider is required.
- Where the provider comes from.
- Which provider versions are acceptable.

`provider`

Defines:

- How the provider is configured.

Example:

`required_providers`:

`source = "hashicorp/aws"`

`version = "~> 5.0"`

Provider configuration:

`provider "aws" {`

`  region = "us-east-1"`

`}`

---

# 41. Version Constraints

Examples:

`>= 1.0`

Means greater than or equal to version `1.0`.

`<= 1.0`

Means less than or equal to version `1.0`.

`~> 2.0`

Allows compatible versions in the `2.x` range.

`>= 2.10, <= 2.30`

Allows versions between `2.10` and `2.30`.

Version constraints help control which Terraform or provider versions can be used.

---

# 42. Resource Targeting

Normally:

`terraform plan`

evaluates the complete Terraform configuration.

Resource Targeting allows Terraform to focus on a specific resource.

Example:

`terraform plan -target=aws_instance.web`

Or:

`terraform apply -target=aws_instance.web`

---

# 43. When Targeting Can Be Useful

Resource Targeting can be useful in exceptional situations such as:

- Troubleshooting.
- State becoming out of sync.
- Network failures.
- Provider problems.
- Upstream cloud platform issues.
- Situations where only a specific part of the infrastructure needs to be addressed.

---

# 44. Resource Targeting Warning

Resource Targeting should not become the normal Terraform workflow.

Avoid using:

`terraform apply -target=...`

simply to avoid reviewing the complete plan.

Terraform is designed to understand the complete configuration and its dependencies.

Use targeting only when there is a specific operational reason.

---

# 45. Large Terraform Configurations

Cloud providers have API limits.

Large Terraform configurations can result in many provider API calls during:

`terraform plan`

and other Terraform operations.

This can potentially lead to API throttling.

---

# 46. Managing Large Infrastructure

Large configurations can sometimes be divided into smaller independently managed Terraform configurations.

Example:

    networking/
    ├── vpc.tf
    └── subnets.tf

    security/
    ├── security-groups.tf
    └── iam.tf

    compute/
    └── instances.tf

The exact architecture depends on the project requirements.

The important idea is to keep infrastructure manageable and avoid unnecessary scale within a single configuration.

---

# 47. Resource Targeting and API Calls

Resource Targeting can reduce the number of provider API calls in certain exceptional situations.

Example:

`terraform plan -target=aws_instance.web`

However, Resource Targeting should not replace proper infrastructure organization.

If a configuration is consistently too large to manage effectively, consider a better infrastructure structure instead of repeatedly relying on `-target`.

---

# 48. Common Mistakes

## Mistake 1 — Incorrect PowerShell Environment Variable Syntax

For PowerShell use:

`$env:TF_LOG="TRACE"`

Not shell syntax from another operating system.

---

## Mistake 2 — Using TRACE Immediately

Do not automatically use:

`TRACE`

for every problem.

Start with the Terraform error message and normal validation.

Use detailed logging when additional information is required.

---

## Mistake 3 — Skipping terraform fmt

Unformatted Terraform code creates unnecessary differences and makes reviews harder.

Use:

`terraform fmt`

---

## Mistake 4 — Skipping terraform validate

Before planning, validate the configuration:

`terraform validate`

---

## Mistake 5 — Duplicate Resources

Remember:

    All .tf files in the same directory
                    ↓
             One configuration

Do not define the same resource address twice.

---

## Mistake 6 — Treating File Names as Execution Order

Terraform does not execute:

`network.tf`

and then:

`compute.tf`

as independent stages.

Dependencies are determined from configuration references.

---

## Mistake 7 — Overusing Dynamic Blocks

Dynamic Blocks should simplify repeated nested configuration.

If they make the code harder to understand, they may not be appropriate.

---

## Mistake 8 — Using terraform taint for Modern Workflows

Prefer:

`terraform apply -replace="RESOURCE_ADDRESS"`

---

## Mistake 9 — Opening Plan Files as Text

Use:

`terraform show ec2.plan`

instead of opening the binary plan file directly.

---

## Mistake 10 — Using -target as Normal Workflow

Do not use:

`terraform apply -target=...`

just because the complete infrastructure is large.

Targeting should be exceptional.

---

# 49. Day 08 Debugging Checklist

When Terraform returns an error:

- [ ] Read the entire error message.
- [ ] Identify the file.
- [ ] Identify the line.
- [ ] Identify the affected resource or variable.
- [ ] Classify the error.
- [ ] Run `terraform fmt`.
- [ ] Run `terraform validate`.
- [ ] Run `terraform plan`.
- [ ] Enable `TF_LOG` if required.
- [ ] Fix the root cause.
- [ ] Validate again.
- [ ] Plan again.

---

# 50. Day 08 Code Quality Checklist

Before committing:

- [ ] Terraform code is formatted.
- [ ] `terraform fmt -check` passes.
- [ ] `terraform validate` passes.
- [ ] No duplicate configuration objects exist.
- [ ] Dynamic Blocks are used only where appropriate.
- [ ] Terraform settings are clearly defined.
- [ ] Provider requirements are controlled.
- [ ] Resource targeting is not being used unnecessarily.
- [ ] Debug logs are not accidentally committed.
- [ ] Saved plan files are reviewed.
- [ ] Sensitive files are excluded from Git.

---

# 51. Git Hygiene

Review generated Terraform files before committing.

Common files and directories that should normally be excluded or carefully reviewed include:

- `.terraform/`
- Terraform state files.
- Terraform backup state files.
- Saved plan files.
- Debug logs.

Never commit sensitive information to a public repository.

Review:

`git status`

before:

`git add .`

---

# 52. Recommended Day 08 Workflow

Use:

`terraform fmt`

Then:

`terraform fmt -check`

Then:

`terraform validate`

Then:

`terraform plan`

Review the plan.

If the plan is correct:

`terraform apply`

After completing the practical work:

`terraform destroy`

---

# 53. Saved Plan Workflow

When a saved plan is required:

`terraform plan -out=ec2.plan`

Then inspect it:

`terraform show ec2.plan`

Review the planned changes.

Then apply:

`terraform apply ec2.plan`

---

# 54. Replacement Workflow

When a specific resource needs to be recreated:

`terraform apply -replace="aws_instance.web"`

Review the plan generated by Terraform before confirming the operation.

Remember that replacement means the existing resource is destroyed and recreated.

---

# 55. Debugging Workflow

A professional debugging process looks like:

    Terraform Error
          ↓
    Read Complete Message
          ↓
    Identify Location
          ↓
    Classify Error
          ↓
    Inspect Configuration
          ↓
    Format
          ↓
    Validate
          ↓
    Plan
          ↓
    Enable Logs if Necessary
          ↓
    Fix Root Cause
          ↓
    Validate Again
          ↓
    Plan Again

---

# 56. Important Commands

## Formatting

`terraform fmt`

`terraform fmt -recursive`

`terraform fmt -check`

`terraform fmt -diff`

## Validation

`terraform validate`

## Debugging

`$env:TF_LOG="DEBUG"`

`$env:TF_LOG="TRACE"`

`$env:TF_LOG_PATH="terraform.log"`

`terraform plan`

`Remove-Item Env:TF_LOG`

## Saved Plans

`terraform plan -out=ec2.plan`

`terraform show ec2.plan`

`terraform apply ec2.plan`

## Replacement

`terraform apply -replace="aws_instance.web"`

## Resource Targeting

`terraform plan -target=aws_instance.web`

`terraform apply -target=aws_instance.web`

---

# 57. Quick Comparison

| Command | Purpose |
|---|---|
| `terraform fmt` | Format Terraform code |
| `terraform fmt -check` | Check formatting without modifying files |
| `terraform fmt -recursive` | Format Terraform files recursively |
| `terraform fmt -diff` | Show formatting differences |
| `terraform validate` | Validate Terraform configuration |
| `terraform plan` | Generate an execution plan |
| `terraform plan -out=FILE` | Save an execution plan |
| `terraform show FILE` | Inspect a saved plan |
| `terraform apply FILE` | Apply a saved plan |
| `terraform apply -replace=RESOURCE` | Force resource replacement |
| `terraform plan -target=RESOURCE` | Target a specific resource |
| `terraform apply -target=RESOURCE` | Apply targeting a specific resource |

---

# 58. Key Concepts to Remember

## Debugging

Find the root cause instead of randomly changing configuration.

## TF_LOG

Use Terraform logging when normal error information is insufficient.

## Troubleshooting

Think in terms of:

    LANGUAGE
    STATE
    CORE
    PROVIDER

## Formatting

Use:

`terraform fmt`

## Validation

Use:

`terraform validate`

## Dynamic Blocks

Use them to generate repeated nested blocks from collections.

## Replacement

Use:

`terraform apply -replace="RESOURCE"`

when a resource needs to be recreated.

## Splat Expressions

Use:

`[*]`

to retrieve attributes from multiple instances, especially resources created with `count`.

## Saved Plans

Use:

`terraform plan -out=FILE`

then:

`terraform show FILE`

and:

`terraform apply FILE`

## Terraform Settings

Understand:

- `required_version`
- `required_providers`
- `provider`

## Resource Targeting

Use `-target` only for exceptional situations.

---

# 59. Day 08 Memory Model

Remember Day 08 as:

    FORMAT
       ↓
    VALIDATE
       ↓
    PLAN
       ↓
    REVIEW
       ↓
    APPLY

For troubleshooting:

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

For Dynamic Blocks:

    COLLECTION
        ↓
    for_each
        ↓
    dynamic
        ↓
    content
        ↓
    GENERATED NESTED BLOCKS

For Saved Plans:

    PLAN
     ↓
    SAVE
     ↓
    SHOW
     ↓
    REVIEW
     ↓
    APPLY

For Resource Replacement:

    -replace
       ↓
    DESTROY
       ↓
    CREATE

---

# 60. Final Takeaways

Day 08 is primarily about improving Terraform code quality and developing a systematic troubleshooting approach.

The most important skills are:

- Reading Terraform errors correctly.
- Classifying Terraform problems.
- Using `TF_LOG`.
- Formatting Terraform code.
- Validating Terraform configuration.
- Understanding Terraform file loading.
- Avoiding duplicate configuration objects.
- Using Dynamic Blocks appropriately.
- Forcing resource replacement with `-replace`.
- Using Splat Expressions.
- Saving and inspecting Terraform plans.
- Understanding Terraform settings.
- Understanding Resource Targeting.
- Recognizing the operational impact of large Terraform configurations.

The goal is not to memorize every command.

The goal is to know:

    What is wrong?
          ↓
    Where is it wrong?
          ↓
    What type of problem is it?
          ↓
    Which Terraform tool should I use?
          ↓
    How do I verify the fix?

This is the Terraform troubleshooting mindset that should be developed through Day 08.