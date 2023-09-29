resource "github_membership" "all" {
  for_each = {
    for member in local.members :
    member.username => member
  }

  username = each.value.username
  role     = each.value.role
}
