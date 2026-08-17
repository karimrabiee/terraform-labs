# Terraform Day 11 — Provisioners

## Overview

This lab covers Terraform **Provisioners**, which allow Terraform to execute specific actions on a resource after or before resource creation and during resource destruction.

The focus of this day is understanding how provisioners work, when they are executed, their different types, failure behavior, and the differences between creation-time and destroy-time provisioners.

> **Scope:** This README covers only the topics from the Day 11 videos **105–112**. It does not include topics from previous or upcoming days.

---

## Topics Covered

* Overview of Provisioners
* Types of Provisioners
* Provisioner Definition Syntax
* `local-exec` Provisioner
* `remote-exec` Provisioner
* Important Provisioner Considerations
* Creation-Time Provisioners
* Destroy-Time Provisioners
* Provisioner Failure Behavior

---

## 1. What Are Terraform Provisioners?

Terraform provisioners are used to execute commands or scripts as part of the Terraform resource lifecycle.

They can be useful when Terraform needs to perform an action that cannot be handled directly through a provider resource or argument.

Typical use cases include:

* Running a local command after resource creation
* Executing commands on a newly created remote server
* Running configuration or initialization scripts
* Triggering external commands
* Performing cleanup actions during resource destruction

Example:

```hcl
resource "aws_instance" "example" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo EC2 instance created"
  }
}
```

The provisioner is associated with the resource and participates in its lifecycle.

---

## 2. Types of Provisioners

Terraform provides several provisioner mechanisms.

The two important provisioners covered in this lab are:

### `local-exec`

Runs a command on the machine where Terraform is being executed.

The command does **not** run on the created infrastructure.

Example:

```hcl
provisioner "local-exec" {
  command = "echo Resource created"
}
```

Execution location:

```text
Terraform Machine
      |
      └── local-exec
```

---

### `remote-exec`

Runs commands on the remote resource.

For example, Terraform can create an EC2 instance and then execute commands inside that instance.

Example:

```hcl
provisioner "remote-exec" {
  inline = [
    "sudo apt update",
    "sudo apt install -y nginx"
  ]
}
```

Execution location:

```text
Terraform Machine
      |
      └── SSH / WinRM
              |
              └── Remote Server
```

---

## 3. Provisioner Definition Format

Provisioners are defined inside a Terraform resource block.

General structure:

```hcl
resource "resource_type" "resource_name" {

  # Resource configuration

  provisioner "provisioner_type" {
    # Provisioner configuration
  }
}
```

For example:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo Web server created"
  }
}
```

The provisioner belongs to the resource and is executed according to the resource lifecycle.

---

# 4. `local-exec` Provisioner

The `local-exec` provisioner executes a command on the machine running Terraform.

This is important because the command does **not** execute inside the AWS instance.

For example:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo EC2 instance created"
  }
}
```

If Terraform is executed from:

```text
Windows Laptop
```

the command runs on:

```text
Windows Laptop
```

not on:

```text
EC2 Instance
```

---

## 4.1 Example with Resource Attributes

A provisioner can use Terraform expressions.

```hcl
resource "aws_instance" "web" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo Instance ID: ${self.id}"
  }
}
```

`self` refers to the resource containing the provisioner.

---

## 4.2 Example: Create a Local File

A common demonstration is creating a local file after a resource is created.

```hcl
resource "aws_instance" "web" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > instance-ip.txt"
  }
}
```

The command executes locally and creates:

```text
instance-ip.txt
```

containing the instance's public IP address.

---

# 5. `remote-exec` Provisioner

The `remote-exec` provisioner executes commands on a remote machine.

It normally requires a connection configuration such as SSH for Linux systems.

Example:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("terraform-key.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]
  }
}
```

The general flow is:

```text
Terraform
    |
    | Create EC2
    v
AWS EC2 Instance
    |
    | SSH Connection
    v
remote-exec
    |
    ├── apt update
    ├── install nginx
    └── start nginx
```

---

## 5.1 `inline`

`inline` accepts a list of commands.

Example:

```hcl
provisioner "remote-exec" {
  inline = [
    "sudo apt update",
    "sudo apt install -y nginx",
    "sudo systemctl start nginx"
  ]
}
```

The commands are executed on the remote machine.

---

## 5.2 `script`

A script file can also be executed.

Example:

```hcl
provisioner "remote-exec" {
  script = "setup.sh"
}
```

Terraform uses the remote connection configuration to execute the script on the target machine.

---

## 5.3 `scripts`

Multiple scripts can be specified.

Example:

```hcl
provisioner "remote-exec" {
  scripts = [
    "setup.sh",
    "configure.sh"
  ]
}
```

---

# 6. Connection Configuration

`remote-exec` requires a way to connect to the remote machine.

For Linux systems, SSH is commonly used.

Example:

```hcl
connection {
  type        = "ssh"
  user        = "ubuntu"
  private_key = file("terraform-key.pem")
  host        = self.public_ip
}
```

Important parameters include:

| Argument      | Purpose                      |
| ------------- | ---------------------------- |
| `type`        | Connection protocol          |
| `user`        | Remote operating-system user |
| `private_key` | SSH private key              |
| `host`        | Remote host address          |

---

# 7. Creation-Time Provisioners

By default, provisioners execute during resource creation.

Example:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo Instance created"
  }
}
```

The general lifecycle is:

```text
terraform apply
      |
      v
Create Resource
      |
      v
Run Provisioner
      |
      v
Resource Available
```

Creation-time provisioners are useful when an action needs to happen after the resource has been created.

---

# 8. Destroy-Time Provisioners

A provisioner can also run when a resource is being destroyed.

This is configured using:

```hcl
when = destroy
```

Example:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    when    = destroy
    command = "echo Instance is being destroyed"
  }
}
```

The lifecycle becomes:

```text
terraform destroy
      |
      v
Run Destroy-Time Provisioner
      |
      v
Destroy Resource
```

Destroy-time provisioners should be used carefully because they depend on the resource lifecycle and Terraform state.

---

# 9. Creation-Time vs Destroy-Time

| Feature          | Creation-Time            | Destroy-Time                  |
| ---------------- | ------------------------ | ----------------------------- |
| Default behavior | Yes                      | No                            |
| Configuration    | `provisioner`            | `when = destroy`              |
| Execution        | During resource creation | During resource destruction   |
| Typical purpose  | Initialization / setup   | Cleanup                       |
| Example          | Install software         | Remove external configuration |

Creation-time:

```hcl
provisioner "local-exec" {
  command = "echo Created"
}
```

Destroy-time:

```hcl
provisioner "local-exec" {
  when    = destroy
  command = "echo Destroying"
}
```

---

# 10. Provisioner Failure Behavior

Provisioners can fail.

For example:

```hcl
provisioner "local-exec" {
  command = "invalid-command"
}
```

If the command fails, Terraform normally considers the provisioner execution unsuccessful.

This can affect the resource lifecycle and Terraform state.

---

## 10.1 `on_failure`

Terraform provisioners support the `on_failure` argument.

The important behaviors are:

* `fail`
* `continue`

Example:

```hcl
provisioner "local-exec" {
  command    = "some-command"
  on_failure = continue
}
```

With `continue`, Terraform continues even if the provisioner fails.

---

## 10.2 Default Failure Behavior

The default behavior is:

```hcl
on_failure = fail
```

Therefore:

```hcl
provisioner "local-exec" {
  command = "some-command"
}
```

is effectively treated as:

```hcl
provisioner "local-exec" {
  command    = "some-command"
  on_failure = fail
}
```

---

## 10.3 Continue on Failure

Example:

```hcl
provisioner "local-exec" {
  command    = "echo Something"
  on_failure = continue
}
```

This tells Terraform to continue the operation even if the provisioner command fails.

This option should be used carefully because ignoring failures can hide problems in infrastructure automation.

---

# 11. Important Provisioner Points

Provisioners are powerful, but they should **not** be the first solution for normal infrastructure configuration.

Terraform is designed primarily to manage infrastructure through providers and declarative resource configuration.

Provisioners are generally considered a fallback mechanism when there is no better Terraform-native solution.

---

## 11.1 Prefer Terraform Resources

Instead of using a provisioner to create infrastructure, prefer the appropriate Terraform resource.

For example, avoid using:

```hcl
provisioner "local-exec" {
  command = "aws s3 mb s3://my-bucket"
}
```

when the AWS provider can manage the bucket directly:

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-example-bucket"
}
```

The second approach allows Terraform to understand and manage the resource declaratively.

---

# 12. Provisioners Are Imperative

Terraform resources are primarily declarative.

Provisioners introduce imperative behavior.

Declarative:

```text
Desired State
     |
     v
Terraform
     |
     v
Infrastructure
```

Imperative:

```text
Run Command 1
     |
Run Command 2
     |
Run Command 3
```

This difference is important because imperative commands can be harder for Terraform to track and manage.

---

# 13. Why Provisioners Can Be Problematic

Provisioners can introduce several challenges.

### 1. Dependency on External Systems

A command may depend on:

* Operating-system tools
* Shell configuration
* Network connectivity
* SSH availability
* Credentials
* External APIs

### 2. Less Declarative

Terraform cannot always understand the exact state produced by an arbitrary command.

### 3. Reproducibility Issues

A script may behave differently depending on:

* Operating system
* Installed packages
* Environment variables
* Network conditions
* Current system state

### 4. Failure Handling

If a provisioner fails, the resource may already exist while the provisioning action did not complete successfully.

---

# 14. `local-exec` vs `remote-exec`

| Feature                    | `local-exec`      | `remote-exec`          |
| -------------------------- | ----------------- | ---------------------- |
| Execution location         | Terraform machine | Remote machine         |
| Requires remote connection | No                | Yes                    |
| Common protocol            | Local shell       | SSH / WinRM            |
| Typical use                | Local commands    | Remote configuration   |
| Example                    | Create local file | Install package on EC2 |

---

## 15. Practical Workflow

A typical workflow for testing provisioners is:

```text
terraform init
        |
        v
terraform fmt
        |
        v
terraform validate
        |
        v
terraform plan
        |
        v
terraform apply
        |
        v
Provisioner executes
        |
        v
Verify result
        |
        v
terraform destroy
```

---

# 16. Recommended Lab Structure

A simple project structure for this lab can be:

```text
day11-provisioners/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── setup.sh
└── README.md
```

Keep the project focused only on provisioners covered in this lab.

---

# 17. Useful Terraform Commands

Initialize the working directory:

```bash
terraform init
```

Format Terraform files:

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

Destroy the infrastructure:

```bash
terraform destroy
```

Inspect the current state:

```bash
terraform state list
```

---

# 18. Key Takeaways

### Provisioners

Provisioners allow Terraform to execute commands during resource lifecycle operations.

### `local-exec`

Runs commands on the machine running Terraform.

```text
Terraform Machine
      |
      └── local-exec
```

### `remote-exec`

Runs commands on a remote machine.

```text
Terraform
    |
    └── SSH / WinRM
            |
            └── Remote Machine
```

### Creation-Time

The default provisioner behavior is to execute during resource creation.

### Destroy-Time

Use:

```hcl
when = destroy
```

to execute a provisioner during resource destruction.

### Failure Behavior

Use:

```hcl
on_failure = fail
```

or:

```hcl
on_failure = continue
```

### Best Practice

Use provisioners only when a Terraform-native or provider-based solution is not available.

---

# 19. Interview Notes

### Q1: What is a Terraform provisioner?

A provisioner allows Terraform to execute commands or scripts during a resource lifecycle.

### Q2: What is `local-exec`?

`local-exec` executes a command on the machine where Terraform is running.

### Q3: What is `remote-exec`?

`remote-exec` executes commands on a remote resource, commonly through SSH or WinRM.

### Q4: What is the difference between `local-exec` and `remote-exec`?

`local-exec` runs locally, while `remote-exec` runs on the remote machine.

### Q5: How do you create a destroy-time provisioner?

Use:

```hcl
when = destroy
```

### Q6: What happens if a provisioner fails?

By default, Terraform treats the failure as an error. The behavior can be changed using `on_failure`.

### Q7: What are the values of `on_failure`?

The main values are:

```hcl
on_failure = fail
```

and:

```hcl
on_failure = continue
```

### Q8: Should provisioners be used everywhere?

No. Provisioners should generally be a last resort when Terraform-native functionality or provider resources cannot accomplish the required task.

---

# 20. Best Practices

* Prefer Terraform resources over provisioners whenever possible.
* Use provisioners only when necessary.
* Keep provisioner commands simple and predictable.
* Avoid embedding sensitive credentials directly in provisioner commands.
* Use SSH keys securely for `remote-exec`.
* Validate connectivity before using `remote-exec`.
* Understand the resource lifecycle before using destroy-time provisioners.
* Be careful with `on_failure = continue`.
* Keep scripts version-controlled when scripts are required.
* Test provisioner behavior with `terraform plan` and `terraform apply`.
* Always verify the resulting infrastructure.
* Destroy lab resources after completing the exercise to avoid unnecessary AWS costs.

---

# 21. Day 11 Scope

This README intentionally covers only the following videos:

```text
105. Overview of Provisioners
106. Type of Provisioners
107. Format of Defining Provisioners
108. Practical - local-exec Provisioner
109. Practical - remote-exec Provisioner
110. Points to Note - Provisioners
111. Creation-Time and Destroy-Time Provisioners
112. Failure Behaviour for Provisioners
```

No topics from other Terraform course days are included.

---

# Conclusion

Day 11 introduces Terraform Provisioners and demonstrates how Terraform can execute commands locally or remotely as part of the resource lifecycle.

The most important concepts from this lab are:

```text
Provisioners
    |
    ├── local-exec
    │      └── Runs on Terraform machine
    │
    ├── remote-exec
    │      └── Runs on remote machine
    │
    ├── Creation-Time
    │
    ├── Destroy-Time
    │
    └── Failure Behavior
           ├── fail  (default)
           └── continue
```

The key professional takeaway is that **provisioners should be used carefully and generally as a last resort**. Terraform-native resources and provider capabilities should be preferred whenever they can achieve the required result.
