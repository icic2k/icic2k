
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
                    Write-Host "`nDownloading EI Application..." `
                        -ForegroundColor Cyan

                    $file = Download-File `
                        -Url 'https://raw.githubusercontent.com/icic2k/icic2k/main/ei.exe' `
                        -Name 'ei.exe'

                    Write-Host "Download completed." `
                        -ForegroundColor Green

                    $confirm = Read-Host "Run the downloaded file? (YES/no)"

if ($confirm -ceq 'YES') {
    Start-Process -FilePath $file -Wait
}

                    Write-Host "Review and open EI Application from File Explorer."
                    Pause-Menu
                }

                '3' {
                    Write-Host "`nDownloading DE Script..." `
                        -ForegroundColor Cyan

                    $file = Download-File `
                        -Url 'https://raw.githubusercontent.com/suraj1863/itit2k/main/de.bat' `
                        -Name 'de.bat'

                    Write-Host "Download completed." `
                        -ForegroundColor Green

                    Write-Host "`nScript contents:" `
                        -ForegroundColor Cyan

                    Get-Content -LiteralPath $file

                    $confirm = Read-Host "Run the downloaded DE script? (YES/no)"

if ($confirm -ceq 'YES') {
    Start-Process -FilePath 'cmd.exe' `
        -ArgumentList "/c `"$file`"" `
        -Wait
}

                    Pause-Menu
                }

                '4' {
                    Write-Host "`nDownloading DWAgent..." `
                        -ForegroundColor Cyan

                    $zip = Download-File `
                        -Url 'https://raw.githubusercontent.com/suraj1863/itit2k/main/dwagent_x86.zip' `
                        -Name 'dw.zip'

                    $folder = Join-Path $workDir 'DWAgent'

                    New-Item -ItemType Directory `
                        -Path $folder -Force |
                        Out-Null

                    Expand-Archive -LiteralPath $zip `
                        -DestinationPath $folder -Force

                    $exe = Get-ChildItem `
                        -LiteralPath $folder `
                        -Filter 'dwagent_x86.exe' `
                        -File -Recurse |
                        Select-Object -First 1

                    if ($exe) {
                        Write-Host "DWAgent extracted successfully." `
                            -ForegroundColor Green

                        Write-Host "Open the installer and enter your DWAgent installation code." `
                            -ForegroundColor Yellow

                        Open-DownloadedFile -Path $exe.FullName
                    }
                    else {
                        Write-Host "DWAgent executable not found." `
                            -ForegroundColor Red
                    }

                    Pause-Menu
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
