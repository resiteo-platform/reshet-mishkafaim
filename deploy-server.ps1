# Deploys Reshet Mishkafaim from this computer to the server (SSH accepts only this computer's IP).
# Packs this folder with tar, uploads it to ~/reshet-mishkafaim on the server and runs Docker Compose there.
# Usage (PowerShell, in this folder):
#   .\deploy-server.ps1 -Server SSH_USER@SERVER_IP
#   .\deploy-server.ps1 -Server SSH_USER@SERVER_IP -Port 2222
# The SSH password is asked twice: once for the upload and once for the deployment.
param(
    [Parameter(Mandatory = $true)][string]$Server,
    [int]$Port = 22
)
$ErrorActionPreference = 'Stop'

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$archive = Join-Path $env:TEMP "reshet-mishkafaim-$stamp.tar.gz"
$remoteArchive = "/tmp/reshet-mishkafaim-$stamp.tar.gz"

# Secrets (.env*), build output and the local database (.data) stay here.
Write-Host 'Packing ...'
& "$env:SystemRoot\System32\tar.exe" -czf $archive -C $PSScriptRoot `
    --exclude=.git --exclude=node_modules --exclude=.data --exclude=.openai `
    --exclude=dist --exclude='.env*' --exclude='*.zip' --exclude='*.tar.gz' .
if ($LASTEXITCODE -ne 0) { throw 'Packing failed.' }

try {
    Write-Host "Uploading to $Server ..."
    scp -P $Port $archive "${Server}:$remoteArchive"
    if ($LASTEXITCODE -ne 0) { throw 'Upload failed.' }

    Write-Host 'Deploying on the server ...'
    $remote = "set -eu; mkdir -p ~/reshet-mishkafaim; tar -xzf '$remoteArchive' -C ~/reshet-mishkafaim; rm -f '$remoteArchive'; cd ~/reshet-mishkafaim; " +
        "docker compose -f docker-compose.prod.yml config --quiet; " +
        "docker compose -f docker-compose.prod.yml up -d --build --remove-orphans; " +
        "docker compose -f docker-compose.prod.yml ps; docker image prune -f"
    ssh -p $Port $Server $remote
    if ($LASTEXITCODE -ne 0) { throw 'Deployment failed on the server. See the output above.' }
    Write-Host 'Done.'
}
finally {
    if (Test-Path $archive) { Remove-Item $archive -Force }
}
