param([ValidateSet('build','start','update','stop','status','logs','check')][string]$Command='start')
$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
function Invoke-SiteNative([string]$Program,[string[]]$Arguments) {
  & $Program @Arguments
  if ($LASTEXITCODE -ne 0) { throw "$Program failed with exit code $LASTEXITCODE" }
}
try {
  $env:XSOLUTIONS_REVISION=(git rev-parse HEAD).Trim()
  if ($Command -eq 'update') {
    $branch=(git branch --show-current).Trim()
    if ($branch -notin @('main','dev')) { throw 'Update requires the dev or main branch.' }
    if (git status --porcelain --untracked-files=all) { throw 'Commit or stash local changes before updating.' }
    Invoke-SiteNative git @('fetch','origin',$branch)
    Invoke-SiteNative git @('merge','--ff-only',"origin/$branch")
    $env:XSOLUTIONS_REVISION=(git rev-parse HEAD).Trim()
  }
  $base=@('compose','-f','compose.local.yaml')
  switch ($Command) {
    { $_ -in 'build','start','update' } {
      Invoke-SiteNative docker ($base + @('build'))
      if ($Command -ne 'build') {
        Invoke-SiteNative docker ($base + @('up','-d','--no-build','--wait','--wait-timeout','90'))
        $port=if($env:XSOLUTIONS_PORT){$env:XSOLUTIONS_PORT}else{'8787'}
        Write-Host "Local website: http://localhost:$port"
      }
    }
    'stop' { Invoke-SiteNative docker ($base + @('down')) }
    'status' { Invoke-SiteNative docker ($base + @('ps')) }
    'logs' { Invoke-SiteNative docker ($base + @('logs','--tail','80')) }
    'check' {
      $gitBash=Join-Path (Split-Path (Split-Path (Get-Command git).Source)) 'bin/bash.exe'
      if (!(Test-Path $gitBash)) { throw 'Use Git Bash and run bash scripts/check.sh.' }
      Invoke-SiteNative $gitBash @('scripts/check.sh')
    }
  }
} finally { Pop-Location }
