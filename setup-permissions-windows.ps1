# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
   Write-Warning "Please run this script as Administrator!"
   Break
}

Write-Host "Setting up permissions for AlgoMon persistent storage on Windows..."

# Create data directories if they don't exist
$directories = @(
   "elasticsearch\data",
   "prometheus\data",
   "grafana\data"
)

foreach ($dir in $directories) {
   if (-not (Test-Path $dir)) {
      New-Item -ItemType Directory -Force -Path $dir | Out-Null
      Write-Host "Created directory: $dir"
   }
}

# Set permissions for each directory
foreach ($dir in $directories) {
   Write-Host "Setting permissions for $dir..."
   try {
      $acl = Get-Acl $dir
      $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
         "Users",
         "FullControl",
         "ContainerInherit,ObjectInherit",
         "None",
         "Allow"
      )
      $acl.SetAccessRule($accessRule)
      Set-Acl $dir $acl
      Write-Host "Successfully set permissions for $dir"
   }
   catch {
      Write-Error ("Failed to set permissions for {0}: {1}" -f $dir, $PSItem.ToString())
   }
}

Write-Host "`nDone! All permissions have been set correctly."
Write-Host "You can now run 'docker compose up -d' to start AlgoMon."
Write-Host "`nPress any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")