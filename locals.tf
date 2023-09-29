
locals {
  repositories = yamldecode(file("repositories.yaml"))
  teams        = yamldecode(file("teams.yaml"))
  members      = yamldecode(file("members.yaml"))

  # iterate over all github_team & local.member that contains a map of teams (<team_name>:<role>)
  team_members = flatten([
    for tn, t in github_team.all : [
      for memb in local.members : {
        name    = t.name
        team_id = t.id
        username = memb.username
        role = memb.teams[t.name]
      } if lookup(memb.teams, t.name, "NULL") != "NULL"
    ]
  ])

  

  # Parse repo team membership files
  repo_teams_path = "repos-team"
  repo_teams_files = {
    for file in fileset(local.repo_teams_path, "*.csv") :
    trimsuffix(file, ".csv") => csvdecode(file("${local.repo_teams_path}/${file}"))
  }
}
