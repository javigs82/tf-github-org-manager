# tf-github-org-manager

Terraform code to manage github organizations.

## Prerequisites

 - Github account with the organization created
 - Terraform 1.5+

## Assumptions

  - Github organization created
  - Github token created with at least following scopes:
    - The `repo` permisison for full control of repositories.
    - The `admin:org` permission for full control of orgs and teams, read and write org projects
  - Repositories will never be deleted in terms of reducing blast radious. Instead, they will be *archived* (and manual deleted in case)
  - Due to the nature of this exercise, terraform state is not a remote state and does not implement locks

## How to run it

In order to run this repository, a github token must be properly configured as describe in the above section. Please use [this link](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) to set up the organization owner's access token.

Following security best practises, the token must be set up out of the code in the form of *environment variable* to avoid storing credentials in repositories.

> $ export GITHUB_TOKEN=XXXXXXXXX

Then, create an environment variable named GITHUB_OWNER and set it to your GitHub organization.

> $ export GITHUB_OWNER=<YOUR_ORGANIZATION_NAME_HERE>

Terraform will use these environment variables to authenticate with GitHub and manage your organization's resources.

## Requirements

As an organisation, we are currently managing all our code repositories manually within our GitHub account. Over time the configuration of each repository has changed at different times, leading to a significant variance in how each repository is set up. Additionally, managing the users that have access to our repositories is one of the scopes of the current solution.

Data model are defined in yaml format, separating by concerns based on the use case.

### Manage Repository

Adding a new repository quickly and easily within a GitHub Organisation. Even the configuration of these repositories will be largely the same, at least following options must be accomplished.
  - Whether the repository is public or private
  - Whether the repository has Issues, Projects, Discussions, or Wiki enabled.
  - Repositories cannot be deleted but archived in order to reduce blast radious

For more info about the repository model [click here](./repositories.yaml). Note that the relation between team and repository (ManyToMany) is defined in  `repositories.yaml`

### Manage Users & Teams

The organization needs to add users that can be alloacted into 1 or more teams. The level of access to repositories will be different depending on the team,
so at least following option must be accomplished

 - Create teams
 - Assign members to the teams
 - Assign repositories & permissions to the teams. The permission of the team members must be one of `pull`,`triage`,`push`,`mantain`, or `admin`

For more info about the team model [click here](./teams.yaml). 

For more info about the member model [click here](./members.yaml). Note that the relation between team and member (ManyToMany) is defined in  `members.yaml`

## References

 - https://registry.terraform.io/providers/integrations/github/latest/docs

 - https://github.com/integrations/terraform-provider-github/issues/1064


## Author

 - javigs82 [github](https://github.com/javigs82/)

## License

This project is licensed under the terms of the MIT license: see the 
[LICENSE](./LICENSE) file for details

