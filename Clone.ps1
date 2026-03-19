# Paths
$vaultPath   = "F:\Emanuel Ser\Emanuel Ser's Vault"
$quartzPath  = "C:\Users\Emmanuel Ser\Documents\Rêverie\quartz"
$contentPath = Join-Path $quartzPath "content"

Write-Host "Starting publish script..."

# Step 1: Sync vault → content
if (Test-Path $contentPath) {
    Write-Host "Syncing $vaultPath -> $contentPath"
    robocopy "$vaultPath" "$contentPath" /MIR /E /XD "Private" "Archive"
}
else {
    Write-Host "Content folder not found, creating..."
    New-Item -ItemType Directory -Path $contentPath | Out-Null
    robocopy "$vaultPath" "$contentPath" /E /XD "Private" "Archive"
}
Write-Host "Sync complete."

# Step 2: Change to repo
Set-Location $quartzPath
Write-Host "Now inside repo: $(Get-Location)"

# Step 3: Check for changes
$changes = git status --porcelain
if (-not $changes) {
    Write-Host "No changes detected. Nothing to commit."
    exit 0
}

# Step 4: Stage changes
Write-Host "Staging changes..."
git add .

# Step 5: Commit
$timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$commitMessage = "Publish site $timeStamp"
Write-Host "Committing with message: $commitMessage"
git commit -m "$commitMessage"

# Step 6: Push
Write-Host "Pushing to branch v4..."
git push origin v4

Write-Host "Publish complete!"