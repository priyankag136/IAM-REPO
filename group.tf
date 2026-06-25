resource "aws_iam_group" "education" {
    name = "Education"
    path = "/groups/"
}
resource "aws_iam_group" "manager" {
    name = "Manager"
    path = "/groups/"
}
resource "aws_iam_group" "account" {
    name = "Account"
    path = "/groups/"
}

resource "aws_iam_group_membership" "education_members" {
  name = "education-group-membership"
  group = aws_iam_group.education.name

  users = [
    for user in aws_iam_user.users: user.name if user.tags.Department=="Education"
  ]
}

resource "aws_iam_group_membership" "account_members" {
  name = "account-group-membership"
  group = aws_iam_group.account.name

  users = [
    for user in aws_iam_user.users: user.name if user.tags.Department=="Accounting"
  ]
}

resource "aws_iam_group_membership" "manager_members" {
  name = "manager-group-membership"
  group = aws_iam_group.manager.name

  users = [
    for user in aws_iam_user.users: user.name if contains(keys(user.tags),"JobTitle") && can(regex("Manager|CEO",user.tags.JobTitle))
  ]
}