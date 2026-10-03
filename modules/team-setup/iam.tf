# An IAM policy for S3 ABAC
data "aws_iam_policy_document" "s3_abac" {
  statement {
    sid    = "ListOwnedBuckets"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets", # only allows listing bucket oned by user
      "s3:GetBucketLocation",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowAccessTeamBuckets"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketTagging",
    ]
    resources = ["arn:aws:s3:::*"]
    condition {
      test     = "StringEquals"
      variable = "s3:BucketTag/Owner"
      values   = [var.team_name]
    }
  }

  # These IAM permission can be tightened, but I need to know what verbs are allowed
  statement {
    sid    = "AllowAccessTeamBucketObjects"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:Put*",
      "s3:Delete*"
    ]
    resources = ["arn:aws:s3:::*/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:BucketTag/Owner"
      values   = [var.team_name]
    }
  }

  # May be an overkill, since IAM is deny by default
  statement {
    sid       = "DenyCreationUntaggedBuckets"
    effect    = "Deny"
    actions   = ["s3:CreateBucket"]
    resources = ["*"]
    condition {
      test     = "Null"
      variable = "s3:BucketTag/Owner"
      values   = ["true"]
    }
  }
}

resource "aws_iam_policy" "s3_policy" {
  name        = "${var.team_name}-s3-policy"
  description = "ABAC policy for the buckets owner"
  policy      = data.aws_iam_policy_document.s3_abac.json
}

resource "aws_iam_role_policy_attachment" "s3_policy" {
  depends_on = [aws_iam_role.team_role]
  role       = aws_iam_role.team_role.arn
  policy_arn = aws_iam_policy.s3_policy.arn
}

# Below is a team role for illustration, just for the sake of being able to apply the code
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_iam_role" "team_role" {
  name               = "${var.team_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
