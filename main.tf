resource "aws_iam_user" "user_create" {
  for_each = toset(var.users)
  name = each.value
}

resource "aws_iam_user_login_profile" "login" {
  for_each = aws_iam_user.user_create
  user = each.value.name
  password_length = 16
  #pgp_key                 = "keybase:${each.value.name}"
  password_reset_required = true
}

resource "aws_iam_policy" "iam_policy" {

  name = "IAMAccessPolicy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "iam:*",
        "s3:*"
      ]

      Resource = "*"
    }]
  })
}

resource "aws_iam_user_policy_attachment" "attach_iam" {

  for_each = aws_iam_user.user_create

  user       = each.value.name
  policy_arn = aws_iam_policy.iam_policy.arn
}