# Rails Template

Professional Rails 7.1+ template with three frontend options, CI/CD, and
production-ready deployment configuration.

## 🚀 Features

### Frontend Options

- **Default**: Rails + Sass stylesheets with modular structure
- **Bootstrap**: Bootstrap 5 + custom variables and components
- **Tailwind**: Tailwind CSS with optimized build configuration

### Development Tools

- **Commitizen**: Interactive commit messages (no Node.js required)
- **Overcommit**: Automatic commit validation and hooks
- **Rubocop**: Code formatting and linting
- **Simple Form**: Form helpers with framework integration

### Production Ready

- **PostgreSQL**: Database configuration for all environments
- **Render Deploy**: Optimized build scripts and configuration
- **CI/CD**: GitHub Actions workflow
- **Error Pages**: Custom 404/500 pages
- **Security**: Dependabot and audit tools

## 🛠️ Quick Start

Create a new Rails application with your preferred frontend:

```sh
rails _7.1.3.4_ new <APP-NAME> -d postgresql -m https://raw.githubusercontent.com/jotaEmeCortat/rails_template/refs/heads/main/setup.rb
```

The template will prompt you to choose:

1. **Default** - Rails + Sass
2. **Bootstrap** - Rails + Bootstrap 5
3. **Tailwind** - Rails + Tailwind CSS

## 💻 Development Workflow

### Interactive Commits

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

## 🌐 Deployment

### Render.com

The template includes optimized configuration for Render deployment:

- Automatic asset precompilation
- Database migrations
- Production environment variables
- Build scripts for all frontend options

### Environment Setup

1. Create `.env` file with your variables
2. Configure `DATABASE_URL` in production
3. Deploy using the included `render-build.sh` script

### Automated Checks

- **Rubocop**: Automatic code formatting and style enforcement
- **Overcommit**: Pre-commit and pre-push hooks
- **Brakeman**: Security vulnerability scanning
- **Bundle Audit**: Gem security auditing

### Branch Protection

Configure these settings on GitHub for production-ready workflow:

| Setting                             | Status |
| ----------------------------------- | ------ |
| Require pull request before merging | ✅     |
| Require status checks to pass       | ✅     |
| Require branches to be up to date   | ✅     |
| Require conversation resolution     | ✅     |
| Do not allow bypassing by admins    | ✅     |

---

**Happy coding! 🎉**
