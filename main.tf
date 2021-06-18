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

# IAM role that allows devops to deploy resources


resource "aws_iam_role" "devops" {
  name = "devops"
  assume_role_policy = data.aws_iam_policy_document.devops.json
}

data "aws_iam_policy_document" "devops" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.vault.arn]
    }

    principals {
      type        = "Service"
      identifiers = [var.trusted_ecs_service]
    }

    principals {
      type        = "Service"
      identifiers = [var.trusted_lambda_service]
    }

  }
}

resource "aws_iam_role_policy_attachment" "devops" {
  role       = aws_iam_role.devops.name
  count      = length(var.devops_iam_role_policy_arn)
  policy_arn = var.devops_iam_role_policy_arn[count.index]
}


# Allow vault root user to assume the devops role

data "aws_iam_policy_document" "vault-devops" {
  statement {
    
    effect  = "Allow"
    actions = [
        "sts:AssumeRole",
    ]
    resources = [aws_iam_role.devops.arn]
  }
}

resource "aws_iam_policy" "vault-devops" {
  name        = "vault-assume-devops-role"
  description = "policy to allow vault to assume devops role"
  policy      = data.aws_iam_policy_document.vault-devops.json
}

resource "aws_iam_user_policy_attachment" "vault-devops" {
  user       = aws_iam_user.vault.name
  policy_arn = aws_iam_policy.vault-devops.arn
}

output "devops-role-arn" {
  value = aws_iam_role.devops.arn
}