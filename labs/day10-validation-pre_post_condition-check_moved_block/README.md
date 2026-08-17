# Terraform Day 10 — Validation, Preconditions, Postconditions, Check Blocks & Moved Blocks


## Overview

This project focuses on Terraform validation and configuration safety.

The main practical objective is to add **Input Variable Validation** to an existing Terraform configuration so invalid values are rejected before Terraform attempts to provision infrastructure.

The project also covers the related validation mechanisms studied in this learning session:

- Input Variable Validation
- Preconditions
- Postconditions
- Check Blocks
- Moved Blocks

The README documents the project implementation and scope only. Detailed study notes, explanations, syntax breakdowns, and troubleshooting are kept separately in `NOTES.md`.

---

## Learning Objectives

By completing this project, the following concepts are covered:

- Validate Terraform input variables with custom rules.
- Prevent unsupported configuration values from reaching resources.
- Define clear validation requirements for infrastructure inputs.
- Understand where validation occurs in the Terraform workflow.
- Understand the purpose of Preconditions and Postconditions.
- Understand the purpose of Check Blocks.
- Understand how Moved Blocks support resource refactoring.
- Apply validation to an existing Terraform configuration.

---

## Project Scope

This project is intentionally limited to the Day 10 learning scope.

### Implemented

- Input Variable Validation

### Studied

- Preconditions
- Postconditions
- Check Blocks
- Moved Blocks

The practical implementation of this project focuses on **Input Variable Validation**, while the remaining topics were covered as part of the Day 10 course material.

---

## Course Progress

The following Day 10 lectures were completed:

| Lecture | Topic | Status |
|---|---|---|
| 100 | Overview of Input Variable Validation | Completed |
| 101 | Practical - Input Variable Validation | Completed |
| 102 | Overview of Preconditions and Postconditions | Completed |
| 103 | Check Blocks | Completed |
| 104 | Moved Blocks | Completed |
| Quiz 2 | Practice Test | Completed |

---

## Project Structure

```text
day10-validation/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── terraform.tfvars
└── README.md
```

The exact files may vary depending on the final Terraform configuration.

---

## Input Variable Validation

Terraform input variables can include validation rules that restrict which values are accepted.

Example:

```hcl
variable "instance_type" {
  type = string

  validation {
    condition = contains(
      ["t2.micro", "t3.micro"],
      var.instance_type
    )

    error_message = "The instance_type must be t2.micro or t3.micro."
  }
}
```

With this configuration, Terraform accepts only the values defined by the validation condition.

An unsupported value causes Terraform to report a validation error instead of continuing with an invalid configuration.

---

## Validation Components

The practical validation implementation consists of three main parts:

```text
variable
   │
   └── validation
         │
         ├── condition
         │
         └── error_message
```

The validation condition determines whether the supplied value is acceptable.

The error message communicates what is expected when the condition is not satisfied.

---

## Example Validation Flow

```text
Input Variable
      │
      ▼
Validation Rule
      │
      ├── Valid ──────► Terraform continues
      │
      └── Invalid ────► Validation error
```

This allows configuration errors to be detected before infrastructure deployment.

---

## Practical Validation Example

A common use case is restricting an EC2 instance type to an approved set.

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string

  validation {
    condition = contains(
      ["t2.micro", "t3.micro"],
      var.instance_type
    )

    error_message = "Only approved EC2 instance types are allowed."
  }
}
```

The value can then be provided through the normal Terraform variable mechanisms.

Example:

```hcl
instance_type = "t3.micro"
```

---

## Invalid Input

If an unsupported value is supplied:

```hcl
instance_type = "invalid-type"
```

Terraform should reject the value during validation rather than continuing with the deployment.

This creates an explicit boundary around accepted infrastructure configuration.

---

## Preconditions and Postconditions

The Day 10 study also introduced Terraform Preconditions and Postconditions.

These provide validation associated with Terraform objects rather than only validating raw input variables.

### Preconditions

A precondition evaluates a requirement before the associated object is evaluated.

Conceptually:

```text
Precondition
     │
     ▼
Resource Evaluation
```

### Postconditions

A postcondition evaluates a requirement after the associated object has been evaluated.

Conceptually:

```text
Resource Evaluation
     │
     ▼
Postcondition
```

These mechanisms were covered during the Day 10 learning session but are not required for the primary implementation of this project.

---

## Check Blocks

Check Blocks were also covered as part of Day 10.

They are designed for assertions that can evaluate infrastructure conditions without making the assertion failure behave like a normal resource precondition or postcondition failure.

Conceptually:

```text
Infrastructure
      │
      ▼
Check Block
      │
      ▼
Assertion
```

Check Blocks are part of the Day 10 knowledge scope but are not required for the primary project implementation.

---

## Moved Blocks

Moved Blocks were covered as part of the Day 10 learning material.

They are relevant when Terraform resource addresses change during configuration refactoring.

Conceptually:

```text
Old Terraform Address
        │
        ▼
    moved block
        │
        ▼
New Terraform Address
```

A Moved Block allows Terraform to understand that an existing managed object has moved from one Terraform address to another.

This topic is included in the Day 10 learning scope but is not required for the main validation implementation.

---

## Terraform Workflow

Initialize the project:

```powershell
terraform init
```

Format the configuration:

```powershell
terraform fmt
```

Validate the configuration:

```powershell
terraform validate
```

Create a plan:

```powershell
terraform plan
```

Apply the configuration:

```powershell
terraform apply
```

---

## Validation Testing

The validation rule should be tested with both valid and invalid input.

### Valid Input

Example:

```hcl
instance_type = "t3.micro"
```

Expected result:

```text
Validation passes
        ↓
Terraform continues
```

### Invalid Input

Example:

```hcl
instance_type = "invalid-type"
```

Expected result:

```text
Validation fails
        ↓
Terraform reports an error
```

Testing both cases confirms that the validation rule behaves as intended.

---

## Verification

After making configuration changes, run:

```powershell
terraform fmt
```

Then:

```powershell
terraform validate
```

Finally:

```powershell
terraform plan
```

The plan should only proceed when the supplied variable values satisfy the defined validation rules.

---

## Project Outcome

This project adds a validation layer to Terraform configuration so that infrastructure inputs are checked before deployment.

The result is a configuration that:

- Accepts approved values.
- Rejects invalid values.
- Provides a meaningful validation error.
- Reduces configuration mistakes.
- Makes infrastructure requirements explicit.

---

## Best Practices Applied

- Avoid accepting unrestricted values when the infrastructure has known requirements.
- Keep validation rules close to the variable they validate.
- Use clear and actionable validation error messages.
- Test both valid and invalid inputs.
- Run `terraform fmt` before committing changes.
- Run `terraform validate` before planning or applying.
- Review `terraform plan` before making infrastructure changes.
- Keep detailed explanations and troubleshooting separate from the project README.

---

## Key Takeaway

Terraform Input Variable Validation provides an early safety check for infrastructure configuration.

Instead of allowing an invalid value to continue through the deployment process:

```text
Invalid Input
     │
     ▼
Validation
     │
     ▼
Error
```

Valid configuration follows the normal Terraform workflow:

```text
Valid Input
     │
     ▼
Validation
     │
     ▼
Terraform Plan
     │
     ▼
Terraform Apply
```

This project demonstrates the practical use of validation while the Day 10 study also introduced Preconditions, Postconditions, Check Blocks, and Moved Blocks as additional Terraform validation and configuration-safety mechanisms.

---

## Cleanup

If AWS resources were created during the practical exercise and are no longer required:

```powershell
terraform destroy
```

Verify that unnecessary resources have been removed after completing the lab.

---

## Day 10 Status

- [x] Input Variable Validation — Completed
- [x] Practical Validation Exercise — Completed
- [x] Preconditions and Postconditions — Studied
- [x] Check Blocks — Studied
- [x] Moved Blocks — Studied
- [x] Quiz 2 — Completed
- [x] README Documentation — Completed