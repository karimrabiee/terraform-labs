# Terraform Day 09 — Notes & Troubleshooting

## Scope

Day 09 focuses on Terraform Meta-Arguments, resource lifecycle behavior, resource dependencies, `count`, `for_each`, Sets, and Objects.

The main practical objective is to understand how Terraform manages multiple resource instances, controls resource lifecycle behavior, and handles dependencies between resources.

> These notes are intentionally limited to Day 09 topics.

---

# 1. Terraform Meta-Arguments

Meta-Arguments are special Terraform arguments that change how resources are created, managed, replaced, or destroyed.

Important Meta-Arguments covered in Day 09:

- `count`
- `for_each`
- `depends_on`
- `lifecycle`

Meta-Arguments are different from normal provider-specific resource arguments because they control Terraform's behavior rather than configuring a specific cloud service feature.

---

# 2. lifecycle Meta-Argument

The `lifecycle` block controls how Terraform manages changes to a resource.

Basic structure:

    lifecycle {
      ...
    }

Important lifecycle arguments:

- `create_before_destroy`
- `prevent_destroy`
- `ignore_changes`
- `replace_triggered_by`

---

# 3. create_before_destroy

By default, Terraform may destroy an existing resource before creating its replacement.

`create_before_destroy` changes this behavior.

Example:

    resource "aws_instance" "web" {
      # resource configuration

      lifecycle {
        create_before_destroy = true
      }
    }

Conceptually:

    Default:

    Old Resource
         ↓
      Destroy
         ↓
      Create New


    create_before_destroy:

    Old Resource
         ↓
     Create New
         ↓
     Destroy Old

## Why Use It?

It can help reduce downtime when a resource must be replaced and the old and new resources can exist at the same time.

## Important Consideration

The old and new resources must be able to coexist.

For resources that require unique names or exclusive ownership of a specific identifier, `create_before_destroy` may not be appropriate.

---

# 4. prevent_destroy

`prevent_destroy` protects a resource from planned destruction while the lifecycle configuration remains in place.

Example:

    resource "aws_instance" "database" {
      # resource configuration

      lifecycle {
        prevent_destroy = true
      }
    }

Terraform will reject an operation that attempts to destroy this resource.

## Why Use It?

It can be useful for important resources such as:

- Production databases.
- Critical storage.
- Important infrastructure.

## Important Limitation

`prevent_destroy` is not a permanent cloud-side deletion protection mechanism.

It depends on the lifecycle configuration remaining in the Terraform configuration.

---

# 5. ignore_changes

Terraform normally tries to keep real infrastructure aligned with the Terraform configuration.

If something is changed outside Terraform, Terraform may detect the difference.

`ignore_changes` tells Terraform to ignore changes to selected attributes.

Example:

    resource "aws_instance" "web" {
      tags = {
        Name = "web-server"
      }

      lifecycle {
        ignore_changes = [
          tags
        ]
      }
    }

Terraform will ignore changes to the specified attribute during updates.

---

# 6. ignore_changes = all

Terraform also supports:

    lifecycle {
      ignore_changes = all
    }

This tells Terraform to ignore changes to all resource attributes during updates.

The resource can still be:

- Created.
- Destroyed.

However, Terraform will not attempt to update the resource attributes based on configuration changes.

Use this carefully because it significantly reduces Terraform's control over the resource.

---

# 7. replace_triggered_by

`replace_triggered_by` can cause a resource to be replaced when another referenced resource or item changes.

Conceptually:

    Resource A Changes
          ↓
    Replacement Triggered
          ↓
    Resource B Replaced

Example structure:

    lifecycle {
      replace_triggered_by = [
        aws_instance.example
      ]
    }

The important idea is that a change in the referenced object can trigger replacement of the resource containing the lifecycle rule.

---

# 8. Lifecycle Quick Reference

| Argument | Purpose |
|---|---|
| `create_before_destroy` | Create the replacement before destroying the old resource |
| `prevent_destroy` | Prevent planned destruction of the resource |
| `ignore_changes` | Ignore selected changes |
| `replace_triggered_by` | Trigger replacement when referenced objects change |

---

# 9. count Meta-Argument

`count` allows Terraform to create multiple instances of a resource.

Example:

    resource "aws_instance" "web" {
      count = 3

      instance_type = "t3.micro"
    }

Terraform creates three instances.

Their addresses are:

    aws_instance.web[0]
    aws_instance.web[1]
    aws_instance.web[2]

---

# 10. count.index

When a resource uses `count`, Terraform provides:

    count.index

Example:

    resource "aws_iam_user" "users" {
      count = 3

      name = "user-${count.index + 1}"
    }

The generated names are based on the resource index.

The indexes are:

    0
    1
    2

---

# 11. Main Challenge with count

The major challenge with `count` is index-based resource identity.

Example:

    aws_iam_user.users[0]
    aws_iam_user.users[1]
    aws_iam_user.users[2]

Terraform identifies these resources by their numeric indexes.

If the order of the input data changes, Terraform can associate different values with existing indexes.

This can lead to unnecessary resource changes or replacements.

---

# 12. Example of count Index Problems

Initial configuration:

    0 → user-01
    1 → user-02
    2 → user-03

After changing the order:

    0 → user-03
    1 → user-01
    2 → user-02

Terraform still sees:

    resource[0]
    resource[1]
    resource[2]

The identity is based on the index rather than the actual name.

This is one reason `for_each` can be preferable for resources with distinct identities.

---

# 13. When count Is Appropriate

`count` is useful when resources are essentially identical.

Example:

    resource "aws_instance" "web" {
      count = 3

      instance_type = "t3.micro"
    }

If the instances do not need unique identities beyond their numeric indexes, `count` can be simple and appropriate.

---

# 14. for_each Meta-Argument

`for_each` creates one resource instance for each element in a collection.

It is commonly used with:

- Sets.
- Maps.

Example:

    resource "aws_iam_user" "users" {
      for_each = var.users

      name = each.value
    }

Terraform creates one resource for every element in the collection.

Unlike `count`, `for_each` identifies instances using keys.

---

# 15. each.key

`each.key` represents the current key when using `for_each`.

Example:

    resource "aws_instance" "web" {
      for_each = var.instances

      tags = {
        Name = each.key
      }
    }

If the collection contains:

    web-01
    web-02
    web-03

then `each.key` represents the current resource key.

---

# 16. each.value

`each.value` represents the current value associated with the `for_each` element.

Example:

    resource "aws_instance" "web" {
      for_each = var.instances

      instance_type = each.value.instance_type
    }

For a Map of Objects, `each.value` represents the object associated with the current key.

---

# 17. for_each with a Set

A Set can be used with `for_each`.

Example:

    variable "users" {
      type = set(string)
    }

    resource "aws_iam_user" "users" {
      for_each = var.users

      name = each.value
    }

If the variable contains:

    users = [
      "user-01",
      "user-02",
      "user-03"
    ]

Terraform creates:

    aws_iam_user.users["user-01"]
    aws_iam_user.users["user-02"]
    aws_iam_user.users["user-03"]

---

# 18. Set Data Type

A Set is a Terraform collection type containing unique values.

Example:

    variable "users" {
      type = set(string)
    }

Important characteristics:

- Values are unique.
- Ordering is not significant.
- Duplicate values are not preserved.

Example:

    alice
    bob
    alice

The Set contains only:

    alice
    bob

---

# 19. List vs Set

## List

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

## Set

A Set:

- Does not preserve ordering.
- Does not allow duplicate values.
- Represents unique membership.

Example:

    set(string)

---

# 20. Object Data Type

An Object represents structured data containing named attributes.

Example:

    object({
      name = string
      size = number
    })

A value can look like:

    {
      name = "web"
      size = 20
    }

Objects are useful when multiple related attributes need to be stored together.

---

# 21. Map of Objects

A Map of Objects is especially useful with `for_each`.

Example:

    variable "instances" {
      type = map(object({
        instance_type = string
        environment   = string
      }))
    }

Example values:

    instances = {
      web-01 = {
        instance_type = "t3.micro"
        environment   = "development"
      }

      web-02 = {
        instance_type = "t3.small"
        environment   = "production"
      }

      web-03 = {
        instance_type = "t3.micro"
        environment   = "development"
      }
    }

This structure gives every resource:

- A stable key.
- Its own configuration.
- Multiple related attributes.

---

# 22. for_each with Map of Objects

Example:

    resource "aws_instance" "web" {
      for_each = var.instances

      instance_type = each.value.instance_type

      tags = {
        Name        = each.key
        Environment = each.value.environment
      }
    }

The resource addresses become:

    aws_instance.web["web-01"]
    aws_instance.web["web-02"]
    aws_instance.web["web-03"]

---

# 23. count vs for_each

The most important difference is resource identity.

## count

    resource "aws_instance" "web" {
      count = 3

      instance_type = "t3.micro"
    }

Addresses:

    aws_instance.web[0]
    aws_instance.web[1]
    aws_instance.web[2]

Identity is based on:

    Numeric Index

## for_each

    resource "aws_instance" "web" {
      for_each = var.instances
    }

Addresses:

    aws_instance.web["web-01"]
    aws_instance.web["web-02"]
    aws_instance.web["web-03"]

Identity is based on:

    Key

---

# 24. Why for_each Is Often Better for Distinct Resources

Consider three servers:

    web-01
    web-02
    web-03

Each server has a meaningful identity.

Using `count`, Terraform identifies them as:

    0
    1
    2

Using `for_each`, Terraform identifies them as:

    web-01
    web-02
    web-03

The second approach makes the resource identity more meaningful and avoids many index-related problems.

---

# 25. Resource Dependencies

Terraform builds a dependency graph to determine the correct order for resource operations.

Example:

    VPC
     ↓
    Subnet
     ↓
    EC2 Instance

Terraform uses dependencies to determine which resources must exist before others can be created or used.

---

# 26. Implicit Dependencies

An implicit dependency is automatically created when one resource references another.

Example:

    resource "aws_security_group" "web" {
      # configuration
    }

    resource "aws_instance" "web" {
      vpc_security_group_ids = [
        aws_security_group.web.id
      ]
    }

The EC2 instance references:

    aws_security_group.web.id

Terraform automatically understands:

    Security Group
          ↓
    EC2 Instance

This is an implicit dependency.

---

# 27. Explicit Dependencies

An explicit dependency is defined manually using:

    depends_on

Example:

    resource "aws_instance" "web" {
      depends_on = [
        aws_s3_bucket.example
      ]

      # configuration
    }

This tells Terraform:

    S3 Bucket
        ↓
    EC2 Instance

even if there is no direct resource attribute reference.

---

# 28. Implicit vs Explicit Dependencies

| Type | How Terraform Knows | Example |
|---|---|---|
| Implicit | Resource reference | `aws_security_group.web.id` |
| Explicit | `depends_on` | `depends_on = [aws_s3_bucket.example]` |

## Best Practice

Prefer implicit dependencies when possible.

Use `depends_on` when there is a real dependency that Terraform cannot automatically detect.

---

# 29. depends_on

Example:

    resource "aws_instance" "web" {
      depends_on = [
        aws_s3_bucket.example
      ]
    }

Terraform creates the dependency first.

During destruction, Terraform respects the dependency relationship in the reverse direction.

Conceptually:

    Create:

    S3 Bucket
        ↓
    EC2 Instance

    Destroy:

    EC2 Instance
        ↓
    S3 Bucket

---

# 30. Do Not Overuse depends_on

Avoid adding `depends_on` to resources when Terraform can already determine the dependency.

Unnecessary dependencies can:

- Make the dependency graph more complex.
- Reduce Terraform's ability to perform independent operations.
- Make the configuration harder to understand.

Use explicit dependencies only when they communicate a real requirement.

---

# 31. Day 09 Practical Challenge

The main challenge is:

> Create three EC2 instances using `for_each` instead of `count`.

The goal is to demonstrate the difference between index-based and key-based resource creation.

Instead of:

    count = 3

use:

    for_each = ...

with an appropriate collection.

---

# 32. Recommended Challenge Structure

A Map of Objects is a good structure for distinct EC2 instances.

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
        instance_type = "t3.micro"
      }

      web-03 = {
        instance_type = "t3.micro"
      }
    }

Resource:

    resource "aws_instance" "web" {
      for_each = var.instances

      instance_type = each.value.instance_type

      tags = {
        Name = each.key
      }
    }

---

# 33. Expected Resource Addresses

After using `for_each`, Terraform should track the resources using keys:

    aws_instance.web["web-01"]
    aws_instance.web["web-02"]
    aws_instance.web["web-03"]

This is different from:

    aws_instance.web[0]
    aws_instance.web[1]
    aws_instance.web[2]

---

# 34. Verifying for_each Resources

Use:

    terraform state list

to inspect the resources managed by Terraform.

Expected pattern:

    aws_instance.web["web-01"]
    aws_instance.web["web-02"]
    aws_instance.web["web-03"]

This confirms that Terraform is using key-based resource addressing.

---

# 35. Day 09 Workflow

Recommended workflow:

    terraform init
          ↓
    terraform fmt
          ↓
    terraform validate
          ↓
    terraform plan
          ↓
    Review
          ↓
    terraform apply
          ↓
    Verify
          ↓
    terraform destroy

For the `for_each` challenge, verify the resource addresses after applying the configuration.

---

# 36. Common Mistakes

## Mistake 1 — Using count for Distinct Resources

If resources have different identities or configurations, consider using:

    for_each

instead of:

    count

---

## Mistake 2 — Confusing each.key and each.value

With:

    for_each = var.instances

use:

    each.key

for the resource key.

Use:

    each.value

for the value associated with that key.

---

## Mistake 3 — Assuming Sets Preserve Order

Sets are unordered.

Do not depend on a Set having numeric indexes or a predictable order.

---

## Mistake 4 — Assuming Sets Allow Duplicates

Sets contain unique values.

Duplicate elements are not preserved.

---

## Mistake 5 — Using depends_on Everywhere

Do not manually define dependencies that Terraform already understands from resource references.

---

## Mistake 6 — Overusing ignore_changes

`ignore_changes` can hide real infrastructure drift.

Only ignore changes intentionally.

---

## Mistake 7 — Misunderstanding prevent_destroy

`prevent_destroy` is a Terraform lifecycle protection mechanism.

It is not the same as permanent deletion protection provided by a cloud service.

---

## Mistake 8 — Misusing create_before_destroy

The old and new resources must be able to coexist.

If both resources cannot exist simultaneously, this lifecycle setting may cause problems.

---

# 37. Day 09 Best Practices

## Meta-Arguments

- Understand what each Meta-Argument changes.
- Use lifecycle rules only when required.
- Avoid unnecessary configuration complexity.

## Lifecycle

- Use `create_before_destroy` when replacement order matters.
- Use `prevent_destroy` for important resources that require extra Terraform protection.
- Use `ignore_changes` only for intentionally unmanaged attributes.
- Use `replace_triggered_by` when resource replacement should follow another change.

## Dependencies

- Prefer implicit dependencies.
- Use `depends_on` only when necessary.
- Keep the dependency graph simple.

## count

- Use `count` for similar resources.
- Understand numeric resource indexes.
- Be careful when collection ordering can change.

## for_each

- Use `for_each` for resources with meaningful identities.
- Prefer stable and descriptive keys.
- Understand `each.key` and `each.value`.

## Collections

- Use Lists when ordering matters.
- Use Sets when uniqueness matters.
- Use Objects for structured data.
- Use Maps of Objects for collections of uniquely identified resources.

---

# 38. Important Command Reference

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

List resources:

    terraform state list

---

# 39. Quick Comparison

| Feature | Purpose |
|---|---|
| `count` | Create multiple resource instances using indexes |
| `for_each` | Create multiple resource instances using keys |
| `each.key` | Current `for_each` key |
| `each.value` | Current `for_each` value |
| `lifecycle` | Control resource lifecycle behavior |
| `create_before_destroy` | Create replacement before destroying old resource |
| `prevent_destroy` | Prevent planned destruction |
| `ignore_changes` | Ignore selected attribute changes |
| `replace_triggered_by` | Trigger replacement from another change |
| `depends_on` | Define an explicit dependency |
| Implicit Dependency | Dependency inferred from references |
| Set | Unique unordered collection |
| Object | Structured value with named attributes |

---

# 40. Day 09 Checklist

## Meta-Arguments

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

## Collections

- [ ] Understand Sets.
- [ ] Understand Objects.
- [ ] Understand Maps of Objects.
- [ ] Know that Sets are unordered.
- [ ] Know that Sets contain unique values.

## for_each

- [ ] Understand `each.key`.
- [ ] Understand `each.value`.
- [ ] Understand key-based resource addressing.
- [ ] Create three EC2 instances using `for_each`.
- [ ] Verify the resulting resource addresses.

---

# 41. Interview-Level Questions

Before moving to the next lesson, make sure you can answer:

### What is the difference between count and for_each?

`count` creates resources using numeric indexes, while `for_each` creates resources using keys from a collection.

### Why can for_each be better than count?

`for_each` provides stable and meaningful resource keys, which is useful when resources have distinct identities or configurations.

### What does each.key represent?

The key of the current `for_each` element.

### What does each.value represent?

The value associated with the current `for_each` element.

### What is an implicit dependency?

A dependency Terraform automatically detects from a resource reference.

### What is an explicit dependency?

A dependency manually declared using `depends_on`.

### When should depends_on be used?

When a real dependency exists but Terraform cannot infer it automatically.

### What does create_before_destroy do?

It tells Terraform to create a replacement resource before destroying the existing resource when replacement is required.

### What does prevent_destroy do?

It prevents Terraform from performing a planned destruction of the resource while the lifecycle rule remains configured.

### What does ignore_changes do?

It tells Terraform to ignore changes to specified resource attributes during updates.

### What is a Set?

A collection of unique unordered values.

### What is an Object?

A structured value containing named attributes.

---

# 42. Final Mental Model

Remember Day 09 using four concepts:

    META-ARGUMENTS
          ↓
    CONTROL TERRAFORM BEHAVIOR

    LIFECYCLE
          ↓
    CONTROL CREATE / UPDATE / REPLACE / DESTROY

    DEPENDENCIES
          ↓
    CONTROL RESOURCE RELATIONSHIPS

    for_each
          ↓
    CREATE RESOURCES USING STABLE KEYS

For lifecycle:

    Resource Change
          ↓
    Replacement Required
          ↓
    create_before_destroy
          ↓
    Create New
          ↓
    Destroy Old

For dependencies:

    Resource Reference
          ↓
    Implicit Dependency

or:

    No Direct Reference
          ↓
    depends_on
          ↓
    Explicit Dependency

For resource creation:

    count
      ↓
    Numeric Index
      ↓
    resource[0]
    resource[1]
    resource[2]

versus:

    for_each
      ↓
    Stable Key
      ↓
    resource["web-01"]
    resource["web-02"]
    resource["web-03"]

---

# 43. Final Takeaways

Day 09 introduces more advanced control over Terraform resource behavior.

The most important concepts to remember are:

- Meta-Arguments control Terraform resource behavior.
- `lifecycle` controls how Terraform handles resource changes.
- `create_before_destroy` changes replacement order.
- `prevent_destroy` provides Terraform-level destruction protection.
- `ignore_changes` can intentionally ignore selected changes.
- `replace_triggered_by` can trigger resource replacement.
- `count` uses numeric indexes.
- `for_each` uses stable keys.
- Sets contain unique unordered values.
- Objects represent structured values.
- Implicit dependencies are automatically detected.
- Explicit dependencies use `depends_on`.
- `for_each` is often preferable when resources have distinct identities.
- `each.key` identifies the current resource.
- `each.value` provides the current resource configuration.
- The practical challenge is to create three EC2 instances using `for_each`.

The key lesson of Day 09 is:

> Use the right Meta-Argument for the desired Terraform behavior, and prefer stable resource identities when managing multiple distinct resources.