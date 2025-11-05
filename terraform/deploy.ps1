# Use environment variable WORKSPACE provided by Jenkins
$WORKSPACE_DIR = $env:WORKSPACE
if (-not $WORKSPACE_DIR) {
    throw "❌ WORKSPACE environment variable not set. Are you running this inside Jenkins?"
}

$DEPLOY_DIR = "C:\nginx\html\stellartrack"
$BACKUP_DIR = "C:\nginx\html\stellartrack_backup"
$SITE_SOURCE = Join-Path $WORKSPACE_DIR "site"

try {
    # Cleanup previous backup
    if (Test-Path $BACKUP_DIR) {
        Remove-Item $BACKUP_DIR -Recurse -Force -ErrorAction Stop
    }

    # Create new backup (only website files)
    if (Test-Path $DEPLOY_DIR) {
        New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
        Get-ChildItem $DEPLOY_DIR -File | ForEach-Object {
            Copy-Item $_.FullName $BACKUP_DIR -Force -ErrorAction Stop
        }
        Write-Host "✅ Backup created at $BACKUP_DIR"
    }

    # Validate source directory
    if (-not (Test-Path $SITE_SOURCE)) {
        throw "❌ Source directory missing: $SITE_SOURCE"
    }

    # Clean and prepare deployment directory
    if (Test-Path $DEPLOY_DIR) {
        Remove-Item "$DEPLOY_DIR\*" -Recurse -Force -ErrorAction Stop
    }
    else {
        New-Item -ItemType Directory -Path $DEPLOY_DIR -Force | Out-Null
    }

    # Deploy new files
    Copy-Item "$SITE_SOURCE\*" $DEPLOY_DIR -Recurse -Force -ErrorAction Stop

    # Verify deployment
    $indexPath = Join-Path $DEPLOY_DIR "index.html"
    if (-not (Test-Path $indexPath)) {
        throw "❌ Deployment failed: index.html missing"
    }

    # Check for merge conflicts
    $indexContent = Get-Content $indexPath -Raw
    if ($indexContent -match '<<<<<<< HEAD|=======|>>>>>>>') {
        throw "❌ Merge conflict detected in index.html"
    }

    Write-Host "🚀 Deployment successful!"
    Write-Host "📄 index.html preview:"
    $indexContent.Substring(0, [Math]::Min(200, $indexContent.Length)) + "..."
}
catch {
    Write-Host "❌ Critical error: $_"
    exit 1
}
