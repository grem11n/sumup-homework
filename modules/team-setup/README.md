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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.16 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_policy.s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.s3_abac](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_team_iam_role"></a> [team\_iam\_role](#input\_team\_iam\_role) | IAM role that team assumes | `string` | n/a | yes |
| <a name="input_team_name"></a> [team\_name](#input\_team\_name) | self explanatory | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->