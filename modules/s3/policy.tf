data "aws_iam_policy_document" "ensure_transit_encrypt" {
  statement {
    sid     = "EnsureEncryptInTransit"
    effect  = "Deny"
    actions = ["s3:*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.this.bucket,
      "${aws_s3_bucket.this.bucket}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

# One has to be very careful with Deny bucket policies. Many times I witnessed situations
# when a bucket was locked for everyone but root
# Notice, I do not use this policy in this module actually, with proper IAM hygiene ABAC may be
# sufficient. AWS IAM implicitly denies access by default, so with ABAC and user IAM policies it
# is possible to restrict access.
# This policy is an illustration that even tigter access control is possible.
# It requires ARNs of those who are allowed to access the bucket. So, either a strong convention
# for IAM role names is required, or one has to provide ARNs to the module explicitly.
# The latter is error prone and poor UX.
# tflint-ignore: terraform_unused_declarations
data "aws_iam_policy_document" "deny_non_owners" {
  statement {
    sid     = "DenyNonAdminNonOwner"
    effect  = "Deny"
    actions = ["s3:*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.this.bucket,
      "${aws_s3_bucket.this.bucket}/*",
    ]
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "aws:PrincipalARN"
      values = concat(
        ["arn:aws:iam:${local.account_id}:role/AdministratorAccess"],
        var.allowed_roles
      )
    }
  }
}

resource "aws_s3_bucket_policy" "ensure_transit_encrypt" {
  bucket = aws_s3_bucket.this.bucket
  policy = data.aws_iam_policy_document.ensure_transit_encrypt.json
}
