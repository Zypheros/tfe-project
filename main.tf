resource "tfe_workspace" "main" {
  for_each     = { for w in local.workspaces : w.name => w }
  name         = each.key
  organization = var.organization

  queue_all_runs = contains(local.queue_runs, each.key) ? true : false
  working_directory = each.value.working_dir

  vcs_repo {
    identifier     = each.value.repo
    oauth_token_id = var.oauth_token_id
  }
}

resource "tfe_variable" "main" {
  for_each     = { for i in local.variables : i.key => i}
  key          = each.value.key
  value        = each.value.value
  workspace_id = tfe_workspace.main[each.value.workspace].id
  category     = each.value.category
  sensitive    = each.value.sensitive  
}
