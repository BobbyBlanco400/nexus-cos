# TRAE SOLO Final Repo Cleanup & Push Script
# Purpose: Remove Puppeteer binaries from history, clean repo, and push safely.

# Exit on any error
$ErrorActionPreference = "Stop"

# 1️⃣ Ensure script is run from repo root
$REPO_ROOT = git rev-parse --show-toplevel
Set-Location $REPO_ROOT

Write-Host "✅ Working from repo root: $REPO_ROOT"

# 2️⃣ Backup current branch
$CURRENT_BRANCH = git rev-parse --abbrev-ref HEAD
git checkout -b "${CURRENT_BRANCH}-backup"
Write-Host "✅ Backup branch created: ${CURRENT_BRANCH}-backup"

# 3️⃣ Install git-filter-repo if missing
if (-not (Get-Command git-filter-repo -ErrorAction SilentlyContinue)) {
    Write-Host "⚡ Installing git-filter-repo..."
    pip install git-filter-repo
}

# 4️⃣ Remove Puppeteer binaries from Git history
Write-Host "⚡ Removing .cache/puppeteer/ from history..."
git filter-repo --path .cache/puppeteer/ --invert-paths --force

# 5️⃣ Ensure .gitignore has Puppeteer cache ignored
$gitignoreContent = Get-Content .gitignore -ErrorAction SilentlyContinue
if (-not ($gitignoreContent -contains ".cache/puppeteer/")) {
    Add-Content -Path .gitignore -Value ".cache/puppeteer/"
    git add .gitignore
    git commit -m "Add Puppeteer cache to .gitignore"
    Write-Host "✅ Updated .gitignore"
}

# 6️⃣ Optional: Track Puppeteer binaries via Git LFS (if needed)
$lfsTracked = git lfs track 2>$null
if (-not ($lfsTracked -match ".cache/puppeteer")) {
    Write-Host "⚡ Tracking Puppeteer binaries via Git LFS..."
    git lfs track ".cache/puppeteer/**"
    git add .gitattributes
    git commit -m "Track Puppeteer binaries via Git LFS"
}

# 7️⃣ Repack and clean repository
Write-Host "⚡ Running aggressive git garbage collection..."
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# 8️⃣ Ensure remote is set
$remoteExists = $null
try {
    $remoteExists = git remote get-url origin 2>$null
} catch {
    # Remote doesn't exist
}

if (-not $remoteExists) {
    git remote add origin git@github.com:BobbyBlanco400/nexus-cos.git
}

# 9️⃣ Force push cleaned branch
Write-Host "⚡ Force pushing cleaned branch to origin..."
git push -u origin "$CURRENT_BRANCH" --force

Write-Host "🎉 Repo cleanup complete and branch pushed: $CURRENT_BRANCH"