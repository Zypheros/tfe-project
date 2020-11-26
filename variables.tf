variable "name_prefix" {
  type        = string
  description = "Creates a unique name beginning with the specified prefix."
}

variable "organization" {
  type        = string
  description = "The name of the organization."
}

variable "environments" {
  type        = set(string)
  description = "A set of distinct environment names to be used in the project."
}

variable "workspaces" {
  type = map(object({
    name      = string
    working_dir = string
    repo      = string
    variables = map(object({
      key = string
      value = string
      category = string
      sensitive = string
    }))
  }))
  description = "A list of `workspaces` objects to be used in the project."
}

variable "run_triggers" {
  type        = map(list(string))
  default     = {}
  description = "A mapping from each workspace name to a list of sourceable workspace names."
}

variable "queue_runs" {
  type        = list(string)
  default     = []
  description = "A list of workspace names for which all runs should be queued."
}

variable "oauth_token_id" {
  type        = string
  description = "The token ID of the VCS Connection (OAuth Conection Token) to use in Terraform Cloud."
}

locals {
  queue_runs = [
    for p in setproduct(var.queue_runs, var.environments) :
    format("%s-%s-%s", var.name_prefix, p[0], p[1])
  ]

  # The "tfe_workspace" resource only deal with one workspace at a time,
  # so we need to flatten these.
  workspaces = flatten([
    for w in var.workspaces : [
      for e in var.environments : {
        name      = format("%s-%s-%s", var.name_prefix, w.name, e)
        working_dir = w.working_dir
        repo      = w.repo
        variables = w.variables
      }
    ]
  ])

  # The "tfe_variable" resource only deal with one variable at a time,
  # so we need to flatten these.
  variables = flatten([
    for w in local.workspaces : [
      for i in w.variables : {
        workspace = w.name
        key       = i.key
        value     = i.value
        category  = i.category
        sensitive = i.sensitive
      }
    ]
  ])


  # The "tfe_run_trigger" resource only deal with one variable at a time,
  # so we need to flatten these.
  run_triggers = flatten([
    for k, v in var.run_triggers : [
      for p in setproduct(v, var.environments) : {
        workspace  = format("%s-%s-%s", var.name_prefix, k, p[1])
        sourceable = format("%s-%s-%s", var.name_prefix, p[0], p[1])
      }
    ]
  ])
}