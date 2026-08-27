# Terraform Day 15 — HCP Terraform

## Overview

Day 15 focuses on **HCP Terraform** (HashiCorp Cloud Platform for Terraform) and how it provides a centralized platform for running and managing Terraform in team environments.

Topics include **Organizations, Workspaces, CLI-driven workflows, Sentinel, Air-Gapped Environments, Private Registry, Teams, Permissions, Health Assessments, Run Triggers, State Migration, and Terraform Version Management**.

---

## Topics Covered

### 1. HCP Terraform

HCP Terraform is HashiCorp's managed platform for collaborating on Terraform.

Instead of managing everything locally:

```text
Developer
   ↓
Terraform CLI
   ↓
Local Machine
   ↓
Terraform State
```

HCP Terraform provides a centralized workflow:

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

HCP Terraform can provide:

* Centralized Terraform runs
* Remote state management
* Team collaboration
* Access control
* Policy enforcement
* Private module/provider registry
* Run management
* Workspace management

---

## 2. HCP Terraform Pricing

HCP Terraform provides different capabilities depending on the plan being used.

The important concept is to understand what the platform provides rather than memorizing pricing numbers.

When evaluating HCP Terraform, consider:

```text
Users / Teams
Workspaces
Runs
Policy Enforcement
Private Registry
Access Control
Collaboration Features
```

Pricing and available features can change, so current pricing should always be checked from HashiCorp's official documentation before making a production decision.

---

## 3. Creating an HCP Terraform Account

The basic process is:

```text
Create Account
     ↓
Create Organization
     ↓
Create Workspace
     ↓
Configure Terraform
     ↓
Run Terraform
```

The **Organization** is the main container for HCP Terraform resources.

---

## 4. HCP Terraform Base Structure

The basic hierarchy is:

```text
HCP Terraform
      │
      └── Organization
              │
              ├── Teams
              │
              ├── Projects
              │
              ├── Workspaces
              │
              ├── Private Registry
              │
              └── Policies
```

### Organization

An Organization is the main administrative boundary.

### Workspace

A Workspace is where Terraform configuration, variables, state, runs, and related infrastructure management are organized.

---

## 5. Organization and Workspaces

A typical setup:

```text
Organization
      │
      ├── Network Workspace
      │
      ├── Dev Workspace
      │
      ├── Staging Workspace
      │
      └── Production Workspace
```

Each workspace can have its own:

```text
Terraform State
Variables
Environment Variables
Terraform Runs
Execution Settings
Permissions
```

This provides a centralized way to manage infrastructure environments.

---

## 6. HCP Terraform Core Workflow

The basic workflow is:

```text
Terraform Configuration
          ↓
      HCP Terraform
          ↓
       Workspace
          ↓
      Terraform Plan
          ↓
      Approval / Run
          ↓
     Terraform Apply
          ↓
      Infrastructure
```

HCP Terraform can execute Terraform remotely instead of relying entirely on the user's local machine.

---

## 7. CLI-Driven Run Workflow

HCP Terraform supports a **CLI-driven workflow**, where Terraform commands are initiated from the local CLI while the actual Terraform run can be executed by HCP Terraform.

Conceptually:

```text
Developer
    ↓
terraform plan
    ↓
HCP Terraform
    ↓
Remote Run
    ↓
Plan
    ↓
Apply
```

The Terraform configuration can remain on the developer's machine while HCP Terraform provides the remote execution and state management capabilities.

---

## 8. CLI-Driven Workflow — Practical

A Terraform configuration can be connected to an HCP Terraform workspace through the Terraform configuration.

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

The exact configuration depends on the HCP Terraform setup and authentication method being used.

---

## 9. Sentinel

Sentinel is HashiCorp's policy-as-code framework.

It can be used to enforce organizational rules before infrastructure changes are applied.

Concept:

```text
Terraform Configuration
        ↓
     Terraform Plan
        ↓
      Sentinel
        ↓
   Policy Evaluation
        ↓
   Allowed / Denied
```

Example policies could enforce rules such as:

```text
Only approved AWS regions
Required tags
Approved instance types
No public resources
Required security settings
```

The main purpose is **governance and policy enforcement**.

---

## 10. Air-Gapped Environments

An air-gapped environment is an environment isolated from the public internet.

Concept:

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

The challenge is that Terraform normally needs access to providers, modules, registries, and other external resources.

Air-gapped environments therefore require carefully controlled access to required Terraform dependencies and infrastructure components.

The key concept:

> **Air-gapped = isolated environment with no normal internet connectivity.**

---

## 11. HCP Terraform Private Registry

The Private Registry allows organizations to share reusable Terraform modules and providers privately.

Concept:

```text
Terraform Module
       ↓
Private Registry
       ↓
Multiple Teams
       ↓
Reusable Infrastructure
```

Example:

```text
Private Registry
      │
      ├── VPC Module
      ├── EC2 Module
      ├── RDS Module
      └── Security Group Module
```

Benefits:

* Reusability
* Standardization
* Centralized module management
* Team collaboration
* Controlled access to internal modules

---

## 12. HCP Terraform Teams

Teams allow organizations to group users and manage permissions collectively.

Example:

```text
Organization
     │
     ├── DevOps Team
     ├── Developers
     ├── Security Team
     └── Platform Team
```

Instead of assigning permissions individually to every user, access can be managed through teams.

---

## 13. Managing Permissions

HCP Terraform provides access controls to determine what users and teams can do.

Concept:

```text
Organization
      ↓
    Teams
      ↓
 Permissions
      ↓
 Workspaces / Resources
```

A production workspace should have stricter permissions than a development workspace.

Example:

```text
Developer
   ↓
Read / Limited Access

DevOps
   ↓
Plan / Apply

Admin
   ↓
Full Management
```

The exact permissions should follow the **principle of least privilege**.

---

## 14. Health Assessments

HCP Terraform provides health assessment capabilities to help identify issues with managed infrastructure.

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

The purpose is to improve visibility into infrastructure health and detect conditions that may require attention.

---

## 15. Run Triggers

Run triggers allow one HCP Terraform workspace to trigger a run in another workspace when changes occur.

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

This is useful when Terraform projects have dependencies.

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

A change in the upstream workspace can trigger a run in the downstream workspace.

---

## 16. State Migration to HCP Terraform

Existing Terraform state can be migrated from a local backend to HCP Terraform.

Before migration:

```text
Developer Machine
      ↓
Local State
```

After migration:

```text
Developer
    ↓
HCP Terraform
    ↓
Remote State
```

The general process is:

```text
Existing Terraform Project
          ↓
Configure HCP Terraform
          ↓
terraform init
          ↓
Confirm State Migration
          ↓
State Stored Remotely
```

### Important

State migration should be performed carefully and the existing state should be backed up before making significant backend changes.

---

## 17. Choosing Terraform Version

HCP Terraform allows teams to control which Terraform version is used for workspace runs.

Concept:

```text
Workspace
    ↓
Terraform Version
    ↓
Terraform Run
```

Example:

```text
Production
    ↓
Terraform 1.x

Development
    ↓
Terraform 1.y
```

The goal is to ensure predictable and consistent Terraform execution.

### Best Practice

Use a deliberate Terraform version strategy:

```text
Choose Version
      ↓
Test
      ↓
Standardize
      ↓
Use Consistently
```

Avoid allowing different team members or environments to randomly use different Terraform versions.

---

# HCP Terraform Architecture

A simplified architecture:

```text
                    HCP Terraform
                         │
                ┌────────┴────────┐
                │                 │
          Organization         Teams
                │                 │
        ┌───────┴────────┐        │
        │                │        │
    Workspaces       Private     Permissions
        │             Registry
        │
        ↓
 Terraform Runs
        │
        ├── Plan
        ├── Policy
        └── Apply
        │
        ↓
 Infrastructure
```

---

# HCP Terraform vs Local Terraform

| Feature              | Local Terraform  | HCP Terraform              |
| -------------------- | ---------------- | -------------------------- |
| Terraform execution  | Local            | Can be remote              |
| State                | Local by default | Centralized                |
| Team collaboration   | Manual           | Built-in                   |
| Workspace management | CLI              | Centralized platform       |
| Access control       | Limited          | Team/workspace permissions |
| Policy enforcement   | External/manual  | Sentinel integration       |
| Private Registry     | Not built-in     | Available                  |
| Run management       | Local CLI        | Centralized                |
| Remote execution     | ❌                | ✅                          |

---

# Important Concepts

### Organization

Top-level container for an HCP Terraform environment.

```text
Organization
    ↓
Workspaces / Teams / Registry / Policies
```

### Workspace

Logical environment for Terraform state, variables, and runs.

```text
Workspace
    ↓
State + Variables + Runs
```

### Team

Group of users with shared permissions.

```text
Team
    ↓
Users + Permissions
```

### Sentinel

Policy-as-code for enforcing organizational rules.

```text
Plan
 ↓
Sentinel
 ↓
Policy Decision
```

### Private Registry

Private repository for reusable Terraform modules and providers.

```text
Module
 ↓
Private Registry
 ↓
Teams
```

### Run Trigger

Connects Terraform workspaces through automated run dependencies.

```text
Workspace A
     ↓
Run Trigger
     ↓
Workspace B
```

---

# Best Practices

* Use HCP Terraform for centralized team-based Terraform workflows.
* Organize infrastructure using clear organizations and workspaces.
* Apply least-privilege permissions.
* Separate production access from development access.
* Use Teams for scalable access management.
* Use the Private Registry for reusable internal modules.
* Use Sentinel when centralized policy enforcement is required.
* Use Run Triggers when workspaces have explicit dependencies.
* Keep Terraform versions standardized across environments.
* Back up state before migrating it to HCP Terraform.
* Treat Terraform State as sensitive information.
* Avoid unnecessary workspace-to-workspace dependencies.
* Test Terraform and provider version upgrades before applying them to production.

---

# Day 15 Video Progress

| #   | Topic                                                          | Status          |
| --- | -------------------------------------------------------------- | --------------- |
| 150 | Overview of HashiCorp Cloud Platform for Terraform             | ✅ Completed     |
| 151 | HashiCorp Cloud Platform — Pricing                             | ✅ Completed     |
| 152 | Creating a New HCP Terraform Account                           | ✅ Completed     |
| 153 | Base Structure of HashiCorp Cloud Platform for Terraform       | ✅ Completed     |
| 154 | HCP Terraform Practical — Creating Organization and Workspaces | ✅ Completed     |
| 155 | HCP Terraform — Core Practical                                 | ✅ Completed     |
| 156 | The CLI-driven Run Workflow in HCP                             | ✅ Completed     |
| 157 | The CLI-driven Run Workflow — Practical                        | ✅ Completed     |
| 158 | Overview of Sentinel                                           | ✅ Completed     |
| 159 | Air Gapped Environments                                        | ✅ Completed     |
| 160 | HCP Terraform Private Registry                                 | ✅ Completed     |
| 161 | HCP Terraform — Teams                                          | ✅ Completed     |
| 162 | HCP Terraform — Manage Permissions                             | ✅ Completed     |
| 163 | HCP Terraform — Health Assessments                             | ✅ Completed     |
| 164 | HCP Terraform — Run Triggers                                   | ✅ Completed     |
| 165 | Migrate State to HCP Terraform                                 | ⏳ Not Completed |
| 166 | HCP Terraform — Choosing Version                               | ⏳ Not Completed |

---

# Key Takeaways

```text
HCP Terraform
      ↓
Centralized Terraform Platform
      ↓
Organization
      ↓
Workspaces
      ↓
Remote Runs + State
      ↓
Teams + Permissions
      ↓
Private Registry
      ↓
Sentinel Policies
      ↓
Run Triggers
      ↓
Centralized Team Infrastructure Management
```

The most important idea from Day 15 is that **HCP Terraform moves Terraform from a primarily local workflow into a centralized, collaborative, controlled platform**.

It provides the foundation for managing Terraform at team and organizational scale through **remote state, remote runs, workspaces, permissions, policies, private modules, and centralized workflow management**.

---

## Day 15 Scope

This day covers only:

```text
HCP Terraform
HCP Terraform Pricing
HCP Terraform Account
Organizations
Workspaces
HCP Terraform Core
CLI-driven Run Workflow
Sentinel
Air-Gapped Environments
Private Registry
Teams
Permissions
Health Assessments
Run Triggers
State Migration to HCP Terraform
Terraform Version Management
```
