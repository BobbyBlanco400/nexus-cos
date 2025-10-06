# Quick Fix: Database Connection (5 Minutes)

## 🎯 Problem
Health endpoint shows `db: "down"` because `DB_HOST=admin` doesn't resolve.

## ⚡ Quick Solution

### Step 1: Identify Your Database Location

Choose ONE of these:

**A) Local PostgreSQL** (database on same server)
```bash
DB_HOST=localhost
```

**B) Docker Container** (as per PF_ARCHITECTURE.md)
```bash
DB_HOST=nexus-cos-postgres
```

**C) Remote Server** (database on different server)
```bash
DB_HOST=your-db-ip-or-hostname
# Example: DB_HOST=192.168.1.100
# Example: DB_HOST=db.example.com
```

### Step 2: Update Configuration on Server

```bash
# SSH to server
ssh user@nexuscos.online

# Edit .env file
sudo nano /opt/nexus-cos/.env

# Update this line:
DB_HOST=localhost  # or your actual value from Step 1

# Save and exit (Ctrl+X, Y, Enter)
```

### Step 3: Restart Application

```bash
pm2 restart nexus-cos
```

### Step 4: Verify Fix

```bash
curl -s https://nexuscos.online/health | jq '.db'
```

**Expected Result**: `"up"` ✅

## 🔍 If Database Doesn't Exist Yet

### Option 1: Install PostgreSQL Locally

```bash
# Install
sudo apt update && sudo apt install postgresql postgresql-contrib -y

# Start service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create database
sudo -u postgres psql << EOF
CREATE DATABASE nexuscos_db;
CREATE USER nexuscos WITH ENCRYPTED PASSWORD 'YourSecurePassword';
GRANT ALL PRIVILEGES ON DATABASE nexuscos_db TO nexuscos;
\q
EOF

# Update .env
DB_HOST=localhost
DB_PASSWORD=YourSecurePassword

# Restart app
pm2 restart nexus-cos
```

### Option 2: Use Docker PostgreSQL

```bash
# Run PostgreSQL container
docker run -d \
  --name nexus-cos-postgres \
  -e POSTGRES_DB=nexuscos_db \
  -e POSTGRES_USER=nexuscos \
  -e POSTGRES_PASSWORD=SecurePass123 \
  -p 5432:5432 \
  postgres:15-alpine

# Update .env
DB_HOST=localhost  # or nexus-cos-postgres if app is in Docker
DB_PASSWORD=SecurePass123

# Restart app
pm2 restart nexus-cos
```

## ✅ Verification Checklist

- [ ] Updated DB_HOST in `/opt/nexus-cos/.env`
- [ ] Restarted PM2: `pm2 restart nexus-cos`
- [ ] Health check shows `db: "up"`: `curl -s https://nexuscos.online/health`
- [ ] No errors in logs: `pm2 logs nexus-cos`

## 🆘 Still Not Working?

Check logs for error details:
```bash
pm2 logs nexus-cos --lines 50
```

Common issues:
- **"Connection refused"**: Database not running → `systemctl status postgresql`
- **"Authentication failed"**: Wrong password → Check credentials in .env
- **"Database does not exist"**: Create it → See options above

## 📚 For More Details

See full documentation:
- `DATABASE_SETUP_GUIDE.md` - Complete database setup
- `NEXT_STEPS.md` - All post-deployment steps
- `DEPLOYMENT_STATUS_AND_NEXT_MOVES.md` - Strategic recommendations

## 💬 Tell PF Team

Once fixed, let PF know:
```
"Fixed! Updated DB_HOST to [your value]. 
Health now shows db: 'up'. 
Ready for next steps!"
```
