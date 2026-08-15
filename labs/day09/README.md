# Terraform Day 09 — Meta-Arguments, Dependencies & for_each

## Overview

This project focuses on Terraform Meta-Arguments, resource lifecycle behavior, resource dependencies, `count`, `for_each`, Sets, and Objects.

The main objective of Day 09 is to understand how Terraform controls resource behavior and relationships, and why `for_each` is often preferred over `count` when resources require distinct values.

The practical challenge for this day is to create multiple EC2 instances using `for_each` instead of `count`.

> This project is intentionally limited to Day 09 topics.

---

## Learning Objectives

By completing this lab, you should understand how to:

- Understand Terraform Resource Behavior and Meta-Arguments.
- Use the `lifecycle` meta-argument.
- Understand `create_before_destroy`.
- Understand `prevent_destroy`.
- Understand `ignore_changes`.
- Understand `replace_triggered_by`.
- Understand the limitations and challenges of using `count`.
- Understand resource addressing when using `count`.
- Understand implicit resource dependencies.
- Define explicit dependencies using `depends_on`.
- Understand the difference between implicit and explicit dependencies.
- Understand Terraform Set data types.
- Understand Terraform Object data types.
- Use `for_each` to create multiple resource instances.
- Understand why `for_each` is often more suitable than `count` for resources with distinct values.
- Understand how `for_each` resource instances are addressed.
- Complete the Day 09 challenge by creating three EC2 instances with `for_each`.

---

## Day 09 Topics

| Topic | Purpose |
|---|---|
| Meta-Arguments | Control resource behavior |
| Lifecycle | Control resource replacement and change behavior |
| `create_before_destroy` | Create replacement resources before destroying the old resource |
| `prevent_destroy` | Protect resources from planned destruction |
| `ignore_changes` | Ignore selected changes made outside Terraform |
| `replace_triggered_by` | Trigger replacement when referenced objects change |
| `count` | Create multiple similar resource instances |
| Count Challenges | Understand index-based resource addressing |
| Resource Dependencies | Control relationships between resources |
| Implicit Dependencies | Automatically created through resource references |
| Explicit Dependencies | Defined using `depends_on` |
| Set Data Type | Store unique unordered values |
| Object Data Type | Represent structured values |
| `for_each` | Create resources from collections using stable keys |

---

## Project Structure

The Day 09 project follows a simple Terraform structure:

    day09/
    ├── README.md
    ├── NOTES.md
    ├── main.tf
    ├── variables.tf
    ├── terraform.tfvars
    ├── outputs.tf
    ├── terraform.tf
    └── .gitignore

File purposes:

- `README.md` — Project documentation and learning overview.
- `NOTES.md` — Technical notes, important concepts, examples, and troubleshooting points.
- `main.tf` — Main Terraform resources and configuration.
- `variables.tf` — Input variable definitions.
- `terraform.tfvars` — Variable values used by the lab.
- `outputs.tf` — Terraform output definitions.
- `terraform.tf` — Terraform settings and provider requirements.
- `.gitignore` — Prevents Terraform-generated or sensitive files from being committed.

---

# 1. Terraform Meta-Arguments

Meta-Arguments are special arguments that change how Terraform manages resources.

They are not provider-specific resource arguments.

Common Meta-Arguments include:

- `count`
- `for_each`
- `depends_on`
- `lifecycle`

Day 09 focuses mainly on:

- Resource lifecycle behavior.
- Resource dependencies.
- `count`.
- `for_each`.

---

## Why Meta-Arguments Matter

Meta-Arguments allow Terraform to control how resources are:

- Created.
- Updated.
- Replaced.
- Destroyed.
- Connected through dependencies.
- Managed as multiple instances.

Understanding Meta-Arguments is important for writing reusable and predictable Terraform configurations.

---

# 2. Lifecycle Meta-Argument

The `lifecycle` block allows you to customize how Terraform manages the lifecycle of a resource.

Example structure:

    lifecycle {
      ...
    }

Important lifecycle arguments covered in Day 09 include:

- `create_before_destroy`
- `prevent_destroy`
- `ignore_changes`
- `replace_triggered_by`

---

# 3. create_before_destroy

By default, when Terraform must replace a resource, it generally destroys the existing resource and then creates the replacement.

Conceptually:

    Existing Resource
          ↓
        Destroy
          ↓
         Create

The `create_before_destroy` argument changes this behavior.

Example:

    lifecycle {
      create_before_destroy = true
    }

With this setting, Terraform attempts to create the replacement resource first.

Conceptually:

    Existing Resource
          ↓
      Create New
          ↓
      Destroy Old

---

## Why Use create_before_destroy?

`create_before_destroy` can reduce downtime when a replacement resource can safely coexist with the existing resource.

For example, when changing an attribute that requires replacement, Terraform can create the new resource before removing the old one.

---

## Important Consideration

The old and new resources must be able to exist at the same time.

If the infrastructure platform does not allow both resources to coexist because of naming or uniqueness constraints, `create_before_destroy` may not be appropriate.

---

# 4. prevent_destroy

The `prevent_destroy` argument can protect a resource from accidental destruction.

Example:

    lifecycle {
      prevent_destroy = true
    }

When enabled, Terraform rejects a plan that would destroy the associated infrastructure object while the setting remains present in the configuration.

---

## Why Use prevent_destroy?

It can be useful for resources that are costly or difficult to recreate.

Examples may include:

- Databases.
- Important storage resources.
- Critical infrastructure.

The purpose is to provide an additional safety mechanism against accidental destruction.

---

## Important Limitation

`prevent_destroy` does not mean the remote object can never be destroyed.

The protection depends on the lifecycle configuration remaining in the Terraform configuration.

If the resource block is removed entirely from configuration, the `prevent_destroy` setting is no longer present to protect it.

Therefore, `prevent_destroy` should be treated as a Terraform configuration safety mechanism rather than a permanent cloud-side protection mechanism.

---

# 5. ignore_changes

Terraform normally attempts to make the real infrastructure match the Terraform configuration.

If a remote resource is changed outside Terraform, Terraform may detect the difference and attempt to change it back.

`ignore_changes` can be used when specific remote changes should not be managed by Terraform.

Example:

    lifecycle {
      ignore_changes = [
        tags
      ]
    }

This tells Terraform to ignore changes to the specified attribute.

---

## Example Scenario

Terraform creates a resource with:

    tags = {
      Name = "web-server"
    }

An external process later modifies the tags.

Without `ignore_changes`, Terraform may attempt to restore the configuration.

With:

    lifecycle {
      ignore_changes = [
        tags
      ]
    }

Terraform ignores changes to that attribute.

---

## ignore_changes = all

The special keyword `all` can be used:

    lifecycle {
      ignore_changes = all
    }

This instructs Terraform to ignore all attribute changes for updates.

Terraform can still create and destroy the resource, but it will not propose updates to the resource attributes.

Use this carefully because it significantly reduces Terraform's control over configuration drift.

---

# 6. replace_triggered_by

`replace_triggered_by` can cause a resource to be replaced when a referenced resource or item changes.

Conceptually:

    Resource A Changes
          ↓
    Trigger Replacement
          ↓
    Resource B Replaced

This is useful when the lifecycle of one resource should be tied to changes in another resource.

The key idea is:

> A change in the referenced object can trigger replacement of the resource containing the lifecycle rule.

---

# 7. Lifecycle Summary

| Argument | Purpose |
|---|---|
| `create_before_destroy` | Create replacement before destroying the old resource |
| `prevent_destroy` | Reject plans that would destroy the protected resource |
| `ignore_changes` | Ignore selected external changes |
| `replace_triggered_by` | Trigger replacement when referenced items change |

---

# 8. count Meta-Argument

The `count` meta-argument allows Terraform to create multiple instances of a resource.

Example:

    resource "aws_iam_user" "iam" {
      count = 3

      name = "user-${count.index}"
    }

Terraform creates three instances.

The resource addresses are:

    aws_iam_user.iam[0]
    aws_iam_user.iam[1]
    aws_iam_user.iam[2]

---

# 9. Resource Addressing with count

Resources created using `count` are identified by numeric indexes.

For example:

    aws_iam_user.iam[0]

    aws_iam_user.iam[1]

    aws_iam_user.iam[2]

The index represents the position of the instance.

---

# 10. Challenge with count

One of the main challenges with `count` is index-based addressing.

Suppose Terraform manages:

    aws_iam_user.iam[0] → user-01
    aws_iam_user.iam[1] → user-02
    aws_iam_user.iam[2] → user-03

If the order of the input collection changes, the indexes can change.

This can cause Terraform to associate existing infrastructure with different indexes.

---

## Example

Original:

    0 → user-01
    1 → user-02
    2 → user-03

After changing the order:

    0 → user-03
    1 → user-01
    2 → user-02

Terraform sees the resources through their indexes.

This can result in unnecessary changes when the resources have distinct identities.

---

# 11. When count Is Appropriate

`count` is appropriate when resources are almost identical.

Example:

    count = 3

where each instance uses the same basic configuration and the index is sufficient to distinguish them.

If resources require distinctive values, `for_each` is often a better choice.

---

# 12. count vs for_each

The key difference is how Terraform identifies the resource instances.

With `count`:

    aws_instance.web[0]
    aws_instance.web[1]
    aws_instance.web[2]

With `for_each`:

    aws_instance.web["web-01"]
    aws_instance.web["web-02"]
    aws_instance.web["web-03"]

`count` uses indexes.

`for_each` uses keys.

This makes `for_each` more suitable when each resource has a meaningful identity.

---

# 13. Resource Dependencies

Terraform resources can depend on other resources.

Dependencies determine the order in which Terraform performs operations.

For example:

    Security Group
          ↓
       EC2 Instance

The EC2 instance needs the Security Group to exist before it can use it.

Terraform needs to understand this relationship to create the resources in the correct order.

---

# 14. Implicit Dependencies

An implicit dependency is automatically created when one resource references another resource.

Example:

    resource "aws_security_group" "web" {
      ...
    }

    resource "aws_instance" "web" {
      vpc_security_group_ids = [
        aws_security_group.web.id
      ]
    }

The EC2 instance references:

    aws_security_group.web.id

Terraform automatically understands that the Security Group must exist before the EC2 instance can use it.

This is an implicit dependency.

---

# 15. Why Implicit Dependencies Are Preferred

Terraform can automatically build the dependency graph when resource references clearly express the relationship.

For example:

    aws_instance.web
          ↓
    aws_security_group.web.id

The reference itself tells Terraform the dependency.

This is generally clearer than manually defining dependencies when Terraform can already determine them.

---

# 16. Explicit Dependencies

Sometimes a dependency exists but there is no direct attribute reference between the resources.

In this situation, use:

    depends_on

Example:

    resource "aws_instance" "example" {
      depends_on = [
        aws_s3_bucket.example
      ]

      ...
    }

This explicitly tells Terraform that the EC2 instance depends on the S3 bucket.

---

# 17. depends_on

The `depends_on` meta-argument instructs Terraform to complete actions on the dependency before performing actions on the resource declaring the dependency.

Example:

    resource "aws_instance" "example" {
      depends_on = [
        aws_s3_bucket.example
      ]
    }

Terraform creates:

    S3 Bucket
        ↓
    EC2 Instance

When destroying the infrastructure, Terraform reverses the dependency order:

    EC2 Instance
        ↓
    S3 Bucket

This helps prevent dependency relationships from being broken during deletion.

---

# 18. Implicit vs Explicit Dependencies

| Dependency | How It Is Defined | Example |
|---|---|---|
| Implicit | Resource attribute reference | `aws_security_group.web.id` |
| Explicit | `depends_on` | `depends_on = [aws_s3_bucket.example]` |

### Implicit Dependency

Terraform can detect the dependency automatically.

Example:

    vpc_security_group_ids = [
      aws_security_group.web.id
    ]

### Explicit Dependency

Terraform cannot determine the dependency from a direct reference, so it is declared manually.

Example:

    depends_on = [
      aws_s3_bucket.example
    ]

---

# 19. Dependency Best Practice

Prefer implicit dependencies when the relationship can be expressed through a resource reference.

Use `depends_on` when there is a real dependency that Terraform cannot infer automatically.

Do not add `depends_on` everywhere.

Unnecessary explicit dependencies can make the Terraform dependency graph more complicated than required.

---

# 20. Set Data Type

A Set is a Terraform collection type that stores unique values.

Unlike a List:

- Sets do not preserve ordering.
- Duplicate values are removed.
- Elements must be of a defined type.

Example:

    variable "users" {
      type = set(string)
    }

Example values:

    users = [
      "alice",
      "bob",
      "alice"
    ]

The duplicate `"alice"` is removed.

The Set contains unique values.

---

# 21. List vs Set

A List:

- Preserves order.
- Allows duplicates.
- Uses indexes.

Example:

    [
      "alice",
      "bob",
      "alice"
    ]

A Set:

- Does not preserve order.
- Does not allow duplicate values.
- Represents membership rather than position.

Example:

    set(string)

---

# 22. Why Sets Matter for for_each

`for_each` works naturally with collections where each element can provide a stable identity.

A Set of strings can be used with `for_each`.

Example:

    variable "users" {
      type = set(string)
    }

Then:

    resource "aws_iam_user" "users" {
      for_each = var.users

      name = each.value
    }

Terraform creates one resource for each unique Set value.

---

# 23. Object Data Type

An Object represents a structured value containing multiple named attributes.

Example:

    object({
      name = string
      size = number
    })

A value can contain:

    {
      name = "web"
      size = 20
    }

Objects are useful when each item needs multiple related attributes.

---

# 24. Object Example

A variable can contain structured information:

    variable "instances" {
      type = map(object({
        instance_type = string
        environment   = string
      }))
    }

Example:

    instances = {
      web-01 = {
        instance_type = "t3.micro"
        environment   = "development"
      }

      web-02 = {
        instance_type = "t3.small"
        environment   = "production"
      }
    }

This structure works especially well with `for_each`.

---

# 25. for_each Meta-Argument

`for_each` creates one resource instance for each element in a collection.

It can work with:

- Sets.
- Maps.

The major advantage is that each resource instance has a stable key.

Example:

    resource "aws_iam_user" "users" {
      for_each = var.users

      name = each.value
    }

---

# 26. each.key and each.value

When using `for_each`, Terraform provides:

    each.key

and:

    each.value

For a Set:

    each.key
    each.value

represent the current set element.

For a Map:

    each.key

represents the map key.

    each.value

represents the corresponding map value.

---

# 27. for_each with a Set

Example:

    variable "users" {
      type = set(string)
    }

Values:

    users = [
      "user-01",
      "user-02",
      "user-03"
    ]

Resource:

    resource "aws_iam_user" "users" {
      for_each = var.users

      name = each.value
    }

Terraform creates:

    aws_iam_user.users["user-01"]
    aws_iam_user.users["user-02"]
    aws_iam_user.users["user-03"]

---

# 28. for_each with a Map

Example:

    variable "instances" {
      type = map(object({
        instance_type = string
      }))
    }

Values:

    instances = {
      web-01 = {
        instance_type = "t3.micro"
      }

      web-02 = {
        instance_type = "t3.small"
      }

      web-03 = {
        instance_type = "t3.micro"
      }
    }

Resource:

    resource "aws_instance" "web" {
      for_each = var.instances

      instance_type = each.value.instance_type
    }

The resource addresses become:

    aws_instance.web["web-01"]
    aws_instance.web["web-02"]
    aws_instance.web["web-03"]

---

# 29. Why for_each Is Important

`for_each` is commonly used when resources have distinct values.

Instead of thinking:

    Instance 0
    Instance 1
    Instance 2

you can define meaningful identities:

    web-01
    web-02
    web-03

This makes the Terraform configuration easier to understand and can reduce the index-related problems associated with `count`.

---

# 30. count vs for_each Example

Using `count`:

    resource "aws_instance" "web" {
      count = 3

      instance_type = "t3.micro"
    }

Addresses:

    aws_instance.web[0]
    aws_instance.web[1]
    aws_instance.web[2]

Using `for_each`:

    resource "aws_instance" "web" {
      for_each = {
        web-01 = "t3.micro"
        web-02 = "t3.small"
        web-03 = "t3.micro"
      }

      instance_type = each.value
    }

Addresses:

    aws_instance.web["web-01"]
    aws_instance.web["web-02"]
    aws_instance.web["web-03"]

The second approach allows each resource to have a meaningful key and potentially a different value.

---

# 31. Day 09 Practical Challenge

The main practical challenge is:

> Create three EC2 instances using `for_each` instead of `count`.

The objective is to demonstrate that you understand how to replace index-based resource creation with key-based resource creation.

Instead of:

    count = 3

use a suitable collection with:

    for_each = ...

---

# 32. Recommended Challenge Structure

A suitable structure is a map of objects:

    instances = {
      web-01 = {
        instance_type = "t3.micro"
      }

      web-02 = {
        instance_type = "t3.micro"
      }

      web-03 = {
        instance_type = "t3.micro"
      }
    }

Then:

    resource "aws_instance" "web" {
      for_each = var.instances

      instance_type = each.value.instance_type

      ...
    }

The important part is the use of:

    each.key

and:

    each.value

---

# 33. Challenge Resource Addresses

After using `for_each`, the resources should be addressed using keys rather than numeric indexes.

Example:

    aws_instance.web["web-01"]

    aws_instance.web["web-02"]

    aws_instance.web["web-03"]

This is the main difference from:

    aws_instance.web[0]

    aws_instance.web[1]

    aws_instance.web[2]

---

# 34. Why This Challenge Matters

The Day 09 challenge is important because `for_each` is a common Terraform pattern for managing resources with distinct identities or configuration values.

The goal is not simply to create three EC2 instances.

The goal is to understand:

- Collection-based resource creation.
- Stable resource keys.
- `each.key`.
- `each.value`.
- The limitations of index-based `count`.
- When to choose `for_each`.

---

# 35. Recommended Day 09 Workflow

Initialize the project:

    terraform init

Format the configuration:

    terraform fmt

Validate the configuration:

    terraform validate

Create the plan:

    terraform plan

Review the resources Terraform intends to create.

Apply the configuration:

    terraform apply

Verify the resulting resources.

After completing the practical lab:

    terraform destroy

---

# 36. Verification

After applying the configuration, verify the resource addresses.

For `for_each`, the expected pattern is:

    aws_instance.web["web-01"]
    aws_instance.web["web-02"]
    aws_instance.web["web-03"]

Use Terraform state inspection when required:

    terraform state list

This helps confirm how Terraform is tracking the instances.

---

# 37. Day 09 Best Practices

### Meta-Arguments

- Understand the purpose of each Meta-Argument.
- Use lifecycle rules only when they solve a real infrastructure requirement.
- Avoid unnecessary lifecycle customization.

### Lifecycle

- Use `create_before_destroy` when replacement order matters.
- Use `prevent_destroy` for resources that require additional protection.
- Use `ignore_changes` only when external changes are intentionally outside Terraform's control.
- Understand the consequences of `ignore_changes = all`.

### Dependencies

- Prefer implicit dependencies through resource references.
- Use `depends_on` only when Terraform cannot infer the dependency.
- Avoid unnecessary explicit dependencies.

### count

- Use `count` when resources are nearly identical.
- Understand index-based resource addressing.
- Be careful when the order of input elements can change.

### for_each

- Prefer `for_each` when resources have distinct identities or values.
- Use meaningful keys.
- Understand `each.key` and `each.value`.
- Use Sets or Maps appropriately.

### Collections

- Use Lists when ordering and duplicates matter.
- Use Sets when uniqueness matters and ordering does not.
- Use Objects when multiple related attributes need to be represented together.

---

# 38. Common Mistakes

## Mistake 1 — Using count for Distinct Resources

If every instance has a different identity or configuration, using `count` can introduce unnecessary index-related complexity.

Consider:

    for_each

instead.

---

## Mistake 2 — Forgetting each.value

With:

    for_each = var.instances

the current value is accessed through:

    each.value

---

## Mistake 3 — Forgetting each.key

When using a Map, the current key is available through:

    each.key

This is useful for resource naming and identifying the instance.

---

## Mistake 4 — Assuming Sets Preserve Order

Sets are unordered.

Do not depend on a specific element index when using a Set.

---

## Mistake 5 — Using depends_on Everywhere

Terraform can automatically determine many dependencies through references.

Use `depends_on` only when an actual dependency exists that Terraform cannot infer.

---

## Mistake 6 — Overusing ignore_changes

`ignore_changes` can hide configuration drift.

Use it only when ignoring the external change is intentional.

---

## Mistake 7 — Misunderstanding prevent_destroy

`prevent_destroy = true` is not a permanent cloud-side deletion protection mechanism.

It protects the resource while the lifecycle configuration remains in the Terraform configuration.

---

## Mistake 8 — Misunderstanding create_before_destroy

`create_before_destroy` requires the old and new resources to coexist during replacement.

It may not work for resources that require globally unique names or other exclusive properties.

---

# 39. Day 09 Command Reference

Initialize:

    terraform init

Format:

    terraform fmt

Validate:

    terraform validate

Plan:

    terraform plan

Apply:

    terraform apply

Destroy:

    terraform destroy

List Terraform-managed resources:

    terraform state list

---

# 40. Resource Address Reference

## count

Example:

    aws_instance.web[0]

    aws_instance.web[1]

    aws_instance.web[2]

## for_each

Example:

    aws_instance.web["web-01"]

    aws_instance.web["web-02"]

    aws_instance.web["web-03"]

The main difference:

    count
      ↓
    Numeric Index

    for_each
      ↓
    Key

---

# 41. Quick Comparison

| Concept | Key Idea |
|---|---|
| `count` | Creates multiple instances using numeric indexes |
| `for_each` | Creates multiple instances using collection keys |
| `each.key` | Current `for_each` key |
| `each.value` | Current `for_each` value |
| `lifecycle` | Controls resource lifecycle behavior |
| `create_before_destroy` | Creates replacement before destroying old resource |
| `prevent_destroy` | Prevents planned destruction while configured |
| `ignore_changes` | Ignores selected external changes |
| `replace_triggered_by` | Triggers replacement when referenced items change |
| `depends_on` | Defines explicit dependency |
| Implicit Dependency | Automatically inferred from references |
| Set | Unique unordered collection |
| Object | Structured value with named attributes |

---

# 42. Day 09 Checklist

## Meta-Arguments

- [ ] Understand Meta-Arguments.
- [ ] Understand `count`.
- [ ] Understand `for_each`.
- [ ] Understand `depends_on`.
- [ ] Understand `lifecycle`.

## Lifecycle

- [ ] Understand `create_before_destroy`.
- [ ] Understand `prevent_destroy`.
- [ ] Understand `ignore_changes`.
- [ ] Understand `replace_triggered_by`.

## Dependencies

- [ ] Understand implicit dependencies.
- [ ] Understand explicit dependencies.
- [ ] Know when to use `depends_on`.
- [ ] Avoid unnecessary explicit dependencies.

## Collections

- [ ] Understand Lists.
- [ ] Understand Sets.
- [ ] Understand Objects.
- [ ] Know that Sets are unordered.
- [ ] Know that Sets contain unique values.

## for_each

- [ ] Understand `each.key`.
- [ ] Understand `each.value`.
- [ ] Understand resource addressing.
- [ ] Use meaningful keys.
- [ ] Complete the three-EC2 challenge using `for_each`.

---

# 43. Memory Test

Without looking at the notes, explain:

1. What is a Terraform Meta-Argument?
2. What does `create_before_destroy` do?
3. What does `prevent_destroy` do?
4. What does `ignore_changes` do?
5. What does `replace_triggered_by` do?
6. What is the main limitation of `count`?
7. How are `count` resources addressed?
8. What is an implicit dependency?
9. What is an explicit dependency?
10. When should `depends_on` be used?
11. What is a Set?
12. Does a Set preserve order?
13. Can a Set contain duplicate values?
14. What is an Object?
15. What does `for_each` do?
16. What is the difference between `each.key` and `each.value`?
17. What is the difference between `count` and `for_each`?
18. Why is `for_each` often preferred when resources have distinct values?
19. How would you create three EC2 instances using `for_each`?
20. What would the resulting resource addresses look like?

---

# 44. Final Mental Model

Day 09 should be remembered as:

    META-ARGUMENTS
          ↓
    RESOURCE BEHAVIOR
          ↓
       LIFECYCLE
          ↓
     DEPENDENCIES
          ↓
    COLLECTION TYPES
          ↓
       for_each
          ↓
    STABLE RESOURCE KEYS

For lifecycle:

    RESOURCE CHANGE
          ↓
      REPLACEMENT
          ↓
    create_before_destroy
          ↓
    CREATE NEW FIRST
          ↓
    DESTROY OLD

For dependencies:

    RESOURCE REFERENCE
          ↓
    IMPLICIT DEPENDENCY

    No Direct Reference
          ↓
       depends_on
          ↓
    EXPLICIT DEPENDENCY

For resource iteration:

    count
      ↓
    Numeric Index
      ↓
    resource[0]
    resource[1]
    resource[2]

    for_each
      ↓
    Stable Key
      ↓
    resource["web-01"]
    resource["web-02"]
    resource["web-03"]

---

# 45. Final Takeaways

Day 09 is about moving from simple Terraform resource creation to more controlled and scalable resource management.

The most important concepts are:

- Meta-Arguments.
- Lifecycle behavior.
- `create_before_destroy`.
- `prevent_destroy`.
- `ignore_changes`.
- `replace_triggered_by`.
- `count`.
- Implicit dependencies.
- Explicit dependencies.
- `depends_on`.
- Sets.
- Objects.
- `for_each`.
- `each.key`.
- `each.value`.

The most important practical lesson is the difference between `count` and `for_each`.

Use `count` when resources are nearly identical and numeric indexes are sufficient.

Use `for_each` when resources have meaningful identities or distinct configuration values.

The Day 09 challenge demonstrates this directly by replacing index-based EC2 creation with key-based EC2 creation.

The goal is not simply to create multiple resources.

The goal is to understand how Terraform identifies, relates, protects, replaces, and manages resources in a predictable way.