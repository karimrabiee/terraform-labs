# Terraform Day 10 — Validation, Preconditions, Postconditions, Check Blocks & Moved Blocks

## Overview

Quick reference for **Day 10 only**.

Covered:

* Input Variable Validation
* Preconditions
* Postconditions
* Check Blocks
* Moved Blocks

---

# 1. Input Variable Validation

Input variable validation allows Terraform to reject invalid values before continuing with the plan/apply process.

### Basic Syntax

```hcl
variable "instance_type" {
  type = string

  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.instance_type)
    error_message = "Instance type must be t2.micro or t3.micro."
  }
}
```

### Important

`condition` must evaluate to:

```text
true  → Valid
false → Validation error
```

---

## Common Problems

### Problem: Invalid Condition

Wrong:

```hcl
condition = var.instance_type
```

The condition must evaluate to a boolean.

Correct:

```hcl
condition = contains(["t2.micro", "t3.micro"], var.instance_type)
```

---

### Problem: Wrong Variable Type

If:

```hcl
variable "port" {
  type = number
}
```

Do not pass:

```hcl
port = "8080"
```

Prefer:

```hcl
port = 8080
```

---

### Problem: Validation Doesn't Match Requirement

Bad:

```hcl
condition = var.environment != ""
```

This only checks that the value is not empty.

If only specific environments are allowed:

```hcl
condition = contains(["dev", "staging", "prod"], var.environment)
```

---

# 2. Validation vs Preconditions

### Variable Validation

Validates an **input variable**.

```text
Input Variable
      ↓
Validation
      ↓
Valid / Invalid
```

### Preconditions

Validate assumptions before a resource or data source operation.

```text
Resource / Data Source
        ↓
   Precondition
        ↓
   Valid / Invalid
```

### Rule

```text
Variable validation
    → Is the input value valid?

Precondition
    → Is this condition required before using the resource?
```

---

# 3. Preconditions

A precondition verifies that something must be true before Terraform proceeds with the resource operation.

Example:

```hcl
resource "aws_instance" "web" {
  instance_type = var.instance_type

  lifecycle {
    precondition {
      condition     = var.environment != "production" || var.instance_type != "t2.micro"
      error_message = "t2.micro cannot be used in production."
    }
  }
}
```

### Common Problems

* Incorrect expression.
* Referencing the wrong variable.
* Writing a condition that does not represent the real requirement.
* Using validation when a resource-level precondition is more appropriate.

---

# 4. Postconditions

A postcondition verifies the resulting resource state after Terraform performs the operation.

Example:

```hcl
resource "aws_instance" "web" {
  instance_type = var.instance_type

  lifecycle {
    postcondition {
      condition     = self.instance_type != ""
      error_message = "Instance type must be available after creation."
    }
  }
}
```

### Mental Model

```text
Precondition
    ↓
Before operation

Resource Operation
    ↓
Postcondition
    ↓
After operation
```

---

## Common Problems

### Confusing Precondition and Postcondition

Use:

```text
Precondition → Before
Postcondition → After
```

Do not use a postcondition to validate an input that should have been checked before resource creation.

---

# 5. `self` in Preconditions/Postconditions

For resource lifecycle conditions, `self` refers to the resource being evaluated.

Example:

```hcl
postcondition {
  condition     = self.instance_type != ""
  error_message = "Invalid instance type."
}
```

### Common Mistake

Referencing an attribute that does not exist on the resource.

Always verify the resource schema.

---

# 6. Check Blocks

A `check` block performs additional validation during Terraform operations.

Example:

```hcl
check "example" {
  assert {
    condition     = var.environment != "invalid"
    error_message = "Invalid environment."
  }
}
```

### Purpose

Check blocks are useful for validating assumptions without being tied directly to a single resource.

---

# 7. Check Block vs Validation

### Variable Validation

```text
Specific input
     ↓
Must be valid
```

### Check Block

```text
Broader infrastructure assumption
           ↓
        Check
```

### Important Difference

Variable validation is designed to reject invalid variable input.

Check blocks are useful for verifying broader conditions and assumptions.

---

## Common Check Block Problems

### Problem: Incorrect `assert`

Wrong:

```hcl
assert {
  condition = "true"
}
```

`condition` should evaluate to a boolean expression.

Correct:

```hcl
assert {
  condition = var.environment == "production"
}
```

---

### Problem: Check Fails

Terraform may report a failed check when the condition evaluates to `false`.

Check:

1. The expression.
2. Variable values.
3. Resource attributes.
4. External conditions used by the check.

---

# 8. Moved Blocks

A `moved` block tells Terraform that a resource has been renamed or moved to another address.

Example:

```hcl
moved {
  from = aws_instance.web
  to   = aws_instance.application
}
```

Terraform can then understand that:

```text
Old Address
    ↓
aws_instance.web
    ↓
New Address
    ↓
aws_instance.application
```

without treating the change as a completely new resource.

---

# 9. Why `moved` Blocks Are Important

Without a moved block, Terraform may interpret a resource rename as:

```text
Destroy old resource
        +
Create new resource
```

With a correct moved block:

```text
Old Address
     ↓
Move State Address
     ↓
New Address
```

This helps avoid unnecessary resource destruction and recreation.

---

# 10. Moved Block Error — "Moved Object Still Exists"

A common error is:

```text
Error: Moved object still exists
```

This usually means Terraform detects that the old address still exists while a `moved` declaration is also trying to move it.

### Check

```bash
terraform state list
```

Then inspect the resource:

```bash
terraform state show aws_instance.web
```

Make sure the state and configuration agree with the intended move.

---

# 11. Moved Block Common Mistakes

### Wrong Address

Wrong:

```hcl
moved {
  from = aws_instance.old
  to   = aws_instance.new
}
```

if the actual resource address is different.

Always use the exact Terraform address.

---

### Resource Still Defined Under Old Address

If the configuration still declares the old resource while also declaring the moved block incorrectly, Terraform can report conflicts.

Review:

* Resource blocks
* `moved` blocks
* Terraform state

---

### Removing `moved` Too Early

Do not immediately remove a moved block before confirming that the state has been migrated correctly.

Verify:

```bash
terraform plan
```

and:

```bash
terraform state list
```

---

# 12. `count` and `for_each` Address Changes

Resource addresses become more complex when `count` or `for_each` is involved.

Example:

```text
aws_instance.web[0]
aws_instance.web[1]
```

or:

```text
aws_instance.web["app"]
```

The moved block must use the exact address.

Example:

```hcl
moved {
  from = aws_instance.web[0]
  to   = aws_instance.app[0]
}
```

### Common Mistake

Forgetting the index or key.

Wrong:

```text
aws_instance.web
```

Correct:

```text
aws_instance.web[0]
```

when the resource actually uses `count`.

---

# 13. Day 10 Error Checklist

```text
[ ] Check variable type
[ ] Check validation condition
[ ] Check validation error_message
[ ] Check precondition expression
[ ] Check postcondition expression
[ ] Verify self references
[ ] Check assert condition
[ ] Verify check block assumptions
[ ] Check exact moved.from address
[ ] Check exact moved.to address
[ ] Run terraform state list
[ ] Run terraform plan
[ ] Verify no unexpected destroy/create
```

---

# 14. Recommended Troubleshooting Workflow

When something fails:

```text
terraform fmt
      ↓
terraform validate
      ↓
terraform plan
      ↓
Read the exact error
      ↓
Check configuration
      ↓
Check variable values
      ↓
Check Terraform state
      ↓
terraform state list
      ↓
terraform plan again
```

For moved blocks, additionally inspect:

```bash
terraform state show <resource-address>
```

---

# 15. Quick Comparison

| Feature             | Main Purpose                                |
| ------------------- | ------------------------------------------- |
| Variable Validation | Validate input values                       |
| Precondition        | Validate assumptions before operation       |
| Postcondition       | Validate resulting resource state           |
| Check Block         | Validate broader infrastructure assumptions |
| Moved Block         | Safely change Terraform resource addresses  |

---

# 16. Key Rules

```text
Variable Validation
→ Validate inputs

Precondition
→ Validate before resource operation

Postcondition
→ Validate resulting state

Check Block
→ Validate broader assumptions

Moved Block
→ Tell Terraform that an address changed
```

---

# 17. Professional Best Practices

* Keep validation conditions simple and readable.
* Use meaningful `error_message` values.
* Validate inputs as early as possible.
* Use preconditions for resource-specific assumptions.
* Use postconditions to verify important resulting state.
* Use check blocks for broader infrastructure assumptions.
* Use exact Terraform addresses in `moved` blocks.
* Always review `terraform plan` after state/address changes.
* Never assume a rename is harmless without checking the plan.
* Avoid unnecessary resource destruction and recreation.
* Do not manually modify state unless you understand the consequences.

---

# 18. Day 10 Scope

This file covers only:

```text
100. Overview of Input Variable Validation
101. Practical - Input Variable Validation
102. Overview of Preconditions and Postconditions
103. Check Blocks
104. Moved Blocks
Quiz 2: Practice Test
```

No topics from Day 11 or other Terraform course days are included.
