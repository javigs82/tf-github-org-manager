
locals {
  repositories = yamldecode(file("repositories.yaml"))
  teams        = yamldecode(file("teams.yaml"))
  members      = yamldecode(file("members.yaml"))

  # iterate over all github_team & local.member that contains a map of teams (<team_name>:<role>)
  team_members = flatten([
    for tn, t in github_team.all : [
      for memb in local.members : {
        name     = "${t.slug}-${memb.username}" # unique! to use as a key map
        team_id  = t.id
        username = memb.username
        role     = memb.teams[t.name]
      } if lookup(memb.teams, t.name, null) != null
    ]
  ])


  # iterate over all github_team & local.repositories that contains a map of teams (<team_name>:<permission>)
  team_repositories = flatten([
    for tn, t in github_team.all : [
      for rep in local.repositories : {
        name = "${t.slug}-${rep.name}" # unique! to use as a key map
        team_id    = t.id
        repository = rep.name
        permission = rep.teams[t.name]
      } if lookup(rep.teams, t.name, null) != null
    ]
  ])
}
