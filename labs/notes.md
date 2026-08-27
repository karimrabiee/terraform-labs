# Terraform Day 15 — Notes & Problems

## Notes

### 1. HCP Terraform

HCP Terraform is a cloud platform for managing Terraform collaboratively.

Instead of every engineer managing Terraform independently:

```text
Developer
   ↓
Terraform CLI
   ↓
Local Machine
   ↓
Local State
```

HCP Terraform provides:

```text
Developer
   ↓
Terraform CLI / VCS
   ↓
HCP Terraform
   ↓
Workspace
   ↓
Terraform Run
   ↓
Infrastructure
```

Main capabilities:

* Remote Terraform runs
* Remote state
* Workspaces
* Team collaboration
* Permissions
* Policy enforcement
* Private Registry
* Run Triggers
* Terraform version management

---

### 2. HCP Terraform Structure

The basic structure is:

```text
HCP Terraform
      │
      └── Organization
              │
              ├── Projects
              ├── Workspaces
              ├── Teams
              ├── Private Registry
              └── Policies
```

#### Organization

The Organization is the main container for teams, workspaces, projects, policies, and other HCP Terraform resources.

#### Workspace

A Workspace provides an isolated place for:

```text
Terraform Configuration
State
Variables
Terraform Runs
Execution Settings
```

Example:

```text
Organization
     │
     ├── dev-workspace
     ├── staging-workspace
     └── prod-workspace
```

---

### 3. HCP Terraform Core Workflow

The general workflow is:

```text
Terraform Code
      ↓
HCP Terraform Workspace
      ↓
Terraform Plan
      ↓
Policy Checks
      ↓
Apply
      ↓
Infrastructure
```

HCP Terraform centralizes the Terraform workflow instead of depending entirely on each engineer's local machine.

---

### 4. CLI-Driven Run Workflow

Terraform commands can be initiated from the local CLI while HCP Terraform handles the workspace and remote run.

Example:

```hcl
terraform {
  cloud {
    organization = "my-organization"

    workspaces {
      name = "my-workspace"
    }
  }
}
```

Then:

```bash
terraform login
terraform init
terraform plan
terraform apply
```

Concept:

```text
Developer
    ↓
Terraform CLI
    ↓
HCP Terraform
    ↓
Workspace
    ↓
Remote Run
    ↓
Plan / Apply
```

The important point is that the CLI is used to initiate the workflow, while HCP Terraform can provide the centralized execution environment.

---

### 5. HCP Terraform Pricing

Pricing depends on the HCP Terraform plan and the features required.

For learning, the important concepts are:

```text
Plan
 ↓
Available Features
 ↓
Users / Teams
 ↓
Workspaces / Runs
 ↓
Policy / Collaboration Requirements
```

Do not rely on memorized pricing numbers because HCP Terraform pricing and feature availability can change.

---

### 6. Sentinel

Sentinel is HashiCorp's policy-as-code framework.

It allows organizations to enforce rules before infrastructure changes are applied.

```text
Terraform Plan
      ↓
Sentinel Policy
      ↓
Policy Evaluation
      ↓
Allowed / Denied
      ↓
Apply
```

Examples:

```text
Approved AWS Regions
Required Tags
Approved Instance Types
Security Requirements
Organizational Standards
```

The main purpose is:

> Enforce organizational policies automatically.

---

### 7. Air-Gapped Environments

An air-gapped environment is isolated from normal internet connectivity.

```text
Internet
    X
    │
Air-Gapped Environment
    │
    ├── Terraform
    ├── Providers
    └── Infrastructure
```

The main challenge is providing Terraform with everything it needs without normal internet access.

This may include:

```text
Terraform CLI
Provider Packages
Modules
Required Dependencies
Internal Infrastructure
```

Important concept:

```text
Air-Gapped
    ↓
No Normal Internet Connectivity
    ↓
Dependencies Must Be Available Internally
```

---

### 8. HCP Terraform Private Registry

The Private Registry allows organizations to publish and reuse private Terraform modules.

Example:

```text
Private Registry
      │
      ├── VPC Module
      ├── EC2 Module
      ├── RDS Module
      └── Security Group Module
```

Workflow:

```text
Terraform Module
      ↓
Private Registry
      ↓
Multiple Teams
      ↓
Reusable Infrastructure
```

Benefits:

* Reusability
* Standardization
* Centralized module management
* Controlled access
* Less duplicated Terraform code

---

### 9. HCP Terraform Teams

Teams group users together so permissions can be managed at the team level.

Example:

```text
Organization
     │
     ├── DevOps Team
     ├── Developers
     ├── Security Team
     └── Platform Team
```

Instead of managing every user separately:

```text
Team
  ↓
Users
  ↓
Shared Permissions
```

This makes access management easier as the organization grows.

---

### 10. HCP Terraform Permissions

Permissions determine what users and teams can do within HCP Terraform.

Example:

```text
Developer
   ↓
Limited Access

DevOps
   ↓
Plan / Apply

Administrator
   ↓
Full Management
```

Production environments should normally have stricter permissions than development environments.

Main principle:

> Follow least privilege.

Give users only the permissions required for their responsibilities.

---

### 11. Health Assessments

Health assessments help identify changes or conditions affecting managed infrastructure.

Concept:

```text
Managed Infrastructure
        ↓
Health Assessment
        ↓
Detected Changes / Issues
        ↓
Review
```

The goal is better visibility into infrastructure managed through HCP Terraform.

---

### 12. Run Triggers

Run Triggers connect HCP Terraform workspaces.

A change in one workspace can trigger a run in another workspace.

Example:

```text
Network Workspace
       ↓
Network Change
       ↓
Run Trigger
       ↓
Application Workspace
       ↓
Terraform Run
```

Useful when infrastructure is split into multiple workspaces with dependencies.

Example:

```text
Network
   ↓
VPC / Subnets
   ↓
Application
   ↓
EC2 / Load Balancer
```

---

### 13. State Migration to HCP Terraform

Existing Terraform state can be migrated from a local backend to HCP Terraform.

Before:

```text
Terraform
   ↓
Local Backend
   ↓
terraform.tfstate
```

After:

```text
Terraform
   ↓
HCP Terraform
   ↓
Remote State
```

General workflow:

```text
Existing Terraform Project
          ↓
Configure HCP Terraform
          ↓
terraform init
          ↓
State Migration
          ↓
Remote State
```

Before migration:

* Back up the existing state.
* Verify the target organization/workspace.
* Verify the backend configuration.
* Confirm the state after migration.

---

### 14. Choosing Terraform Version

HCP Terraform workspaces can be configured to use a specific Terraform version.

```text
Workspace
    ↓
Terraform Version
    ↓
Terraform Run
```

Example:

```text
Development
    ↓
Terraform Version A

Production
    ↓
Terraform Version B
```

Best practice:

```text
Choose Version
      ↓
Test
      ↓
Standardize
      ↓
Use Consistently
```

Avoid uncontrolled Terraform version differences between environments.

---

# Problems & Important Issues

## Problem 1 — Confusing HCP Terraform with Terraform Cloud

HCP Terraform is the current HashiCorp platform for hosted Terraform collaboration and execution.

The important concepts to understand are:

```text
Organization
Workspace
Remote State
Remote Runs
Teams
Permissions
Policies
Registry
```

Do not focus only on the product name; understand what each component does.

---

## Problem 2 — Workspace vs Organization

These are not the same.

```text
Organization
    ↓
Contains Workspaces
```

Organization = top-level container.

Workspace = individual Terraform working environment.

---

## Problem 3 — Local State vs HCP Terraform State

Local workflow:

```text
Developer
   ↓
Local State
```

HCP Terraform:

```text
Developer
   ↓
HCP Terraform
   ↓
Remote State
```

Do not confuse the Terraform configuration with Terraform state.

---

## Problem 4 — CLI-Driven Does Not Mean Everything Runs Locally

In a CLI-driven HCP Terraform workflow:

```text
Local CLI
    ↓
HCP Terraform
    ↓
Remote Terraform Run
```

The CLI can initiate the operation while HCP Terraform manages the centralized run.

---

## Problem 5 — Sentinel vs Terraform Validation

These serve different purposes.

Terraform validation:

```text
terraform validate
        ↓
Check Configuration
```

Sentinel:

```text
Terraform Plan
      ↓
Policy
      ↓
Allow / Deny
```

`terraform validate` checks configuration correctness.

Sentinel enforces organizational policies.

---

## Problem 6 — Teams vs Permissions

Teams are groups of users.

Permissions determine what those users can access or perform.

```text
Team
  ↓
Users
  ↓
Permissions
  ↓
Workspace / Resources
```

---

## Problem 7 — Private Registry vs Git Repository

A Git repository stores source code.

The HCP Terraform Private Registry provides a standardized way to publish and consume reusable Terraform modules/providers within an organization.

Concept:

```text
Git
 ↓
Source Code

Private Registry
 ↓
Reusable Terraform Modules / Providers
```

---

## Problem 8 — Run Trigger Dependency

Run Triggers should be used when there is a real dependency between workspaces.

Example:

```text
Network
   ↓
VPC Output
   ↓
Application
```

Avoid creating unnecessary workspace dependencies because they increase architectural coupling.

---

## Problem 9 — State Migration Risk

Changing the backend is not just a normal Terraform configuration change.

Before migrating:

```text
Backup State
     ↓
Verify Configuration
     ↓
terraform init
     ↓
Confirm Migration
     ↓
Verify State
```

Never perform state migration blindly.

---

## Problem 10 — Terraform Version Mismatch

Different Terraform versions can produce inconsistent behavior.

Example:

```text
Developer → Version A
CI/CD     → Version B
Production → Version C
```

Better:

```text
Approved Terraform Version
          ↓
Development
          ↓
CI/CD
          ↓
Production
```

Use a controlled version strategy.

---

# Important Commands

```bash
# Authenticate with HCP Terraform
terraform login

# Initialize HCP Terraform configuration
terraform init

# Create and review plan
terraform plan

# Apply changes
terraform apply

# Show current workspace
terraform workspace show

# List workspaces
terraform workspace list

# Show Terraform version
terraform version

# Validate configuration
terraform validate

# Format configuration
terraform fmt
```

---

# Quick Revision

```text
HCP Terraform
    ↓
Centralized Terraform Platform

Organization
    ↓
Top-Level Container

Workspace
    ↓
State + Variables + Runs

Teams
    ↓
Group Users

Permissions
    ↓
Control Access

Sentinel
    ↓
Policy as Code

Private Registry
    ↓
Reusable Private Modules / Providers

Run Triggers
    ↓
Workspace-to-Workspace Automation

State Migration
    ↓
Local State → HCP Terraform

Terraform Version
    ↓
Controlled Execution Version
```

---

# Most Important Day 15 Points

```text
1. HCP Terraform = Centralized Terraform Management

2. Organization contains Workspaces and Teams

3. Workspace manages Terraform state, variables, and runs

4. HCP Terraform can execute Terraform runs remotely

5. CLI-driven workflow starts from Terraform CLI

6. Sentinel = Policy as Code

7. Private Registry = Reusable Private Terraform Modules / Providers

8. Teams = Group Users

9. Permissions = Control Access

10. Run Triggers = Connect Dependent Workspaces

11. State can be migrated from Local Backend to HCP Terraform

12. Terraform Version should be controlled and standardized

13. Air-Gapped Environment = Isolated from normal Internet connectivity
```

---

# Day 15 Scope

This notes file covers only the topics from Day 15:

```text
HCP Terraform
HCP Terraform Pricing
HCP Terraform Account
HCP Terraform Structure
Organizations
Workspaces
HCP Terraform Core
CLI-Driven Run Workflow
Sentinel
Air-Gapped Environments
Private Registry
Teams
Permissions
Health Assessments
Run Triggers
State Migration
Terraform Version Selection
```
