# Common Development Tasks Template

> **Template for project-specific common tasks**
>
> Copy this to your project and customize with project-specific values.
> Replace `{PLACEHOLDERS}` with actual values in your project-specific version.

---

## Development Environment Tasks

### Setup Development Environment

```bash
# Clone repository
git clone git@github.com:{ORG}/{REPO}.git
cd {REPO}

# Create virtualenv (Python projects)
python -m venv venv
source venv/bin/activate

# Install dependencies
{INSTALL_COMMAND}

# Verify setup
{TEST_COMMAND}
```

### Format and Lint Code

```bash
# ALWAYS format first, then lint
make fmt   # Auto-fix formatting issues
make lint  # Check remaining issues

# Fix any remaining lint errors manually
```

### Run Tests

```bash
# All tests
{TEST_COMMAND}

# Specific test file
pytest tests/{path}/test_{name}.py

# Specific test
pytest tests/{path}/test_{name}.py::test_{function}

# With coverage
pytest --cov={PACKAGE} --cov-report=html tests/
```

---

## Database Tasks (if applicable)

### Debug Database Pipeline

```bash
# 1. Set database connection
export {DB_ENV_VAR}={DB_PROTOCOL}://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}

# 2. Activate environment
{ACTIVATE_ENV_COMMAND}

# 3. Deploy changes (if applicable)
{DEPLOY_COMMAND}

# 4. Reset database (clean state)
{DB_RESET_COMMAND}

# 5. Run tests
{TEST_COMMAND}
```

### Check Database Data

```python
import {DB_DRIVER}
conn = {DB_DRIVER}.connect("{DB_CONNECTION_STRING}")
cur = conn.cursor()

# List tables
cur.execute("""
    SELECT table_name FROM information_schema.tables
    WHERE table_schema = '{SCHEMA_NAME}'
""")
print(cur.fetchall())
```

### Reset Test Database

```bash
# SSH to database host (if remote)
ssh {SSH_USER}@{DB_HOST}

# Restart container (loses all data)
docker restart {DB_CONTAINER_NAME}

# Or drop/recreate specific schema
{DB_CLI} -U {DB_USER} -d {DB_NAME} -c "DROP SCHEMA IF EXISTS {SCHEMA_NAME} CASCADE;"
{DB_CLI} -U {DB_USER} -d {DB_NAME} -c "CREATE SCHEMA {SCHEMA_NAME};"
```

---

## API Tasks

### Add New API Endpoint

**Step 1: Define schema**
```python
from pydantic import BaseModel

class ItemCreate(BaseModel):
    name: str
    # ... fields

class ItemResponse(BaseModel):
    id: str
    name: str
    # ... fields
```

**Step 2: Implement CRUD**
```python
def create_item(project: str, item: ItemCreate):
    # Validation
    _validate_item_data(item)

    # Create in database
    db_item = get_db().create_item(project, item.dict())

    return ItemResponse(**db_item)
```

**Step 3: Add route**
```python
from fastapi import APIRouter, Depends

router = APIRouter()

@router.post("/projects/{project}/items", response_model=ItemResponse)
def create_item_route(
    project: str,
    item: ItemCreate,
    auth: Auth = Depends(get_auth)
):
    auth.verify_project_permission(project, "create")
    return crud.items.create_item(project, item)
```

**Step 4: Add tests**
```python
def test_create_item(client, auth_token):
    response = client.post(
        "/api/v1/projects/default/items",
        headers={"Authorization": f"Bearer {auth_token}"},
        json={"name": "test", ...}
    )
    assert response.status_code == 200
    assert response.json()["name"] == "test"
```

---

## PR Workflow

### Create PR

```bash
# 1. Create feature branch
git checkout {MAIN_BRANCH}
git pull upstream {MAIN_BRANCH}
git checkout -b feature/{PROJECT_KEY}-12345-description

# 2. Make changes and test
# ... edit files ...
make fmt
make lint
{TEST_COMMAND}

# 3. Commit
git add .
git commit -m "[Component] Add feature description

Implements feature X.

- Change 1
- Change 2
- Reference: {PROJECT_KEY}-12345"

# 4. Rebase to latest
git fetch upstream
git rebase upstream/{MAIN_BRANCH}

# 5. Push and create PR
git push origin feature/{PROJECT_KEY}-12345-description
```

---

## Troubleshooting Tasks

### Check Logs

```bash
# Container logs
kubectl logs -n {NAMESPACE} deployment/{DEPLOYMENT_NAME}

# Stream logs
kubectl logs -f -n {NAMESPACE} deployment/{DEPLOYMENT_NAME}
```

### Debug Failed Test

```bash
# Run with verbose output
pytest -vv tests/path/to/test.py::test_name

# Run with pdb on failure
pytest --pdb tests/path/to/test.py

# Run with print output
pytest -s tests/path/to/test.py

# See full traceback
pytest --tb=long tests/path/to/test.py
```

---

## Quick Reference

### Essential Commands

```bash
# Development
make fmt && make lint              # Format and check code
{TEST_COMMAND}                     # Run tests
pytest -k test_name                # Run specific test

# Git
git rebase -i HEAD~5               # Clean up commits
git push -f origin branch          # Force push after rebase

# Kubernetes (if applicable)
kubectl get pods -n {NAMESPACE}    # List pods
kubectl logs -f pod-name           # Stream logs
kubectl exec -it pod-name -- bash  # Shell into pod
```

---

## Placeholder Reference

Replace these when creating your project-specific version:

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{ORG}` | GitHub organization | `mlrun` |
| `{REPO}` | Repository name | `mlrun` |
| `{MAIN_BRANCH}` | Main branch name | `development` |
| `{PROJECT_KEY}` | Jira project key | `ML` |
| `{PACKAGE}` | Python package name | `mlrun` |
| `{TEST_COMMAND}` | Test command | `pytest` or `make test` |
| `{INSTALL_COMMAND}` | Install command | `pip install -e .` |
| `{DB_HOST}` | Database host | `localhost` |
| `{DB_USER}` | Database user | `postgres` |
| `{DB_PASSWORD}` | Database password | Store in Memory MCP |
| `{SSH_USER}` | SSH username | Store in Memory MCP |
| `{NAMESPACE}` | Kubernetes namespace | `mlrun` |

---

**Note**: For sensitive values (passwords, credentials), store them in:
1. **Memory MCP** - Persistent across sessions, not in version control
2. **Environment variables** - Set before running commands
3. **Project CLAUDE.md** - Only if repo is private

**Last Updated**: {DATE}
