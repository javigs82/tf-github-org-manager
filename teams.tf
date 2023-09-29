resource "github_team" "all" {
  for_each = {
    for team in local.teams :
    team.name => team
  }

  name                      = each.value.name
  description               = each.value.description
  privacy                   = each.value.privacy
  create_default_maintainer = true
}

resource "github_team_membership" "members" {
  for_each = { for tm in local.team_members : tm.team_id => tm }

  team_id  = each.value.team_id
  username = each.value.username
  role     = each.value.role
}


