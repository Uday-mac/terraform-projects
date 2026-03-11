locals {
  users = csvdecode(file("./users.csv"))
}

resource "aws_iam_user" "users" {
  for_each = { for user in local.users : user.first_name => user }
  name     = lower("${substr(each.value.first_name, 0, 1)}${each.value.last_name}")

  path = "/users"

  tags = {
    "department" = each.value.department
    "job_title"   = each.value.job_title
  }
}
resource "aws_iam_user_login_profile" "test" {
  for_each                = aws_iam_user.users
  user                    = each.value.name
  password_reset_required = true

  lifecycle {
    ignore_changes = [password_reset_required, password_length]
  }
}

#creating groups
resource "aws_iam_group" "education" {
  name = "education"
  path = "/groups/"
}

resource "aws_iam_group" "Accounting" {
  name = "Accounting"
  path = "/groups/"
}

#adding users to the groups
resource "aws_iam_group_membership" "education_members" {
  name  = "education-membership-group"
  group = aws_iam_group.education.name
  users = [for user in aws_iam_user.users : user.name if user.tags.department == "Education"]
}

resource "aws_iam_group_membership" "Accounting-members" {
  name  = "Accounting-membership-group"
  group = aws_iam_group.Accounting.name
  users = [for user in aws_iam_user.users : user.name if user.tags.department == "Accounting"]
}