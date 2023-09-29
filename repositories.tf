# Create all repositories

resource "github_repository" "all" {
  for_each = {
    for repository in local.repositories :
    repository.name => repository
  }

  # Important to never destroy repos but archieved. It must be done manually just in case
  archive_on_destroy = true
  name               = each.value.name
  description        = each.value.description
  visibility         = each.value.visibility
  has_issues         = each.value.has_issues
  has_downloads      = each.value.has_downloads
  has_projects       = each.value.has_projects
  has_wiki           = each.value.has_wiki

  # this will disable write operations in the repository (read only mode)
  archived = each.value.archived

}


