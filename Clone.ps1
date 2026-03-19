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