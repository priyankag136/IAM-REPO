locals {
  users =csvdecode(file("users.csv"))
}

locals {

  ungrouped_users = {

    for k, v in aws_iam_user.users :

    k => v

    if !contains([
      for u in aws_iam_group_membership.education_members.users : u
    ], v.name)

    &&
    !contains([
      for u in aws_iam_group_membership.account_members.users : u
    ], v.name)

    &&
    !contains([
      for u in aws_iam_group_membership.manager_members.users : u
    ], v.name)

  }

}