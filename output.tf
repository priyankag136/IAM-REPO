output "user_names" {
  value = [
    for user in local.users: "${user.first_name} ${user.last_name}"
  ]
}

output "user_passwords" {
  value = {
    for user,v in aws_iam_user_login_profile.users:
    user=> v.password
  }
  sensitive = true
}

output "ungrouped_users" {
  value = [
    for user in local.ungrouped_users: user.name
  ]
}