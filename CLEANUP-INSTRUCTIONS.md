# 🧹 R iRepair - Project Cleanup Instructions

## Overview

This document provides step-by-step instructions to clean up the R iRepair project by removing unused files and preparing it for clean deployment.

## What Will Be Removed

### 1. Backend Directory (Unused)
- **Path**: `backend/`
- **Reason**: The application uses Next.js API routes directly, no separate backend needed
- **Action**: Delete entire directory

### 2. Troubleshooting Documentation (50+ files)
All these `.md` files were created during debugging and are no longer needed:
- `SOLUTION-*.md` (Redis, Network, Admin Login, etc.)
- `DIAGNOSTIC-*.md`
- `RESUME-*.md`
- `GUIDE-CORRECTION-*.md`
- `GUIDE-FINAL-*.md`
- `GUIDE-NOUVELLES-*.md`
- `TODO-FIX-*.md`
- `README-FIX-*.md`
- `README-DEPLOIEMENT.md`
- `README-ARCHITECTURE.md`
- `DEPLOIEMENT-*.md`
- `ETAPES-DEPLOIEMENT.md`
- `INDEX-DEPLOIEMENT.md`
- `ROADMAP-DEPLOIEMENT.md`
- `COMMANDES-UTILES.md`
- `MIGRATION-TO-POSTGRESQL.md`
- `TEST-COMPLET.md`

### 3. Fix/Deploy Scripts (60+ files)
All these `.sh` scripts were temporary fixes:
- `fix-*.sh` (all fix scripts)
- `deploy-*.sh` (old deployment scripts)
- `clean-start*.sh`
- `cleanup-and-deploy.sh`
- `complete-database-setup.sh`
- `create-admin*.sh`
- `create-schedule-table-direct.sh`
- `diagnose*.sh`
- `force-*.sh`
- `full-diagnostic-and-cleanup.sh`
- `init-admin.sh`
- `install.sh`
- `quick-*.sh`
- `redeploy-*.sh`
- `restart-*.sh`
- `seed-database*.sh`
- `start-*.sh`
- `check-*.sh`

### 4. Unused Utilities
- `generate-*.js` (all hash generation scripts)
- `create-admin*.sql`
- `create-admin-user.sql`

### 5. Extra Docker Configs
- `docker-compose.simple.yml`
- `nginx.simple.conf`

### 6. Old Deploy Directory
- `deploy/` (contains old deployment scripts)

### 7. Database Cleanup
- `database/init-admin.js`
- `database/migrate-from-json.js`
- `database/seed-data-adapted.sql`
- `database/add-schedule-table.sql`

## What Will Be Kept

### Essential Files
- ✅ `frontend/` - The entire Next.js application
- ✅ `database/schema.sql` - PostgreSQL database structure
- ✅ `database/seeds.sql` - Initial data
- ✅ `docker-compose.yml` - Main deployment configuration
- ✅ `docker-compose.production.yml` - Production config (backup)
- ✅ `.env.example` - Environment template
- ✅ `.gitignore` - Git configuration
- ✅ `README.md` - Main documentation
- ✅ `DEPLOYMENT-GUIDE.md` - Deployment reference
- ✅ `TODO.md` - Project status
- ✅ `deploy.sh` - New simplified deployment script
- ✅ `nginx.conf` - Nginx configuration

## Manual Cleanup Steps

### Option 1: Using the Cleanup Script (Recommended)

Run the cleanup script that was created:

```cmd
.\cleanup-project.bat
```

This will:
1. Create a backup in `.cleanup-backup/`
2. Remove all unused files
3. Update README.md
4. Configure docker-compose.yml

### Option 2: Manual Cleanup

If the script doesn't work, follow these steps:

#### Step 1: Create Backup
```cmd
mkdir .cleanup-backup
xcopy /E /I frontend .cleanup-backup\frontend
xcopy /E /I database .cleanup-backup\database
copy docker-compose.frontend-only.yml .cleanup-backup\
copy README.md .cleanup-backup\
```

#### Step 2: Remove Backend
```cmd
rmdir /S /Q backend
```

#### Step 3: Remove Documentation
```cmd
del /Q SOLUTION-*.md
del /Q DIAGNOSTIC-*.md
del /Q RESUME-*.md
del /Q GUIDE-*.md
del /Q TODO-FIX-*.md
del /Q README-FIX-*.md
del /Q README-DEPLOIEMENT.md
del /Q README-ARCHITECTURE.md
del /Q DEPLOIEMENT-*.md
del /Q ETAPES-DEPLOIEMENT.md
del /Q INDEX-DEPLOIEMENT.md
del /Q ROADMAP-DEPLOIEMENT.md
del /Q COMMANDES-UTILES.md
del /Q MIGRATION-TO-POSTGRESQL.md
del /Q TEST-COMPLET.md
```

#### Step 4: Remove Scripts
```cmd
del /Q fix-*.sh
del /Q deploy-*.sh
del /Q clean-start*.sh
del /Q cleanup-and-deploy.sh
del /Q complete-database-setup.sh
del /Q create-admin*.sh
del /Q create-schedule-table-direct.sh
del /Q diagnose*.sh
del /Q force-*.sh
del /Q full-diagnostic-and-cleanup.sh
del /Q init-admin.sh
del /Q install.sh
del /Q quick-*.sh
del /Q redeploy-*.sh
del /Q restart-*.sh
del /Q seed-database*.sh
del /Q start-*.sh
del /Q check-*.sh
```

#### Step 5: Remove Utilities
```cmd
del /Q generate-*.js
del /Q create-admin*.sql
del /Q create-admin-user.sql
```

#### Step 6: Remove Extra Configs
```cmd
del /Q docker-compose.simple.yml
del /Q nginx.simple.conf
rmdir /S /Q deploy
```

#### Step 7: Clean Database Directory
```cmd
del /Q database\init-admin.js
del /Q database\migrate-from-json.js
del /Q database\seed-data-adapted.sql
del /Q database\add-schedule-table.sql
```

#### Step 8: Update Files
```cmd
REM Replace README
del README.md
ren README-NEW.md README.md

REM Setup docker-compose
ren docker-compose.yml docker-compose.old.yml
copy docker-compose.production.yml docker-compose.yml
```

## After Cleanup

### Final Project Structure
```
R-iRepair/
├── frontend/                    # Next.js application
│   ├── src/
│   │   ├── app/                # Pages and API routes
│   │   ├── components/         # React components
│   │   └── lib/                # Utilities and DB connection
│   ├── Dockerfile
│   └── package.json
├── database/                    # PostgreSQL setup
│   ├── schema.sql              # Database structure
│   └── seeds.sql               # Initial data
├── docker-compose.yml           # Main deployment config
├── docker-compose.production.yml # Production backup
├── deploy.sh                    # Deployment script
├── .env.example                 # Environment template
├── .gitignore                   # Git configuration
├── nginx.conf                   # Nginx configuration
├── README.md                    # Documentation
├── DEPLOYMENT-GUIDE.md          # Deployment guide
└── TODO.md                      # Project status
```

### Next Steps

1. **Configure Environment**
   ```cmd
   copy .env.example .env
   notepad .env
   ```
   Update the database password and other settings.

2. **Deploy the Application**
   ```cmd
   docker-compose up -d
   ```

3. **Verify Deployment**
   ```cmd
   docker-compose ps
   curl http://localhost:3000
   ```

4. **Access the Application**
   - Frontend: http://localhost:3000
   - Admin: http://localhost:3000/admin/login
   - Credentials: `admin` / `admin123`

## Troubleshooting

### If cleanup script fails
- Use the manual cleanup steps above
- Check file permissions
- Close any open files in VSCode

### If files are locked
- Close VSCode
- Close any terminals
- Run cleanup again

### Backup Location
All important files are backed up in `.cleanup-backup/` directory.

## Summary

This cleanup will:
- ✅ Remove ~150 unused files
- ✅ Keep ~40 essential files
- ✅ Reduce project size by ~70%
- ✅ Make deployment much simpler
- ✅ Improve project maintainability

---

**Note**: A backup is automatically created in `.cleanup-backup/` before any files are deleted.
