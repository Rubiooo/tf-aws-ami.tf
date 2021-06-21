data "aws_caller_identity" "caller_identity_current" {}


# IAM user that allows vault to manage dynamic IAM users.

resource "aws_iam_user" "vault" {
  name = "vault-root-user"
  path = "/"
}


data "aws_iam_policy_document" "vault" {
  statement {
    
    effect  = "Allow"
    actions = [
        "iam:AttachUserPolicy",
        "iam:CreateAccessKey",
        "iam:CreateUser",
        "iam:DeleteAccessKey",
        "iam:DeleteUser",
        "iam:DeleteUserPolicy",
        "iam:DetachUserPolicy",
        "iam:ListAccessKeys",
        "iam:ListAttachedUserPolicies",
        "iam:ListGroupsForUser",
        "iam:ListUserPolicies",
        "iam:PutUserPolicy",
        "iam:AddUserToGroup",
        "iam:RemoveUserFromGroup"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "vault" {
  name        = "vault-root-user"
  description = "policy to allow vault to manange dnyamic iam users"
  policy      = data.aws_iam_policy_document.vault.json
}

resource "aws_iam_user_policy_attachment" "vault" {
  user       = aws_iam_user.vault.name
  policy_arn = aws_iam_policy.vault.arn
}


## IAM superuser for EKS/ECR Admin

resource "aws_iam_user" "superuser" {
  name = "vault-superuser"
  path = "/"
}

data "aws_iam_policy_document" "superuser" {
  statement {
    
    effect  = "Allow"
    actions = [
        "autoscaling:*",
        "cloudformation:*",
        "cloudwatch:*",
        "elasticloadbalancing:*",
        "eks:*",
        "ec2:*",
        "ecr:*",
        "iam:*",
        "kms:*",
        "ssm:*",
        "sts:GetFederationToken",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "superuser" {
  name        = "vault-superuser"
  description = "vault-superuser"
  policy      = data.aws_iam_policy_document.superuser.json
}

resource "aws_iam_user_policy_attachment" "superuser" {
  user       = aws_iam_user.superuser.name
  policy_arn = aws_iam_policy.superuser.arn
}