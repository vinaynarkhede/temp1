# PostgREST Installation Guide

## Overview

PostgREST automatically generates a REST API from your PostgreSQL database schema. This guide covers installation on various platforms.

## Prerequisites

- PostgreSQL 9.5 or higher (we have PostgreSQL 16)
- Database with schema and permissions configured

---

## Installation Methods

### Method 1: Pre-built Binary (Recommended)

**Linux (x64):**
```bash
# Download the latest release
wget https://github.com/PostgREST/postgrest/releases/download/v12.0.2/postgrest-v12.0.2-linux-static-x64.tar.xz

# Extract
tar xf postgrest-v12.0.2-linux-static-x64.tar.xz

# Make executable
chmod +x postgrest

# Move to system path
sudo mv postgrest /usr/local/bin/

# Verify installation
postgrest --version
```

**macOS:**
```bash
# Using Homebrew
brew install postgrest

# Verify
postgrest --version
```

**Windows:**
1. Download from: https://github.com/PostgREST/postgrest/releases
2. Extract `postgrest.exe`
3. Add to PATH or run from directory

---

### Method 2: Docker (Alternative)

```bash
# Pull the image
docker pull postgrest/postgrest

# Run PostgREST
docker run --rm -p 3000:3000 \
  -v $(pwd)/postgrest.conf:/etc/postgrest.conf \
  postgrest/postgrest

# Or use docker-compose.yml:
cat > docker-compose.yml << 'EOF'
version: '3'
services:
  postgrest:
    image: postgrest/postgrest
    ports:
      - "3000:3000"
    environment:
      PGRST_DB_URI: postgres://myapp_user:password@localhost:5432/myapp_db
      PGRST_DB_SCHEMAS: public
      PGRST_DB_ANON_ROLE: web_anon
      PGRST_JWT_SECRET: your-secret-key
    restart: always
EOF

docker-compose up -d
```

---

### Method 3: Build from Source

**Requirements:**
- Stack (Haskell build tool)
- GHC (Glasgow Haskell Compiler)

```bash
# Install Stack
curl -sSL https://get.haskellstack.org/ | sh

# Clone repository
git clone https://github.com/PostgREST/postgrest.git
cd postgrest

# Build and install
stack install

# Verify
postgrest --version
```

---

## Configuration

### 1. Create Configuration File

Create `postgrest.conf`:

```ini
# Database connection
db-uri = "postgres://myapp_user:secure_password@localhost:5432/myapp_db"
db-schemas = "public"
db-anon-role = "web_anon"
db-pool = 10

# Server settings
server-host = "localhost"
server-port = 3000

# JWT Authentication
jwt-secret = "+8JzgQ2jvhuM0599SeDxAZi690cif2H9F0fDiRvy06U="
jwt-secret-is-base64 = true

# API documentation
openapi-mode = "follow-privileges"
openapi-server-proxy-uri = "http://localhost:3000"

# Logging
log-level = "info"
```

### 2. Generate JWT Secret

```bash
# Generate a secure secret
openssl rand -base64 32

# Use this in postgrest.conf as jwt-secret
```

### 3. Environment Variables (Optional)

Instead of storing secrets in config file:

```bash
# Set environment variables
export PGRST_DB_URI="postgres://myapp_user:password@localhost:5432/myapp_db"
export PGRST_JWT_SECRET="your-secret-key"

# Update postgrest.conf to use them
db-uri = "env:PGRST_DB_URI"
jwt-secret = "env:PGRST_JWT_SECRET"
```

---

## Starting PostgREST

### Foreground (for testing)

```bash
postgrest postgrest.conf
```

### Background

```bash
# Linux/macOS
nohup postgrest postgrest.conf > postgrest.log 2>&1 &

# Check if running
curl http://localhost:3000/

# View logs
tail -f postgrest.log
```

### System Service (Linux)

Create `/etc/systemd/system/postgrest.service`:

```ini
[Unit]
Description=PostgREST REST API
After=postgresql.service

[Service]
Type=simple
User=postgres
WorkingDirectory=/opt/postgrest
ExecStart=/usr/local/bin/postgrest /opt/postgrest/postgrest.conf
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl enable postgrest
sudo systemctl start postgrest
sudo systemctl status postgrest
```

---

## Verification

### 1. Check PostgREST is Running

```bash
# Should return OpenAPI specification
curl http://localhost:3000/

# Should return JSON
curl http://localhost:3000/ | jq
```

### 2. Test API Endpoints

```bash
# Get published posts
curl http://localhost:3000/posts?published=eq.true

# Test user registration
curl -X POST http://localhost:3000/rpc/register_user \
  -H "Content-Type: application/json" \
  -d '{"p_email":"test@example.com","p_password":"password123","p_full_name":"Test User"}'
```

### 3. Run Integration Tests

```bash
node tests/api_tests.js
```

---

## Network Restrictions Workaround

If you cannot download PostgREST directly:

### Option 1: Download on Another Machine

1. Download on a machine with internet access
2. Transfer file via USB or secure copy
3. Install on target machine

### Option 2: Use Package Manager

```bash
# Ubuntu/Debian
sudo apt install postgrest

# Arch Linux
yay -S postgrest

# Check version
postgrest --version
```

### Option 3: Use Docker (if Docker is available)

```bash
docker pull postgrest/postgrest
docker save postgrest/postgrest > postgrest-docker.tar
# Transfer postgrest-docker.tar to target machine
docker load < postgrest-docker.tar
```

---

## Troubleshooting

### PostgREST Won't Start

**Check configuration:**
```bash
# Test config syntax
postgrest postgrest.conf --example
```

**Check database connection:**
```bash
psql "postgres://myapp_user:password@localhost:5432/myapp_db" -c "SELECT 1;"
```

**Check port availability:**
```bash
lsof -i :3000
netstat -tuln | grep 3000
```

### Permission Denied Errors

**Check database roles:**
```sql
SELECT * FROM pg_roles WHERE rolname IN ('myapp_user', 'web_anon', 'authenticated');
```

**Check grants:**
```sql
\dp
SELECT * FROM information_schema.role_table_grants WHERE grantee = 'web_anon';
```

### RLS Blocking Requests

**Temporarily disable for debugging:**
```sql
ALTER TABLE posts DISABLE ROW LEVEL SECURITY;
```

**Check JWT claims:**
```sql
SELECT current_setting('request.jwt.claims', true);
```

---

## Configuration Options Reference

| Option | Description | Example |
|--------|-------------|---------|
| `db-uri` | PostgreSQL connection string | `postgres://user:pass@host:5432/db` |
| `db-schemas` | Schemas to expose | `public` |
| `db-anon-role` | Role for anonymous requests | `web_anon` |
| `db-pool` | Connection pool size | `10` |
| `server-host` | Listen address | `localhost` or `0.0.0.0` |
| `server-port` | Listen port | `3000` |
| `jwt-secret` | JWT signing secret | Base64 encoded string |
| `log-level` | Logging verbosity | `info`, `debug`, `error` |

---

## Security Recommendations

1. **Use environment variables** for secrets
2. **Enable SSL/TLS** in production
3. **Use strong JWT secret** (32+ random bytes)
4. **Restrict server-host** to localhost if using reverse proxy
5. **Enable rate limiting** at reverse proxy level
6. **Monitor logs** for suspicious activity
7. **Keep PostgREST updated** to latest version

---

## Production Deployment

### Reverse Proxy (nginx)

```nginx
upstream postgrest {
    server localhost:3000;
}

server {
    listen 443 ssl http2;
    server_name api.example.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://postgrest;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### SSL Configuration

Update `postgrest.conf`:
```ini
server-host = "localhost"
server-port = 3000
# Let nginx handle SSL
```

---

## Additional Resources

- **Official Docs:** https://postgrest.org/en/stable/
- **GitHub:** https://github.com/PostgREST/postgrest
- **Tutorial:** https://postgrest.org/en/stable/tutorials/tut0.html
- **API Reference:** https://postgrest.org/en/stable/references/api.html
- **Community:** https://github.com/PostgREST/postgrest/discussions

---

**Next Steps:** Once PostgREST is installed and running, test the API with the integration test suite!
