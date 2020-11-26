# Terraform TFE Project

Taken from: https://github.com/innovationnorway/terraform-tfe-project

This [Terraform](https://www.terraform.io/) module creates a project, which is a collection of [workspaces](https://www.terraform.io/docs/cloud/workspaces/index.html).

## Example Usage

```hcl
module "project" {
  source = "innovationnorway/project/tfe"

  organization = "innovationnorway"

  name_prefix = "example"

  environments = [
    "dev",
    "test",
    "prod",
  ]

  workspaces = [
    {
      name = "databricks"
      repo = "innovationnorway/terraform-dataplatform-databricks"
      variables = {
        sku = "premium"
      }
    },
    {
      name = "network"
      repo = "innovationnorway/terraform-infrastructure-network"
      variables = {
        cidr_block = "10.128.0.0/16"
      }
    },
    {
      name = "monitoring"
      repo = "innovationnorway/terraform-infrastructure-monitoring"
      variables = {
        retention_days = 30
      }
    },
  ]

  run_triggers = {
    databricks = ["network"]
    monitoring = ["databricks", "network"]
  }

  queue_runs = ["network"]
}
```

## Arguments

* `organization` - (Required) The name of the organization.

* `name_prefix` - (Required) Creates a unique name beginning with the specified prefix.

* `environments` - (Required) A set of distinct environment names to be used in the project.

* `workspaces` - (Required) A list of `workspaces` objects to be used in the project.

* `run_triggers` - (Optional) A mapping from each workspace name to a list of sourceable workspace names.

* `queue_runs` - (Optional) A list of workspace names for which all runs should be queued.

---

A `workspaces` object supports the following:

* `name` - The name of the workspace.

* `repo` - A reference to a VCS repository in the format `:org/:repo`.

* `variables` - A mapping of Terraform variables to be added to the workspace.