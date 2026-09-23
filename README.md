# sample-deployment-demonolith-bootstrap-transfer

Hands a source/receiver pair to Snap CD as two modules, so that a transfer can be proved and migrated by the server: [demonolith](https://github.com/schrieksoft/demonolith)'s `transfer` commands, run as a job rather than by hand in a shell.

A transfer has exactly one receiver, so a pair is the whole shape: resources leave one root and arrive in another, both roots already exist, both have their own state, and both keep living afterwards. That is what makes it a transfer rather than a split.

## The pair

- **`roots/app`** - the source. Its DNS zone and that zone's id grew up beside the app they serve, and belong in networking. Both are marked with a bare `# @demono:transfer` comment.
- **`roots/networking`** - the receiver. Its own naming and addressing, in its own state; the marked resources land in its `main.tf` when the code move runs.

One knot makes the pair worth watching: `app`'s `endpoint_name` reads the moved `dns_zone`. After the move that reference crosses a root boundary, so the code move rewrites it into an input variable on `app`, gives `networking` the matching output, and declares the wiring that passes the value at runtime.

Every resource is a mock from the `random` provider, so no cloud account is needed and nothing is really created.

## Use it

```bash
tofu init
tofu apply
```

Every variable has a default matching the pre-configured `snapcd-selfhosted-deployment-docker`; `terraform.tfvars` is gitignored and holds local overrides. Apply both modules from the dashboard once this root has run, so each has state to transfer.

Neither root declares a backend. Snap CD supplies one, written beside the code and pointed at the state store, keyed by each module's own name - which is what keeps the two states apart through the transfer.

`branch_name` selects the branch Snap CD deploys. A prove round runs a ref of its own without changing it, which is how the pair is proved before the code move is merged.

## The code move

The Snap CD wiring lives in this root's own `main.tf`, one level above the pair, so the code move has to be told where to find it:

```bash
cd roots/app
demonolith transfer refactor -y --transfer-target ../networking --snapcd-root ..
```

Without `--snapcd-root`, demonolith looks for a root named `snapcd` beside the source and, finding none, leaves the cross-root reference as code only - the `snapcd_module_input_from_output` that passes the value at runtime is never written.
