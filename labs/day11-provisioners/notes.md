# Terraform Day 11 — Provisioners Notes

## Overview

Quick notes and common problems related **only** to the Day 11 Provisioners topics.

Covered topics:

* Overview of Provisioners
* Types of Provisioners
* Provisioner Definition
* `local-exec`
* `remote-exec`
* Provisioner Best Practices
* Creation-Time / Destroy-Time
* Provisioner Failure Behavior

---

## 1. Provisioner Types

### `local-exec`

Runs the command on the machine running Terraform.

```text
Terraform Machine
      |
      └── local-exec
```

### `remote-exec`

Runs the command on the remote resource.

```text
Terraform
    |
    └── SSH / WinRM
            |
            └── Remote Machine
```

### Common Mistake

Using `local-exec` expecting the command to run inside the EC2 instance.

**Avoid:**

```hcl
provisioner "local-exec" {
  command = "sudo apt update"
}
```

`local-exec` runs locally.

Use `remote-exec` when the command must execute on the remote machine.

---

# 2. Provisioner Syntax

Basic structure:

```hcl
resource "aws_instance" "example" {

  provisioner "local-exec" {
    command = "echo Created"
  }
}
```

### Common Mistakes

* Defining the provisioner outside a resource.
* Misspelling the provisioner type.
* Using invalid arguments.
* Forgetting required connection settings for `remote-exec`.

---

# 3. `local-exec` Problems

## Problem: Command Not Found

Example:

```text
'command' is not recognized
```

### Cause

The command is not available in the environment where Terraform is running.

### Solution

Check that the required command exists:

```powershell
Get-Command command
```

On Linux:

```bash
which command
```

---

## Problem: Shell Differences

A command that works on Linux may fail on Windows.

Example:

```hcl
provisioner "local-exec" {
  command = "echo $HOME"
}
```

Shell syntax differs between operating systems.

### Avoid

Assuming Bash commands will automatically work in PowerShell or CMD.

---

# 4. `remote-exec` Problems

## Problem: SSH Connection Failed

Typical errors:

```text
connection refused
```

```text
timeout
```

```text
permission denied
```

### Check

* EC2 instance is running.
* Correct public/private IP.
* Security Group allows SSH.
* Correct SSH username.
* Correct private key.
* SSH service is available.
* Network path is reachable.

---

## Problem: Wrong SSH Username

Common examples:

```text
Ubuntu       -> ubuntu
Amazon Linux -> ec2-user
```

The username depends on the AMI.

---

## Problem: Invalid Private Key

Example:

```text
Permission denied (publickey)
```

### Check

```hcl
connection {
  type        = "ssh"
  user        = "ubuntu"
  private_key = file("terraform-key.pem")
  host        = self.public_ip
}
```

Verify:

* Key file exists.
* Key matches the EC2 key pair.
* Correct user is being used.
* File path is correct.

---

# 5. Security Group Problems

`remote-exec` commonly fails because SSH is blocked.

Required rule:

```text
TCP 22
Source: Your trusted IP
```

### Avoid

```text
0.0.0.0/0
```

for SSH in production.

Prefer your own public IP or another trusted network.

---

# 6. `remote-exec` Timing Problems

Sometimes Terraform creates the EC2 instance successfully, but SSH is not immediately available.

```text
EC2 Created
    |
    | Booting
    |
    X SSH not ready
```

Then `remote-exec` may fail.

### Check

* Instance status.
* SSH service.
* Network connectivity.
* Cloud-init/user-data completion.

Do not blindly add delays without understanding the real dependency.

---

# 7. `self` Reference

Inside a provisioner, use `self` to reference the resource containing the provisioner.

Example:

```hcl
provisioner "local-exec" {
  command = "echo ${self.public_ip}"
}
```

### Common Mistake

Using the resource reference incorrectly inside its own provisioner.

---

# 8. Creation-Time Provisioner

Default behavior:

```hcl
provisioner "local-exec" {
  command = "echo Created"
}
```

Runs during resource creation.

### Important

A provisioner is not a replacement for normal Terraform resource configuration.

Prefer Terraform resources whenever possible.

---

# 9. Destroy-Time Provisioner

Syntax:

```hcl
provisioner "local-exec" {
  when    = destroy
  command = "echo Destroying"
}
```

### Common Problem

Destroy-time provisioners depend on the resource lifecycle and Terraform state.

Avoid relying on them for critical cleanup that must happen independently of Terraform.

---

# 10. Provisioner Failure

Default behavior:

```hcl
on_failure = fail
```

Example:

```hcl
provisioner "local-exec" {
  command    = "invalid-command"
  on_failure = fail
}
```

Terraform treats the provisioner failure as an error.

---

## Continue on Failure

```hcl
provisioner "local-exec" {
  command    = "some-command"
  on_failure = continue
}
```

### Warning

Do not use `continue` just to hide errors.

It can leave infrastructure partially configured.

---

# 11. Most Common Problems

| Problem                                        | Likely Cause             | Prevention                           |
| ---------------------------------------------- | ------------------------ | ------------------------------------ |
| `command not found`                            | Tool unavailable locally | Verify command exists                |
| SSH timeout                                    | Port 22 blocked          | Check Security Group/network         |
| `Permission denied`                            | Wrong key/user           | Verify AMI username and key          |
| Connection refused                             | SSH not ready            | Verify instance/SSH service          |
| Script fails                                   | OS/shell differences     | Test script manually                 |
| Provisioner fails                              | Command returned error   | Check command output                 |
| Destroy provisioner doesn't behave as expected | Lifecycle/state issue    | Understand Terraform state           |
| Remote command fails                           | Instance not ready       | Verify connectivity and boot process |
| Sensitive data exposed                         | Credentials in command   | Use secure secret handling           |
| Hidden errors                                  | `on_failure = continue`  | Use only when justified              |

---

# 12. Best Practices

* Prefer Terraform resources over provisioners.
* Use provisioners only when necessary.
* Keep commands simple.
* Test commands manually before using them in Terraform.
* Never hard-code secrets in provisioner commands.
* Use least-privilege network access.
* Restrict SSH access.
* Verify the remote connection before troubleshooting Terraform.
* Use `on_failure = continue` carefully.
* Do not depend on provisioners for critical production configuration when a better Terraform-native solution exists.

---

# 13. Quick Troubleshooting Checklist

```text
[ ] terraform validate
[ ] terraform plan
[ ] Verify provisioner syntax
[ ] Verify command exists
[ ] Verify operating system / shell
[ ] Verify EC2 is running
[ ] Verify IP address
[ ] Verify Security Group
[ ] Verify TCP/22 for SSH
[ ] Verify SSH username
[ ] Verify private key
[ ] Verify SSH connectivity manually
[ ] Check provisioner error output
[ ] Check on_failure behavior
```

---

# 14. Key Rules to Remember

```text
local-exec
    = Runs on Terraform machine

remote-exec
    = Runs on remote machine

Creation-time
    = Default provisioner behavior

Destroy-time
    = when = destroy

Failure
    = Default: fail

Continue
    = on_failure = continue

Best Practice
    = Provisioners are a last resort
```

---

## Day 11 Scope

This notes file covers only:

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
