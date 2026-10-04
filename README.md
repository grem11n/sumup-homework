# SumUp Homework

[![terraform-tests](https://github.com/grem11n/sumup-homework/actions/workflows/terraform-test.yaml/badge.svg)](https://github.com/grem11n/sumup-homework/actions/workflows/terraform-test.yaml)
![License](https://img.shields.io/badge/license-MIT-success.svg?style=flat)

This repository contains a take-home task provided by SumUp. This README is an entry point,
but there is more documentats inside this repo.

## Preamble

Normally, for a task like this I would take a readily available [Terraform S3 module](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket).
The motivation is the same as when using a library in a codebase: you don't always need to
create things from scratch. In combination with tight Rego policies and [Conftest](https://www.conftest.dev/),
one could also enforce good practices and naming conventions without rewriting the module.

However, working with Rego policies without AI or readily available templates is complete misery.
I didn't use any AI to generate the code in this repo.
Moreover, the whole task is about writing a module, so here's the module!

Like an AI, though, I left a bunch of comments in various places. Mostly for myself, because
otherwise I wouldn't remember the difference between `BucketOwnerPreferred` and
`BucketOwnerEnforced` after three weeks. If you're interested in the development process itself,
you can check the commit history. I did not squash them. I did not use any pull requests for this project, since it's only me working on it. Also, I tried to use TDD for the S3
module, but it's not always handy for IaC.

I suggest placing modules in a separate repository (or repositories). This way, you can provide
proper versioning and do not break other people's work. However, in this example, both module code
and usage are in the same repository for brevity.

## Design Shotcuts and Assumptions

The task asks to provide an IAM role as well. The problem is that IAM roles do not exist in isolation.
Ideally, you have SSO configured to access your AWS account(s). Perhaps, these are even federated
accounts managed under a single organization. In this case, IAM setup would be more complex
than a single role. Moreover, with such a setup you may likely want to manage IAM in a centralized
fashion by a platform or a security team, and not let folks to "self-service" their IAM permissions.

Thus, this code contains a single illustrative role to bootstrap a team and access the S3 buckets.

Otherwise, this code covers all the topics mentioned in the original task:

**Spec**:

- _Provisions one IAM role and at least one S3 bucket per team_ - exactly one dummy role and potentially as many buckets as you can have.
- _Allows each team to declare how many S3 buckets they need and whether each bucket should be public or private_ - yes, via module vars.
- _Scales dynamically from 1 to 300+ teams without changes to the platform code_ - I am not quite sure what do you mean here by "scales dynamically". [`examples/many`](./modules/s3/examples/many/README.md) contains instructions on how to create multiple buckets per team alongside with some caveats.
- _Keeps each team in control of their own resource declaration file_ - each team gets their own TF state. Although, I would rather factor the code by projects, not teams.
- _Each team must have isolated Terraform state (separate state per team)_ - yes, see above.
- _Triggers a CI/CD pipeline (you can mock this with GitHub Actions or describe it) whenever a team updates their own file_ - given that this is just a sample test, no real CI/CD is happening here. Still, this repository contains [`.atlantis.yaml`](./.atlantis.yaml) and GitHub Actions configuration for illustrative purposes.

**Requirements**:

- _Each team should have an isolated, self-contained configuration file_ - each team has it's own directory for Terraform code, so strictly speaking more than a single file.
- _Adding a new team should require zero changes to the platform module itself_ - yes.
- _Each bucket must have its visibility explicitly declared as either public or private - no defaults_ - yes, and validated on the variables level.
- _The IAM role per team should only have access to that team's own S3 buckets_ - kind of, it's still just a dummy IAM role. For bucket access I use [S3 ABAC](https://docs.aws.amazon.com/AmazonS3/latest/userguide/buckets-tagging-enable-abac.html] here, but there's also an example of how to create a strict bucket policy.
- _S3 buckets should follow a consistent naming convention enforced by the module_ - yes, but the convention itsef it TBD.
- _Terraform state must be isolated per team - no shared state between teams_ - yes.
- _The solution must be idempotent and safe to re-apply_ - yes, there are no imperative steps in the Terraform code, and automation that onboards the teams is (quasi-)idempotent as well. See the Usage parageaph.

## Code Structure

I suggest factoring the code by projects, not teams. Another popular way is to factor the code
by environments, but that may lead to huge states that are hard to manage.
Facotring by projects (services) is more robust than factoring by teams, because the teams are
a subject of change: new teams are created, teams are split and merged, etc.
Every such organizational change would require moving resources around the states, if we want
to keep good IaC hygiene. When the code is factored by projects, changind the ownership is just
a matter of updating some tags and some docs, if certain conventions are followed (shared resurces
such as queues and buckets are always declared by a producer, etc.).

However, this task explicitly requires to have states per team, so here we have states per team.

**High-level directories**:

- `modules/` - contains reusable modules themselves: `s3`, and `team-setup` (used for initial setup). For better version management, you may want to keep modules in a separate repository or event repositories. Here it's all in one place, though.
- `docs` - templates for team onboarding. Potential place for other docs.
- `localtest` - a "team" I used to test the setup locally. See the Testing paragraph.
- `team-a`, `team-b` - examples of "onboarded" teams.

## Usage

### General

Modules' readmes are available in the respective module directories. Since the S3 module is more
interesting one, I also used [`terraform-docs`](https://terraform-docs.io/) to generate parts of
its [`README`](./modules/s3/README.md) in a fancy way.

### Teams Onboarding

Teams onboarding is automated with [`mise`](https://mise.jdx.dev/) - it's an incredible tool,
and I advocate for it whenever I can! You can install it [in different ways](https://mise.jdx.dev/installing-mise.html).
I assume, you're reading it on MacOs, so it's good to know that a `brew` formula is available.

Once installed, you need to install some dependencies for this project. Mise would keep a
project-specific versions, so these tool won't interfere with your environment.

```bash
# Install the dependencies
mise i
```

To onboard a new team, simple run:

```bash
# Replace the <team-name> with whatever you want, e.g. team-x
 mise run new-team <team-name>
```

That's it! Templated TF condigs aready have a file with a bucket example. Yet, it is tailored for
a real AWS account. If you want to test it locally, you can use the [`localtest`](./localtest)
folder.

## Testing

The S3 module has native unit tests. You need Terraform version `1.7+` to run them, though.

I must admit, this was a nice excersise in writing the native tests. Previously, I would use
[Terratest](https://terratest.gruntwork.io/) for this task. It's much more heavy, requires
writing code in Go, but also more flexible, especially when it comes to the integation and e2e
tests. [Here's an example](https://github.com/grem11n/terraform-aws-vpc-peering/tree/master/test)
of how I used it in the past.

With native functionality you can simply run `terraform test` in the module directory! You need to run `terraform init` first, though.

### Serious Tests

I haven't deployed this code in a real AWS account, but I tried it with [MiniStack](https://ministack.org).
Since LocalStack switched to a commercial license, multiple alternatives appeared.
It's been a long time since I wanted to try one of those. I've chosen MiniStack in favor of
[Floci](https://github.com/floci-io/floci) and [Fakecloud](https://github.com/faiscadev/fakecloud)
because it has more straightforward docs than Floci, and uses MIT license. Fakecloud uses AGPL,
which is fine by me, but can be an issue in a corporate setting.

To run the integration tests manually, you need to start Ministack first. You can do it with Docker
or Podman.

```bash
docker run -p 4566:4566 ministackorg/ministack
```

This would create a minimal installation that is enough for IAM and S3.

A caveat I encountered on Fedora: MiniStack doesn't listen on IPv6, and Podman creates a dualstack
network by default. Here's how I ran it in the end:

```bash
podman run --network pasta:-4 -p 4566:4566 ministackorg/ministack
```

Once MiniStack is up, check in another terminal tab that it's up & running:

```bash
curl http://localhost:4566/_ministack/health
```

If everything it ok, go to `localtest` and run Terraform as ususal.

```bash
cd localtest/
terraform init
terraform plan -var-file team.tfvars
terraform apply -var-file team.tfvars
```

A couple of caveats I've noticed with MiniStack:

- Apparenlty, it doesn't support S3 ABAC yet, which results in a warning like below:
    ```
    Warning: AWS resource not found during refresh

    with module.my_team_bucket_simple.aws_s3_bucket_abac.this,
    on ../modules/s3/main.tf line 6, in resource "aws_s3_bucket_abac" "this":
     6: resource "aws_s3_bucket_abac" "this" {
    ```
- I got an error attaching the policy, which claims that the role doesn't exist. However, I can see that the role was created when using the aws cli. I assume, it's a Ministack bug, a definitive test would be to try it in a real AWS account.
    ```
     Error: attaching IAM Policy (arn:aws:iam::000000000000:policy/localtest-s3-policy) to IAM Role (arn:aws:iam::000000000000:role/localtest-role): operation error IAM: AttachRolePolicy, https response error StatusCode: 404, RequestID: dc20b8eb-b0cd-442d-8325-56d901cc7dac, NoSuchEntity: Role arn:aws:iam::000000000000:role/localtest-role not found.
    ```
    ```
     aws --endpoint-url=http://localhost:4566 iam list-roles --output text --no-cli-pager
     ROLES	arn:aws:iam::000000000000:role/localtest-role	2026-10-04T11:06:46+00:00		3600	/AROAC4E9FD4E98C849A79	localtest-role
     ASSUMEROLEPOLICYDOCUMENT	2012-10-17
     STATEMENT	sts:AssumeRole	Allow
     PRINCIPAL	arn:aws:iam::000000000000:root
    ```

## CI/CD

Given this is a sample task, there is no real CI/CD configured. There is a GitHub Action that
runs some basic checks and tests, you can find it in [`terraform-test.yaml`](./.github/workflows/terraform-test.yaml).

In general, for Terraform CD I suggest using [Atlantis](https://www.runatlantis.io/). It's a Git-based
automation for Terraform that is esay to use. Because all the interactions happen through GitHub comments,
working with Atlantis doesn't break developer's flow.

One weak spot of Atlantis is drift detection. There is a plugin for it, but it's so-so.

This repo has an example of repo-side Atlantis configuration in [`.atlantis.yaml`](./.atlantis.yaml)
However, IRL you may want to rather fully use the server-side configuration to fully control
your automation for Terraform.

_CI/CD thinking: How does the pipeline know which team's resources changed and what gets triggered?_ -
Atlantis has a state autodiscovery feature. It works well, unless you need custom workflows
for the projects. Alternatively, it's possible to also update `.atlantis.yaml` with a new team when
one is onboarded, it's just a bit cumbersome. Plus, with many teams (tf states) in place,
the config can quickly become enormous.
