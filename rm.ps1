$ErrorActionPreference = 'Stop'
$workDir = Join-Path $env:TEMP 'AnyremTool'
New-Item -ItemType Directory -Path $workDir -Force | Out-Null

function Pause-Menu {
    Write-Host ''
    [void](Read-Host 'Press Enter to return to menu')
}

function Download-File {
    param(
        [Parameter(Mandatory=$true)][string]$Url,
        [Parameter(Mandatory=$true)][string]$Name
    )
    $path = Join-Path $workDir $Name
    Invoke-WebRequest -Uri $Url -OutFile $path -UseBasicParsing -ErrorAction Stop
    Write-Host "Downloaded: $path" -ForegroundColor Green
    Write-Host 'SHA256 (compare with a trusted value):' -ForegroundColor Cyan
    Write-Host (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
    return $path
}

function Show-Menu {
    while ($true) {
        Clear-Host
        Write-Host '========================================' -ForegroundColor Cyan
        Write-Host '                Any Tool' -ForegroundColor Yellow
        Write-Host '========================================' -ForegroundColor Cyan
        Write-Host ''
        Write-Host '[1] Windows Security / Firewall'
        Write-Host '[2] Download EI Application'
        Write-Host '[3] Download DE Script'
        Write-Host '[4] Download DWAgent'
        Write-Host ''
        Write-Host '[0] Exit & Cleanup' -ForegroundColor Red
        Write-Host ''
        Write-Host 'Select an option: ' -NoNewline -ForegroundColor Green
        $key = [Console]::ReadKey($true).KeyChar
        Write-Host $key
        try {
            switch ($key) {
                '1' {
                    Write-Host "`nWindows Firewall Status:" -ForegroundColor Cyan
                    Get-NetFirewallProfile | Select-Object Name, Enabled | Format-Table -AutoSize
                    Write-Host 'Microsoft Defender Status:' -ForegroundColor Cyan
                    Get-MpComputerStatus | Select-Object RealTimeProtectionEnabled | Format-Table -AutoSize
                    Pause-Menu
                }
                '2' {
                    $file = Download-File -Url 'https://raw.githubusercontent.com/icic2k/icic2k/main/ei.exe' -Name 'ei.exe'
                    Write-Host "Review and verify before executing: $file" -ForegroundColor Yellow
                    Pause-Menu
                }
                '3' {
                    $file = Download-File -Url 'https://raw.githubusercontent.com/suraj1863/itit2k/main/de.bat' -Name 'de.bat'
                    Write-Host "`nBatch script contents:" -ForegroundColor Cyan
                    Get-Content -LiteralPath $file
                    Pause-Menu
                }
                '4' {
                    $zip = Download-File -Url 'https://raw.githubusercontent.com/suraj1863/itit2k/main/dwagent_x86.zip' -Name 'dw.zip'
                    $folder = Join-Path $workDir 'DWAgent'
                    New-Item -ItemType Directory -Path $folder -Force | Out-Null
                    Expand-Archive -LiteralPath $zip -DestinationPath $folder -Force
                    Write-Host "`nExtracted files:" -ForegroundColor Cyan
                    Get-ChildItem -LiteralPath $folder -Recurse -File | Select-Object FullName, Length | Format-Table -AutoSize
                    Write-Host 'Verify the installer before launching it.' -ForegroundColor Yellow
                    Pause-Menu
                }
                '0' { Write-Host "`nExiting Any Tool..." -ForegroundColor Cyan; return }
                default { Write-Host 'Invalid option.' -ForegroundColor Red; Pause-Menu }
            }
        }
        catch {
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
            Pause-Menu
        }
    }
}

try {
    Show-Menu
}
finally {
    Write-Host "`nCleaning temporary files..." -ForegroundColor Cyan
    try {
        if (Test-Path -LiteralPath $workDir) {
            Remove-Item -LiteralPath $workDir -Recurse -Force -ErrorAction Stop
        }
        Write-Host 'Cleanup completed.' -ForegroundColor Green
    }
    catch {
        Write-Host "Cleanup failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}
