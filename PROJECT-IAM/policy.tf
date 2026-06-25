resource "aws_iam_policy" "iam_ec2_policy" {
    name = "IAM-EC2-POLICY"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = [
                "iam:*",
                "ec2:*"
            ]
            Resource = "*"
        }]
    })
}

resource "aws_iam_user_policy_attachment" "user_iam_attch" {
  for_each = aws_iam_user.users
  user = each.value.name
  policy_arn = aws_iam_policy.iam_ec2_policy.arn
}

resource "aws_iam_policy" "route_lambda_policy" {
    name = "ROUTE-LAMBDA-POLICY"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = [
                "route53:*",
                "lambda:*"
            ]
            Resource = "*"
        }]
    })
}

resource "aws_iam_group_policy_attachment" "education_grp" {
  group = aws_iam_group.education.name
  policy_arn = aws_iam_policy.route_lambda_policy.arn
}

resource "aws_iam_group_policy_attachment" "manager_grp" {
  group = aws_iam_group.manager.name
  policy_arn = aws_iam_policy.route_lambda_policy.arn
}

resource "aws_iam_group_policy_attachment" "account_grp" {
  group = aws_iam_group.account.name
  policy_arn = aws_iam_policy.route_lambda_policy.arn
}

resource "aws_iam_role" "role_ec2_s3" {
  name = "role-ec2-s3"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Principal = {
                AWS = [
                    for user in local.ungrouped_users:user.arn
                 ]
            }

            Action = "sts:AssumeRole"
        }
    ]

  })
}

resource "aws_iam_role_policy_attachment" "ec2_policy" {

  role       = aws_iam_role.role_ec2_s3.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"

}

resource "aws_iam_role_policy_attachment" "s3_policy" {

  role       = aws_iam_role.role_ec2_s3.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"

}

resource "aws_iam_user_policy" "assume_role" {

  for_each = local.ungrouped_users

  name = "AssumeEC2S3Role"

  user = each.value.name

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Action = "sts:AssumeRole"

        Resource = aws_iam_role.role_ec2_s3.arn

      }

    ]

  })

}

/*   OPTION1 TO ADD POLICIES TO A GROUP

resource "aws_iam_policy" "education_policy" {

  name        = "EducationPolicy"
  description = "CloudWatch, SNS and SQS access"

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "cloudwatch:*",
          "sns:*",
          "sqs:*"
        ]

        Resource = "*"
      }

    ]

  })

}

resource "aws_iam_group_policy_attachment" "education_policy_attach" {

  group      = aws_iam_group.education.name
  policy_arn = aws_iam_policy.education_policy.arn

}  */


#OPTION2 TO ADD ROLES TO USERS WHICH BELONGS TO THAT SPECIFIC GROUP
resource "aws_iam_role" "education_role" {

  name = "EducationRole"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Principal = {
          AWS = [
            for user in aws_iam_user.users :
            user.arn
            if user.tags.Department == "Education"
          ]
        }

        Action = "sts:AssumeRole"

      }

    ]

  })

}

resource "aws_iam_policy" "cloudwatch_policy" {

  name = "CloudWatchPolicy"

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "cloudwatch:*"
        ]

        Resource = "*"
      }

    ]

  })

}

resource "aws_iam_role_policy_attachment" "cloudwatch_attach" {

  role       = aws_iam_role.education_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn

}

resource "aws_iam_user_policy" "education_assume_role" {

  for_each = {
    for user in aws_iam_user.users :
    user.name => user
    if user.tags.Department == "Education"
  }

  name = "AssumeEducationRole"

  user = each.value.name

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Action = "sts:AssumeRole"

        Resource = aws_iam_role.education_role.arn

      }

    ]

  })

}