# Creating Multiple S3 Buckets

Explicit is better than implicit! This module creates a single bucket per invocation.
This ensures that the module design is simple and the code is clean.
Remember, the infrastructure code changes less frequently than the application code. Thus,
it's totally ok to repeat yourself from time to time. It's better to have some extra lines of code
than try to understand a nested `for_each` at 3 am.

You can find more info on this matter in [this article](https://rosesecurity.dev/2025/11/14/kiss-versus-dry-iac.html).

Still, this example provide various methods of creating multiple buckets. See [`main.tf`](./main.tf).
