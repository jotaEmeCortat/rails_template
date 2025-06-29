# Rails Template

A modular and professional Rails template with three configuration options:
Default, Bootstrap, and Tailwind CSS.

## 🚀 Templates Available

- **Default**: Rails + Sass with organized stylesheet structure
- **Bootstrap**: Rails + Bootstrap 5 with responsive components
- **Tailwind**: Rails + Tailwind CSS with utility-first framework

## ⚡ Quick Setup

### Option 1: Install correct Rails version (Recommended)

```bash
gem install rails -v 7.1.3.4
rails new my_app -d postgresql -m https://raw.githubusercontent.com/jotaEmeCortat/rails_template/refs/heads/main/setup.rb
```

### Option 2: Force specific version

```bash
rails _7.1.3.4_ new my_app -d postgresql -m https://raw.githubusercontent.com/jotaEmeCortat/rails_template/refs/heads/main/setup.rb
```

The template automatically checks if you're using the correct Rails version.

## ✨ Features

### 🔧 Development Tools

- **Overcommit**: Git hooks for code quality
- **Commitizen**: Standardized commits (no Node.js required)
- **Rubocop**: Code linting and formatting
- **Brakeman**: Security scanning
- **Bundler Audit**: Dependency vulnerability checking

### 🎨 Frontend Options

- **Default**: Organized SCSS structure
- **Bootstrap**: Complete Bootstrap 5 setup with JavaScript integration
- **Tailwind**: Tailwind CSS with build optimization for production

### ⚙️ Automatic Configuration

- Custom error pages (400, 404, 422, 500)
- Database setup for production (PostgreSQL)
- Environment variables (.env)
- Responsive viewport meta tag
- Asset pipeline optimization
- Deploy configuration for Render.com

### 📦 Included Gems

- **Development**: dotenv-rails, hotwire-livereload
- **Quality**: rubocop, brakeman, bundler-audit, overcommit
- **Utilities**: simple_form, faker, ostruct

## 📝 Standardized Commits

The template includes a custom Commitizen script (no Node.js required).

### Setup alias:

```bash
# Add to your ~/.zshrc or ~/.bashrc
alias cz="bin/commitizen"
```

### Usage:

```bash
cz
```

The script will guide you through an interactive commit message creation.

## 🚀 Deployment & CI/CD

Ready for deployment to Render.com with safe manual deployment workflow:

### 🔄 Continuous Integration

- **Lint**: Code quality checks with Rubocop
- **Test**: Full test suite (unit + system tests)
- **Security**: Brakeman + Bundler Audit scans
- **Automated**: Runs on every push and pull request

### 🚀 Safe Manual Deployment

- **CI First**: Always check that CI passes before deploy
- **Manual Control**: Deploy from Render dashboard when ready
- **No API Keys**: Works perfectly with Render free tier
- **Simple Setup**: No complex configurations needed
- **Zero Cost**: No additional services or integrations required

## 🔒 GitHub Configuration

### Branch Protection Rules (Recommended)

Configure these settings for your `main` branch to ensure safe deployments:

| Setting                           | Recommended | Purpose                          |
| --------------------------------- | ----------- | -------------------------------- |
| Require pull request reviews      | ✅          | Code review before merge         |
| Require status checks to pass     | ✅          | CI must pass before merge        |
| Require branches to be up to date | ✅          | Prevent merge conflicts          |
| Require conversation resolution   | ✅          | All comments must be resolved    |
| Restrict pushes that create files | ✅          | Prevent accidental large commits |
| Include administrators            | ✅          | Rules apply to all users         |

### Required Status Checks

Add these CI workflow jobs as required status checks:

- `CI / Lint`
- `CI / RSpec`
- `CI / Gems Security`

### 🎯 Result

With branch protection enabled:

- ❌ **No broken code** can reach main branch
- ✅ **Only tested code** gets deployed
- 🛡️ **Safe manual deploys** every time

**This makes your manual deployment workflow bulletproof!** 🚀

---

**Happy coding!** 🎉
