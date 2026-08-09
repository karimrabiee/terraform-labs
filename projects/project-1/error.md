# Errors & Troubleshooting

This document records the configuration errors encountered while building the Terraform AWS infrastructure project, including their causes, solutions, and key lessons learned.

---

## Error 1 — Reference to `count` in Non-Counted Context

### Error

Terraform returned:

```text
Error: Reference to "count" in non-counted context

on local-values.tf line 3, in locals:
3: name = "server-${count.index}"

The "count" object can only be used in "module", "resource", and "data" blocks,
and only when the "count" argument is set.
```

### Problem

The configuration attempted to use `count.index` inside a `locals` block:

```hcl
locals {
  default_tags = {
    Name = "server-${count.index}"
  }
}
```

However, the `locals` block does not have a `count` context.

The `count.index` value is available inside a resource or module that uses the `count` meta-argument.

### Why It Happened

The EC2 resource uses:

```hcl
resource "aws_instance" "web" {
  count = 3
}
```

Therefore, `count.index` is available inside this resource:

```hcl
resource "aws_instance" "web" {
  count = 3

  tags = {
    Name = "server-${count.index}"
  }
}
```

But it cannot be referenced directly from a separate `locals` block.

### Solution

Keep reusable tags independent from `count.index`:

```hcl
locals {
  default_tags = {
    Environment  = "development"
    CreationDate = formatdate("DD/MM/YYYY", timestamp())
  }
}
```

If the instance name needs to include the instance index, use `count.index` inside the EC2 resource:

```hcl
resource "aws_instance" "web" {
  count = 3

  tags = merge(
    local.default_tags,
    {
      Name = "server-${count.index}"
    }
  )
}
```

### Lesson Learned

`count.index` is scoped to the block where `count` is defined.

Valid:

```hcl
resource "aws_instance" "web" {
  count = 3

  tags = {
    Name = "server-${count.index}"
  }
}
```

Invalid:

```hcl
locals {
  default_tags = {
    Name = "server-${count.index}"
  }
}
```

---

## Error 2 — Duplicate `from_port` Argument

### Problem

The HTTP Security Group rule initially contained:

```hcl
from_port = 80
from_port = var.http_port
```

The same Terraform argument was defined twice.

### Why It Happened

A hardcoded value and a variable-based value were both defined for the same argument.

Terraform configuration should contain only one value for a specific argument within a block.

### Solution

Use the variable:

```hcl
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = var.http_port
  to_port           = var.http_port
  protocol          = var.tcp_port
}
```

### Lesson Learned

Avoid defining the same argument more than once.

When a configurable value already exists as a variable, use the variable consistently instead of mixing hardcoded and variable-based values.

---

## Error 3 — Incorrect Security Group Egress Resource Type

### Problem

The original configuration contained:

```hcl
resource "aws_security_group_outgress" "web_sg_egress" {
```

The resource type contained a spelling error:

```text
outgress
```

### Solution

Use the correct AWS provider resource type:

```hcl
aws_security_group_egress
```

Or, when using the dedicated Security Group rule resource:

```hcl
aws_vpc_security_group_egress_rule
```

The project uses the dedicated Security Group rule approach.

### Lesson Learned

Terraform resource type names must exactly match the resource types supported by the provider.

A spelling mistake in a resource type prevents Terraform from recognizing the intended resource.

---

## Error 4 — Understanding `cidr_ipv4 = aws_vpc.main.cidr_block`

### Configuration

The Security Group ingress rules use:

```hcl
cidr_ipv4 = aws_vpc.main.cidr_block
```

### Meaning

This is a Terraform resource attribute reference.

If the VPC is configured as:

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
```

then:

```hcl
aws_vpc.main.cidr_block
```

evaluates to:

```text
10.0.0.0/16
```

Therefore:

```hcl
cidr_ipv4 = aws_vpc.main.cidr_block
```

is equivalent to:

```hcl
cidr_ipv4 = "10.0.0.0/16"
```

but without duplicating the value.

### Why This Is Better

If the VPC CIDR changes, the Security Group rule automatically references the new value.

For example:

```hcl
cidr_block = "10.10.0.0/16"
```

automatically results in:

```text
cidr_ipv4 = "10.10.0.0/16"
```

### Lesson Learned

Use Terraform resource references when one resource depends on an attribute of another resource.

---

## Verification Workflow

After correcting the configuration, the following commands were used:

```powershell
terraform fmt
```

```powershell
terraform validate
```

```powershell
terraform plan
```

The configuration was successfully validated and the execution plan completed successfully.

---

## Final Terraform Plan

The final successful plan reported:

```text
Plan: 9 to add, 0 to change, 0 to destroy.
```

The planned infrastructure included:

```text
1 × VPC
1 × Subnet
1 × Security Group
1 × HTTP Ingress Rule
1 × SSH Ingress Rule
1 × Egress Rule
3 × EC2 Instances
```

Total:

```text
9 resources
```

Terraform also successfully retrieved the Ubuntu AMI through the configured Data Source.

The EC2 instances were represented as:

```text
aws_instance.web[0]
aws_instance.web[1]
aws_instance.web[2]
```

---

## Troubleshooting Summary

| Error                          | Cause                                       | Solution                                       |
| ------------------------------ | ------------------------------------------- | ---------------------------------------------- |
| `count` in non-counted context | `count.index` used inside `locals`          | Use `count.index` inside the counted resource  |
| Duplicate `from_port`          | Same argument defined twice                 | Keep the variable-based value                  |
| Incorrect egress resource type | Typo in resource type                       | Use the correct AWS provider resource          |
| VPC CIDR reference confusion   | Resource attribute reference not understood | `aws_vpc.main.cidr_block` returns the VPC CIDR |

---

## Key Takeaways

* Terraform expressions have scope and context.
* `count.index` is available only where `count` is defined.
* Avoid duplicate arguments within the same block.
* Terraform provider resource types must be written exactly.
* Resource attributes can be referenced directly by other resources.
* Dynamic references reduce duplicated configuration values.
* Always use `terraform fmt`, `terraform validate`, and `terraform plan` before applying infrastructure.
* A successful `terraform plan` confirms that Terraform can build the proposed dependency graph and configuration without planning errors.
