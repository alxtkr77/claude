# Docker Image Security Scanner Guide

Complete guide for scanning Docker images for vulnerabilities from offline registry storage.

## Prerequisites

- Docker installed and running
- Access to offline registry storage (e.g., `/mnt/igz-bugs/offline_versions/`)
- Sufficient disk space for pulling images

---

## Step 1: Start Local Registry from Mounted Storage

When you have Docker images stored in an offline registry directory:

```bash
# Example: Start local registry on port 6001
docker run -d \
  -p 6001:5000 \
  --name local-registry-scanner \
  -v /mnt/igz-bugs/offline_versions/3.7.1-rocky8.b87.20251023135613/docker_registry:/var/lib/registry \
  registry:2

# Wait a few seconds for registry to start
sleep 5

# Verify registry is running
docker ps | grep local-registry-scanner
```

### List Available Images

```bash
# List all repositories in the registry
curl -s http://localhost:6001/v2/_catalog | python3 -m json.tool

# List tags for a specific image (e.g., iguazio/webapi)
curl -s http://localhost:6001/v2/iguazio/webapi/tags/list | python3 -m json.tool
```

---

## Step 2: Pull the Image

```bash
# Pull the specific image tag
docker pull localhost:6001/iguazio/webapi:3.7.1-rocky8.b87.20251023135613

# Verify the image was pulled
docker images | grep webapi
```

### Optional: Tag for External Registry

```bash
# Tag for pushing to artifactory or other registry
docker tag \
  localhost:6001/iguazio/webapi:3.7.1-rocky8.b87.20251023135613 \
  artifactory.iguazeng.com:6555/iguazio/webapi:3.7.1-rocky8.b87.20251023135613
```

---

## Step 3: Scan with Trivy

**Trivy** is recommended for accuracy and ease of use.

### Basic Scan (HIGH and CRITICAL only)

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest image \
  --severity HIGH,CRITICAL \
  localhost:6001/iguazio/webapi:3.7.1-rocky8.b87.20251023135613
```

### Full Scan (All Severities)

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest image \
  localhost:6001/iguazio/webapi:3.7.1-rocky8.b87.20251023135613
```

### JSON Output for Processing

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest image \
  --format json \
  --severity HIGH,CRITICAL \
  localhost:6001/iguazio/webapi:3.7.1-rocky8.b87.20251023135613 \
  > trivy-scan-results.json
```

### Search for Specific CVEs

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest image \
  localhost:6001/iguazio/webapi:3.7.1-rocky8.b87.20251023135613 \
  | grep -E "(CVE-2024-6345|setuptools|pam)"
```

---

## Step 4: Scan with Grype

**Grype** is another excellent scanner with different vulnerability databases.

### Basic Scan

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  anchore/grype:latest \
  localhost:6001/iguazio/webapi:3.7.1-rocky8.b87.20251023135613
```

### High and Critical Only

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  anchore/grype:latest \
  --fail-on high \
  localhost:6001/iguazio/webapi:3.7.1-rocky8.b87.20251023135613
```

### JSON Output

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  anchore/grype:latest \
  -o json \
  localhost:6001/iguazio/webapi:3.7.1-rocky8.b87.20251023135613 \
  > grype-scan-results.json
```

---

## Step 5: Manual Verification

### Verify Specific Package Versions

```bash
# Check Python setuptools version
docker run --rm localhost:6001/iguazio/webapi:3.7.1-rocky8.b87.20251023135613 \
  python3 -c "import setuptools; print(f'setuptools: {setuptools.__version__}')"

# List all pip packages
docker run --rm localhost:6001/iguazio/webapi:3.7.1-rocky8.b87.20251023135613 \
  python3 -m pip list

# Check OS version
docker run --rm localhost:6001/iguazio/webapi:3.7.1-rocky8.b87.20251023135613 \
  cat /etc/os-release

# Check for specific library files
docker run --rm localhost:6001/iguazio/webapi:3.7.1-rocky8.b87.20251023135613 \
  ls -la /lib64/libpam*
```

### Check RPM Database Status

```bash
# Note: Some images remove the RPM database for security
docker run --rm localhost:6001/iguazio/webapi:3.7.1-rocky8.b87.20251023135613 \
  sh -c "rpm -qa 2>&1 | head -20 || echo 'RPM database removed or empty'"
```

---

## Step 6: Understanding False Positives

### Common Causes of False Positives

1. **Removed RPM Database**
   - Many security-hardened images remove `/var/lib/rpm` to reduce attack surface
   - Scanners that rely solely on RPM database will misreport vulnerabilities

2. **PyPI vs RPM Package Confusion**
   - Scanner may detect old system setuptools (RPM) but miss pip-installed version
   - Example: `rpm://setuptools:39.2.0` vs `pypi://setuptools:80.9.0`

3. **Library Files Without Package Metadata**
   - Libraries may exist from `dnf update` but no metadata remains after RPM database removal

4. **Outdated Scanner Databases**
   - Ensure scanner database is up-to-date: `trivy image --download-db-only`

### Verification Checklist

If a scanner reports a vulnerability, verify:

- ✅ **Package actually exists**: Check with `docker run --rm <image> which <package>`
- ✅ **Check actual version**: Import the module or check file directly
- ✅ **Verify in multiple scanners**: Trivy and Grype should agree on real issues
- ✅ **Check image build date**: Vulnerability may be fixed but scanner outdated

---

## Step 7: Interpreting Results

### Example: setuptools Vulnerability Report

**Scanner Reports:**
```
CVE-2024-6345 | setuptools:39.2.0 | CRITICAL
CVE-2025-47273 | setuptools:39.2.0 | CRITICAL
```

**Verification:**
```bash
# Check actual version
docker run --rm localhost:6001/iguazio/webapi:3.7.1-rocky8.b87.20251023135613 \
  python3 -c "import setuptools; print(setuptools.__version__)"
# Output: 80.9.0

# Check installation location
docker run --rm localhost:6001/iguazio/webapi:3.7.1-rocky8.b87.20251023135613 \
  python3 -m pip show setuptools
# Output: Version: 80.9.0, Location: /usr/local/lib/python3.9/site-packages
```

**Conclusion:** FALSE POSITIVE - setuptools 80.9.0 is installed, not 39.2.0

---

## Step 8: Cleanup

```bash
# Stop and remove the local registry
docker stop local-registry-scanner
docker rm local-registry-scanner

# Optional: Remove pulled images
docker rmi localhost:6001/iguazio/webapi:3.7.1-rocky8.b87.20251023135613
```

---

## Common Issues and Solutions

### Issue: "package not installed" but scanner reports vulnerability

**Cause:** Package was removed but leftover files confuse scanner

**Solution:**
```bash
# Search for actual files
docker run --rm <image> find / -name "*packagename*" 2>/dev/null
```

### Issue: Different scanners report different results

**Cause:** Different vulnerability databases and detection methods

**Solution:** Trust the scanner that:
- Correctly identifies the actual installed version
- Has the most recent database update
- Agrees with manual verification

### Issue: Cannot access RPM database

**Cause:** Dockerfile removes `/var/lib/rpm` for security

**Impact:**
- ✅ Trivy: Still works (uses file analysis)
- ✅ Grype: Still works (uses multiple detection methods)
- ❌ RPM-only scanners: Will fail or misreport

---

## Best Practices

1. **Always verify with multiple scanners** - Trivy + Grype recommended
2. **Check actual package versions manually** when high-severity CVEs reported
3. **Keep scanner databases updated** - `docker pull aquasec/trivy:latest`
4. **Document false positives** for compliance audits
5. **Rebuild images regularly** to get latest security patches from `dnf update`
6. **Pin critical package versions** in Dockerfile (e.g., `setuptools==80.9.0`)

---

## Quick Reference Commands

```bash
# Start local registry
docker run -d -p 6001:5000 --name reg -v <path>:/var/lib/registry registry:2

# List images
curl -s http://localhost:6001/v2/_catalog

# Pull image
docker pull localhost:6001/<image>:<tag>

# Scan with Trivy
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image <image>

# Scan with Grype
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock anchore/grype:latest <image>

# Verify package
docker run --rm <image> python3 -m pip show <package>

# Cleanup
docker stop reg && docker rm reg
```

---

## Example: Complete Workflow

```bash
#!/bin/bash
# Complete security scan workflow

IMAGE_TAG="3.7.1-rocky8.b87.20251023135613"
REGISTRY_PATH="/mnt/igz-bugs/offline_versions/${IMAGE_TAG}/docker_registry"
IMAGE_NAME="iguazio/webapi:${IMAGE_TAG}"

# 1. Start registry
docker run -d -p 6001:5000 --name scanner-registry \
  -v ${REGISTRY_PATH}:/var/lib/registry registry:2

sleep 5

# 2. Pull image
docker pull localhost:6001/${IMAGE_NAME}

# 3. Scan with Trivy
echo "=== Trivy Scan ==="
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest image --severity HIGH,CRITICAL \
  localhost:6001/${IMAGE_NAME} | tee trivy-results.txt

# 4. Scan with Grype
echo "=== Grype Scan ==="
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  anchore/grype:latest localhost:6001/${IMAGE_NAME} | tee grype-results.txt

# 5. Manual verification of critical packages
echo "=== Manual Verification ==="
echo "Python version:"
docker run --rm localhost:6001/${IMAGE_NAME} python3 --version

echo "Setuptools version:"
docker run --rm localhost:6001/${IMAGE_NAME} \
  python3 -c "import setuptools; print(setuptools.__version__)"

echo "OS version:"
docker run --rm localhost:6001/${IMAGE_NAME} cat /etc/os-release

# 6. Cleanup
docker stop scanner-registry
docker rm scanner-registry

echo "Scan complete. Results saved to trivy-results.txt and grype-results.txt"
```

---

**Last Updated:** November 2025
**Tested With:** Trivy v0.x, Grype v0.x, Docker v24.x
