# Rails Template

This Rails project adopts a standardized workflow using:

- Interactive commits with a **custom** Commitizen script (no Node.js required)
- Automatic commit validation via
  [Overcommit](https://github.com/sds/overcommit)
- [Rubocop](https://rubocop.org/) configuration
- Stylesheet template
- GitHub workflow for CI
- Dependabot configuration
- Recommended branch protection rules for `main`
- Deployment to Render

## Setup

Get template whit PostgreSQL and ready to be deployed to Render.

```sh
rails _7.1.3.4_ new <RAILS-APP> -d postgresql -m https://raw.githubusercontent.com/jotaEmeCortat/rails_template/refs/heads/main/setup.rb
```

## Standardized Commits with custom Commitizen script

To make this easier, a **custom Bash script** (`bin/commitizen`) is provided —
**no Node.js required**.

### ✅ How to use

#### Add an alias to your shell config:

Append this line to your `~/.zshrc` or `~/.bashrc`:

```sh
alias cz="bin/commitizen"
```

Then reload your shell:

```sh
source ~/.zshrc
# or
source ~/.bashrc
```

#### Make commits using:

```sh
cz
```

The script will guide you through an interactive prompt.

## Recommended Branch Protection for `main`

Configure these settings on GitHub (Settings → Branches):

| Setting                              | Status   |
| ------------------------------------ | -------- |
| Protect matching branches            | ✅       |
| Require pull request before merging  | ✅       |
| Require approvals (1 or 2)           | ✅       |
| Dismiss stale pull request approvals | ✅       |
| Require review from Code Owners      | Optional |
| Require approval of most recent push | ✅       |
| Require status checks to pass        | ✅       |
| Require branches to be up to date    | ✅       |
| Require conversation resolution      | ✅       |
| Require signed commits               | Optional |
| Require linear history               | Optional |
| Require successful deployments       | Optional |
| Lock branch                          | ⛔       |
| Do not allow bypassing by admins     | ✅       |
| Allow force pushes                   | ⛔       |
| Allow deletions                      | ⛔       |

---

</br>

**Happy coding!**
