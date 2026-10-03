# SumUp S3 Bucket Module

This module creates an S3 bucket that enforces naming conventions and has some sensible defaults.

You can find examples of how to use this module under [`./examples/`](./examples) folder.

## Usage

See [`./examples/`](./examples).

## Testing

This module has native unit tests. To run them, you need to execute `terraform test` in the module's
directory.

Running the native tests requires Terraform version `1.7+`. OpenTofu doesn't support it,
to my knowledge.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.16 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_abac.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_abac) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.ensure_transit_encrypt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.deny_non_owners](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ensure_transit_encrypt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_access"></a> [access](#input\_access) | Access type for the bucket: private or public | `string` | n/a | yes |
| <a name="input_allowed_roles"></a> [allowed\_roles](#input\_allowed\_roles) | In case of a strict policy a list of roles who is allowed into the bucket | `list(string)` | `[]` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Bucket name. It will be prefixed with <sumup-> and added the environment info. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment of the bucket | `string` | n/a | yes |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Additional tags for the bucket | `map(any)` | `{}` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | Lifecycle rules for the bucket | `list(map(any))` | `[]` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Owning team name | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bucket_acl"></a> [bucket\_acl](#output\_bucket\_acl) | Access type of the bucket |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Bucket name |
<!-- END_TF_DOCS -->
