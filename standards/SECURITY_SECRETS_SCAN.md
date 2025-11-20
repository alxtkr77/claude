# Security: Secrets Scanning Before Commit

## Purpose

Prevent accidental leaking of sensitive credentials in git commits by scanning for secrets before every commit.

## Critical Rule

**NEVER commit secrets to git repositories** - even private repos. Secrets include:
- API keys and tokens
- Passwords and passphrases
- Cloud provider credentials
- Database connection strings
- Private keys (SSH, SSL, PGP)
- OAuth tokens and client secrets
- Authentication credentials

## Mandatory Pre-Commit Scan

### Step 1: Review Changes
```bash
git diff path/to/changed/files
```

### Step 2: Look for These Patterns

#### ❌ API Keys & Tokens
```
api_key = "ak_live_1234567890abcdef"
token = "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE"
GITHUB_TOKEN = "ghp_1234567890"
ANTHROPIC_API_KEY = "sk-ant-xxxx"
```

#### ❌ Passwords & Secrets
```
password = "MySecretP@ssw0rd"
DB_PASSWORD = "hunter2"
SECRET_KEY = "django-insecure-abc123xyz"
client_secret = "abc123def456"
```

#### ❌ Connection Strings
```
# With embedded credentials
SQLALCHEMY_DATABASE_URI = "postgresql://user:password@host:5432/db"
MONGODB_URI = "mongodb://admin:secret@localhost:27017"
REDIS_URL = "redis://:password@localhost:6379"
```

#### ❌ Private Keys
```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
-----END RSA PRIVATE KEY-----

-----BEGIN PRIVATE KEY-----
...
-----END PRIVATE KEY-----
```

#### ❌ Cloud Credentials
```
# AWS
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

# Azure
AZURE_STORAGE_CONNECTION_STRING = "DefaultEndpointsProtocol=https;AccountName=..."

# Google Cloud
{
  "type": "service_account",
  "private_key": "-----BEGIN PRIVATE KEY-----\n..."
}
```

#### ❌ Hard-coded IPs/Hosts (if sensitive)
```
# Production systems
DB_HOST = "prod-db-01.internal.company.com"
API_ENDPOINT = "https://internal-api.company.com"
```

#### ❌ Email Addresses (if personal/private)
```
ADMIN_EMAIL = "john.doe@company.com"  # If personal
```

#### ❌ Jira/Atlassian IDs (if sensitive)
```
JIRA_CLOUD_ID = "1374a6f1-f268-4a06-909e-b3a9675a9bd1"
# Note: These are often OK in public repos, but check your security policy
```

### Step 3: Common Hiding Places

Check these locations carefully:

#### Configuration Files
- `.env`, `.env.local`, `.env.production`
- `config.yaml`, `config.json`, `settings.py`
- `application.properties`, `application.yml`
- `docker-compose.yml` (environment variables)

#### Test Files
```python
# tests/test_integration.py
def test_api_connection():
    client = APIClient(api_key="ak_live_xyz123")  # ❌ Real key in test!
```

#### Documentation
```markdown
# README.md
## Setup
export API_KEY=sk-ant-xyz123abc  # ❌ Real key in docs!
```

#### Comments
```python
# TODO: Fix this
# api_key = "ak_live_xyz123"  # ❌ Accidentally pasted
```

#### Commit Messages
```bash
git commit -m "Fix auth bug (password was hunter2)"  # ❌ Secret in commit message!
```

## Safe Patterns

### ✅ Environment Variables
```python
import os

API_KEY = os.environ.get("API_KEY")
DB_PASSWORD = os.getenv("DB_PASSWORD")
```

```go
import "os"

apiKey := os.Getenv("API_KEY")
```

```javascript
const apiKey = process.env.API_KEY;
```

### ✅ Config Files (in .gitignore)
```python
# settings.py
from dotenv import load_dotenv
load_dotenv()  # Loads .env file (which is in .gitignore)

API_KEY = os.getenv("API_KEY")
```

### ✅ Placeholders in Documentation
```markdown
# Good - Clear placeholder
export API_KEY=your_api_key_here
export DB_PASSWORD=your_password_here

# Good - Example format
API_KEY=ak_live_xxxxxxxxxxxxxxxxxxxx (starts with ak_live_)
```

### ✅ Test/Mock Credentials (clearly marked)
```python
# Good - Obviously fake
TEST_API_KEY = "test-key-not-real"
MOCK_PASSWORD = "mock-password-for-testing"

# Good - Using test fixtures
@pytest.fixture
def mock_credentials():
    return {
        "api_key": "test-key",
        "password": "test-pass"
    }
```

### ✅ Secret Management Services
```python
# AWS Secrets Manager
import boto3

client = boto3.client('secretsmanager')
secret = client.get_secret_value(SecretId='prod/api/key')
api_key = json.loads(secret['SecretString'])['api_key']

# HashiCorp Vault
import hvac

client = hvac.Client(url='http://localhost:8200')
secret = client.secrets.kv.v2.read_secret_version(path='api-keys')
api_key = secret['data']['data']['api_key']
```

## What to Do If Secrets Found

### Before Commit (Prevention)

1. **STOP** - Do not commit
2. Remove the secret from code
3. Use environment variables or config files
4. Add sensitive files to `.gitignore`:
   ```
   # .gitignore
   .env
   .env.local
   credentials.json
   secrets.yaml
   ```
5. Verify with `git diff` again
6. Commit safely

### After Commit (Already Pushed)

**CRITICAL**: If you've already pushed a commit with secrets:

1. **IMMEDIATELY rotate/revoke the credentials**
   - Generate new API keys
   - Change passwords
   - Revoke OAuth tokens
   - Rotate AWS credentials

2. **Remove from git history** (if private repo and caught quickly):
   ```bash
   # Use git-filter-repo (recommended)
   git filter-repo --invert-paths --path secrets.env

   # Or BFG Repo-Cleaner
   bfg --delete-files secrets.env
   ```

   **Warning**: This rewrites history. Coordinate with team.

3. **Notify security team** (if company policy requires)

4. **Add to .gitignore** to prevent future occurrences

5. **Force push** (if private repo):
   ```bash
   git push origin main --force
   ```

   **Warning**: Force push requires coordination with team.

### After Push (Public Repo)

**ASSUME COMPROMISED**: Even if removed immediately, secrets in public repos should be considered leaked.

1. **IMMEDIATELY rotate ALL credentials**
2. **Notify security team**
3. **Check for unauthorized access**
4. **Follow incident response plan**

## Automated Tools (Optional)

### Pre-commit Hooks
```bash
# Install pre-commit
pip install pre-commit

# Add to .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: detect-aws-credentials
      - id: detect-private-key
```

### Git Secrets
```bash
# Install git-secrets
brew install git-secrets  # macOS
apt-get install git-secrets  # Linux

# Initialize
git secrets --install
git secrets --register-aws

# Scan
git secrets --scan
```

### Gitleaks
```bash
# Install gitleaks
brew install gitleaks

# Scan uncommitted changes
gitleaks detect --no-git

# Scan full history
gitleaks detect -v
```

## Common Mistakes

### ❌ Mistake 1: "It's a test key, it's fine"
```python
# Even test keys can be problematic
STRIPE_TEST_KEY = "sk_test_xyz123..."  # Still gives access to test environment!
```

**Better**:
```python
STRIPE_TEST_KEY = os.getenv("STRIPE_TEST_KEY")
```

### ❌ Mistake 2: "It's in a private repo"
```python
# Still dangerous - repos can become public, employees leave, etc.
API_KEY = "ak_live_xyz123"
```

### ❌ Mistake 3: "I'll remove it later"
```python
# TODO: Remove before commit
password = "MyPassword123"  # ❌ Often forgotten!
```

### ❌ Mistake 4: "It's just in comments"
```python
# Old code: api_key = "ak_live_xyz123"  # ❌ Still searchable!
```

### ❌ Mistake 5: "It's base64 encoded"
```python
# "Obfuscation" is not security
encoded_key = "YWtfbGl2ZV94eXoxMjM="  # Easily decoded!
```

## Integration with Pre-Commit Workflow

This security scan is **Step 5** of the pre-commit workflow:

1. Run `make fmt`
2. Run `make lint`
3. Run tests
4. Review `git diff`
5. **Security scan: Check for secrets** ← YOU ARE HERE
6. Self-review checklist
7. Commit

## Checklist

Before every commit:
- [ ] Reviewed `git diff` line by line
- [ ] No API keys or tokens
- [ ] No passwords or secrets
- [ ] No connection strings with credentials
- [ ] No private keys
- [ ] No cloud credentials
- [ ] No hardcoded sensitive IPs/hosts
- [ ] Test credentials clearly marked as fake
- [ ] Documentation uses placeholders
- [ ] Sensitive files in .gitignore

## Resources

- [GitHub: Removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [GitGuardian: Secrets detection](https://www.gitguardian.com/)
- [OWASP: Secrets management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)

---

**Last Updated**: 2025-11-20
**Importance**: CRITICAL - Security vulnerability prevention
**Applies To**: ALL commits, ALL projects, ALL developers
