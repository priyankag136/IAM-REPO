output "users" {
value = [
    for u in aws_iam_user.user_create:
        u.name
]
}
/*
output "user_password" {
  value = {
    for user, prof in aws_iam_user_login_profile.login:
    user => prof.encrypted_password 

    }
    
    sensitive = true

}*/