# Team Setup Module

This is a helper module that in its current form creates a single IAM policy for [S3 ABAC](https://docs.aws.amazon.com/AmazonS3/latest/userguide/buckets-tagging-enable-abac.html).
This IAM policy is separated from the S3 bucket, because it's a singleton: one policy is enough
for as many buckets as we want as long as the `Owner` tag mathces.

In the real life, we probably want to do something more fancy: use SSO for AWS. In that case,
the policy would become a permission set attachment.

However, you would probably want to manage SSO separately and onboard teams in a centralized
fashion instead of providing full self-service capabilities there. Otherwise, you'd need some
strong policy enforcement in-place. For example, with `conftest` and Rego.

Also, for SSO I would use an open source module as the first choce as well. For example, [cloudposse/terraform-aws-sso](https://github.com/cloudposse/terraform-aws-sso).
