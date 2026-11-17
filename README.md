# Terraform Labs

A hands-on learning portfolio documenting my study of Terraform and Infrastructure as Code (IaC) while working toward the **HashiCorp Certified: Terraform Associate (003/004)** certification.

The repository contains focused, day-by-day labs, study notes, a small AWS project, and separate Terraform challenge exercises. It records what I have practiced and studied; it is a learning repository, not a claim of production readiness or a production infrastructure platform.

## Learning progress

The repository currently contains materials for **Days 01–15**. The status below describes what is present in Git and, where applicable, what an individual lab README reports. A folder or study note alone does not mean that every example has been deployed, independently validated, or remains active in AWS.

| Day | Topic | Repository evidence |
| --- | --- | --- |
| 01 | Installation, Terraform architecture, providers, and IaC | [Lab README](labs/day01-installation/README.md) marks the lab completed |
| 02 | First EC2 instance, AWS provider, authentication, and resource lifecycle | [Lab README](labs/day02-first-ec2/README.md) marks the lab completed |
| 03 | Terraform state, provider versioning, and GitHub provider | [Lab README](labs/day03-state/README.md) marks the lab completed |
| 04 | Security groups, resource references, outputs, EC2, and Elastic IP | [Lab README](labs/day04-security-group/README.md) marks the lab completed |
| 05 | Input variables, tfvars, and variable precedence | [Lab README](labs/day05-variables/README.md) marks the lab completed |
| 06 | Data types, count, conditionals, built-in functions, and Terraform console | [Study notes](labs/day06-functions-count/notes.md) and example files |
| 07 | Local values, data sources, dynamic AMI lookup, and a small AWS infrastructure project | [Lab README](labs/day07-local-values-data-sources/README.md) |
| 08 | Debugging, formatting, validation, dynamic blocks, plans, splat expressions, and resource targeting | [Lab README](labs/day08-debugging-code-cleanup/README.md) |
| 09 | Meta-arguments, lifecycle, dependencies, sets, objects, count, and for_each | [Lab README](labs/day09-meta-arguments-dependencies-for_each/README.md) |
| 10 | Input validation, preconditions, postconditions, check blocks, and moved blocks | [Lab README](labs/day10-validation-pre_post_condition-check_moved_block/README.md) distinguishes the implemented validation example from other studied topics |
| 11 | Provisioners, including local-exec, remote-exec, and destroy-time behavior | [Lab README](labs/day11-provisioners/README.md) |
| 12 | Reusable modules, module inputs and outputs, providers, and module structure | [Lab README](labs/day12-modules/README.md) |
| 13 | Workspaces, Git collaboration, backends, state locking, S3, and remote state | [Lab README](labs/day13-workspaces-git-remote-state/README.md) |
| 14 | Import, removed blocks, multiple providers, sensitive and ephemeral values, and Vault | [Lab README](labs/day14-import-removed-block-sensitive-data-vault/README.md) |
| 15 | HCP Terraform, organizations, workspaces, teams, policies, runs, and state migration | [Lab README](labs/day15-HCP-terraform/README.md) and study notes |

### Additional work

- [AWS mini project](projects/project-1/README.md): a VPC, subnet, security group, EC2 instances, AMI data source, variables, local values, and resource references.
- [KPLabs Terraform challenges](kplabs-terraform-challenges/): four challenge directories with requirements and Terraform examples.

## Repository layout

```text
.
├── .gitignore
├── .terraform.lock.hcl
├── LICENSE
├── README.md
├── labs/
│   ├── day01-installation/
│   ├── day02-first-ec2/
│   ├── day03-state/
│   ├── day04-security-group/
│   ├── day05-variables/
│   ├── day06-functions-count/
│   ├── day07-local-values-data-sources/
│   ├── day08-debugging-code-cleanup/
│   ├── day09-meta-arguments-dependencies-for_each/
│   ├── day10-validation-pre_post_condition-check_moved_block/
│   ├── day11-provisioners/
│   ├── day12-modules/
│   │   ├── modules/
│   │   └── teams/
│   ├── day13-workspaces-git-remote-state/
│   │   ├── network-team/
│   │   └── security-team/
│   ├── day14-import-removed-block-sensitive-data-vault/
│   └── day15-HCP-terraform/
├── kplabs-terraform-challenges/
│   ├── challenge-1/
│   ├── challenge-2/
│   ├── challenge-3/
│   └── challenge-4/
└── projects/
    └── project-1/
```

Each day is kept in its own directory so you can focus on one configuration at a time. Some directories contain a lab README, some contain study notes, and some contain both. Day 12 includes local modules and team examples; Day 13 includes separate network and security team configurations.

## Prerequisites

Install the tools needed for the lab you plan to run:

- [Terraform CLI](https://developer.hashicorp.com/terraform/install)
- [Git](https://git-scm.com/downloads)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and an AWS account for AWS labs
- An AWS identity with only the permissions needed for the selected lab; configure credentials outside the Terraform files
- A GitHub account/token, Vault environment, or HCP Terraform account only for labs that use those services

You can read the notes without cloud credentials. Cloud provider credentials and account setup are required only when you run a lab that calls that provider.

## Run a lab

Run Terraform from the specific directory containing the configuration you want to work with. For example:

```bash
cd labs/day02-first-ec2
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Review the plan before applying changes:

```bash
terraform apply
```

When you have finished and confirmed the resources are safe to remove:

```bash
terraform plan -destroy
terraform destroy
```

Commands that create or destroy infrastructure can incur charges or affect real resources. Check the active cloud account, region, workspace, and plan before applying or destroying. Do not run Terraform from the repository root unless that is the configuration you intend to operate on.

## Safety and working practices

- Treat every plan as a proposed change to a real account. Check resource names, region, account, workspace, and cost before applying.
- Use a non-root AWS identity and least-privilege permissions for AWS exercises.
- Never put access keys, passwords, tokens, private keys, or other secrets in Terraform files or committed variable files. The repository tracks example `.tfvars` files; inspect them and replace or remove any sensitive values before sharing changes.
- Terraform state and plan files can contain sensitive data. Keep them private and do not commit them.
- Keep each `.terraform.lock.hcl` file under version control so provider selections are reproducible.
- Run `terraform fmt`, `terraform validate`, and `terraform plan` and review the proposed changes before applying.
- Prefer references between resources over hard-coded IDs where practical.
- Use provisioners sparingly; prefer provider resources or purpose-built configuration tools when they fit the task.
- Destroy temporary resources after practice, after checking that they are the intended resources to remove.

The repository's `.gitignore` excludes Terraform working directories, state files, plan files, logs, and common private-key files. Ignore rules are a safeguard, not a substitute for checking what is staged before committing.

## Useful links

- [Terraform documentation](https://developer.hashicorp.com/terraform/docs)
- [Terraform CLI documentation](https://developer.hashicorp.com/terraform/cli)
- [Terraform language documentation](https://developer.hashicorp.com/terraform/language)
- [Terraform Registry](https://registry.terraform.io/)
- [AWS provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [HashiCorp tutorials](https://developer.hashicorp.com/terraform/tutorials)
- [HCP Terraform documentation](https://developer.hashicorp.com/terraform/cloud-docs)

## About

**Kareem Rabie**

AWS Cloud | DevOps | Cloud Security

- [LinkedIn](https://www.linkedin.com/in/kareem-rabie)
- [GitHub](https://github.com/kareemrabiee)

## License

This project is licensed under the [MIT License](LICENSE).
