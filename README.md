# tf-github-org-manager

Terraform code to manage github organizations including **repositories**, **teams** and **members**.

## Prerequisites

 - Github account with an organization created
 - Terraform 1.5+

## Assumptions

  - Github organization created
  - Github token created with at least following scopes:
    - The `repo` permission for full control of repositories.
    - The `admin:org` permission for full control of orgs and teams, read and write org projects
  - **Repositories** will never be deleted in terms of reducing blast radius. Instead, they will be *archived* (and manual deleted in case)
  - Due to the nature of this exercise, terraform state is not a remote state and does not implement terraform locks

## How to run it

In order to run this repository, a github token must be properly configured as describe in the above section. Please use [this link](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) to set up the organization owner's access token.

Following security best practices, the token must be set up out of the code in the form of *environment variable* to avoid storing credentials in repositories.

> $ export GITHUB_TOKEN=XXXXXXXXX

Then, create an environment variable named GITHUB_OWNER and set it to your GitHub organization.

> $ export GITHUB_OWNER=<YOUR_ORGANIZATION_NAME_HERE>

Terraform will use these environment variables to authenticate with GitHub and manage your organization's resources.

## Requirements

As an organization, we are currently managing all our code repositories manually within our GitHub account. Over time the configuration of each repository has changed at different times, leading to a significant variance in how each repository is set up. Additionally, managing the users that have access to our repositories is one of the scopes of the current solution.

Data model are defined in yaml format, separating by concerns based on the use case.

### Manage Repository

Adding a new repository quickly and easily within a GitHub Organization. Even the configuration of these repositories will be largely the same, at least following options must be accomplished.
  - Whether the repository is public or private
  - Whether the repository has Issues, Projects, Discussions, or Wiki enabled.
  - Repositories cannot be deleted but archived in order to reduce blast radius

### Manage Users & Teams

The organization needs to add users that can be allocated into 1 or more teams. The level of access to repositories will be different depending on the team,
so at least following features must be implemented

 - Create, delete and update teams. teams can be public or private and sometimes define a parent repository
 - Create, delete and update members. Members has one in the organization that can be `admin` or `member` 
 - Assign members to the teams. Members has one role in the team that can be `maintainer` or `member`
 - Assign repositories & permissions to the teams. The permission of the team members must be one of `pull`,`triage`,`push`,`maintain`, or `admin`


## Design

This section aims to design the solution in terms of modeling and data processing. Please note that data model is built on top of `yaml` structures, that properly supports the scope of this project but might not be an ideal solution for largest organizations when `Single Sign On` identity solutions are usually implemented to manage identity and access management.  

### Models

In order to support the different use cases describe above, following entities and its relations have been declared. 

### Teams

Even though this entity is manyTomany related to *repositories* and *members*, due to data de-normalization, the relations are not defined here in terms of implementing data processing easier and cleaner. terraform data processing is complex of reading and extending due to the nature of the HCL language


```yaml

 - name: management
   description: management team in charge of the organization 
   parent_team: null
   privacy: secret

```

In order to extend teams, please go to [teams.yml](./teams.yaml) to add, update or delete teams. In case of team deletion, [members.yml](./members.yaml) and
 [repositories.yml](./repositories.yaml) needs to be updated as well.


### Members

This entity contains the relation with teams which is a map defining <team_name,team_role>

```yaml

- username: javigs82
  role: admin
  teams:
    back-end: maintainer
    sre: member

```

In order to extend teams, please go to [members.yml](./members.yaml) to add, update or delete members in your organization. 


### Repositories

This entity contains the relation with teams which is a map defining <team_name,repository_permission>

```yaml

- name: clavitos-service-api 
  description: Clavitos backend services
  visibility: "private"
  archived: false
  has_issues: true
  has_downloads: false
  has_projects: false
  has_wiki: true
  gitignore_template: "java"
  teams:
    management: triage
    back-end: maintain
    front-end: pull

```

In order to extend repositories, please go to [repositories.yml](./repositories.yaml) to add, update or archive repos in your organization. Please note that repositories can only be deleted manually to avoid disasters. Terraform repository resource provide a mechanism to comply with this requirement: `archive_on_destroy = true`.

For more info about the implementation, go to [repositories.tf](./repositories.tf)

### Data Processing

To cover the different uses cases, the different data structures needs to be built from yaml files. That involves a bit of complexity in terms of readiness and extensibility.
Those operations are being done in locals, providing the proper relationships to be used as input of the different terraform resources.

Note that, due to the nature of terraform `for_each`, following maps needs to create a unique key built on top of both entity names processed.

``` hcl

 # iterate over all github_team & local.member that contains a map of teams (<team_name>:<team_role>)
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


  # iterate over all github_team & local.repositories that contains a map of teams (<team_name>:<repository_permission>)
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

```

## References

 - https://docs.github.com/organizations

 - https://developer.hashicorp.com/terraform/tutorials/it-saas/github-user-teams

 - https://registry.terraform.io/providers/integrations/github/latest/docs

 - https://github.com/integrations/terraform-provider-github/issues/1064


## Author

 - javigs82 [github](https://github.com/javigs82/)

## License

This project is licensed under the terms of the MIT license: see the 
[LICENSE](./LICENSE) file for details
