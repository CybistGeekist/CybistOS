# CybistOS 0.2c
# Automated system validation
# Run as Administrator inside the CybistOS test installation.

$ErrorActionPreference = "Continue"

$LogDirectory = "C:\CybistOS\logs"
$ReportFile = Join-Path $LogDirectory "CybistOS-Verification.txt"

New-Item -Path $LogDirectory -ItemType Directory -Force | Out-Null

$Results = @()

function Add-TestResult {
    param(
        [string]$Test,
        [string]$Status,
        [string]$Details
    )

    $script:Results += [PSCustomObject]@{
        Test    = $Test
        Status  = $Status
        Details = $Details
    }

    $Color = switch ($Status) {
        "PASS" { "Green" }
        "FAIL" { "Red" }
        "WARN" { "Yellow" }
        default { "White" }
    }

    Write-Host "[$Status] $Test - $Details" -ForegroundColor $Color
}

Write-Host ""
Write-Host "CybistOS Automated Verification" -ForegroundColor Cyan
Write-Host "-------------------------------" -ForegroundColor Cyan
Write-Host ""

# Windows version
try {
    $Windows = Get-ComputerInfo
    Add-TestResult `
        -Test "Windows version" `
        -Status "PASS" `
        -Details "$($Windows.WindowsProductName), build $($Windows.OsBuildNumber)"
}
catch {
    Add-TestResult `
        -Test "Windows version" `
        -Status "FAIL" `
        -Details $_.Exception.Message
}

# Internet connectivity
try {
    $Connection = Test-NetConnection -ComputerName "www.microsoft.com" -Port 443

    if ($Connection.TcpTestSucceeded) {
        Add-TestResult `
            -Test "Internet connectivity" `
            -Status "PASS" `
            -Details "HTTPS connection succeeded."
    }
    else {
        Add-TestResult `
            -Test "Internet connectivity" `
            -Status "FAIL" `
            -Details "HTTPS connection failed."
    }
}
catch {
    Add-TestResult `
        -Test "Internet connectivity" `
        -Status "FAIL" `
        -Details $_.Exception.Message
}

# Defender
try {
    $Defender = Get-MpComputerStatus -ErrorAction Stop

    if ($Defender.AntivirusEnabled -and $Defender.RealTimeProtectionEnabled) {
        Add-TestResult `
            -Test "Microsoft Defender" `
            -Status "PASS" `
            -Details "Antivirus and real-time protection are enabled."
    }
    else {
        Add-TestResult `
            -Test "Microsoft Defender" `
            -Status "WARN" `
            -Details "Defender is present, but one or more protections are disabled."
    }
}
catch {
    Add-TestResult `
        -Test "Microsoft Defender" `
        -Status "FAIL" `
        -Details $_.Exception.Message
}

# Windows Update service
try {
    $UpdateService = Get-Service -Name "wuauserv" -ErrorAction Stop

    if ($UpdateService.StartType -ne "Disabled") {
        Add-TestResult `
            -Test "Windows Update service" `
            -Status "PASS" `
            -Details "Startup type: $($UpdateService.StartType); state: $($UpdateService.Status)"
    }
    else {
        Add-TestResult `
            -Test "Windows Update service" `
            -Status "FAIL" `
            -Details "Windows Update is disabled."
    }
}
catch {
    Add-TestResult `
        -Test "Windows Update service" `
        -Status "FAIL" `
        -Details $_.Exception.Message
}

# Microsoft Store
try {
    $Store = Get-AppxPackage -Name "Microsoft.WindowsStore"

    if ($null -ne $Store) {
        Add-TestResult `
            -Test "Microsoft Store" `
            -Status "PASS" `
            -Details "Store package is installed."
    }
    else {
        Add-TestResult `
            -Test "Microsoft Store" `
            -Status "FAIL" `
            -Details "Store package was not found."
    }
}
catch {
    Add-TestResult `
        -Test "Microsoft Store" `
        -Status "FAIL" `
        -Details $_.Exception.Message
}

# WinGet / App Installer
try {
    $WinGet = Get-Command winget.exe -ErrorAction Stop
    $WinGetVersion = & winget --version

    Add-TestResult `
        -Test "WinGet" `
        -Status "PASS" `
        -Details "Version $WinGetVersion"
}
catch {
    Add-TestResult `
        -Test "WinGet" `
        -Status "FAIL" `
        -Details "WinGet was not found or could not run."
}

# Audio service
try {
    $AudioService = Get-Service -Name "Audiosrv" -ErrorAction Stop

    if ($AudioService.Status -eq "Running") {
        Add-TestResult `
            -Test "Windows Audio service" `
            -Status "PASS" `
            -Details "Audio service is running."
    }
    else {
        Add-TestResult `
            -Test "Windows Audio service" `
            -Status "WARN" `
            -Details "Audio service state: $($AudioService.Status)"
    }
}
catch {
    Add-TestResult `
        -Test "Windows Audio service" `
        -Status "FAIL" `
        -Details $_.Exception.Message
}

# Search service
try {
    $SearchService = Get-Service -Name "WSearch" -ErrorAction Stop

    if ($SearchService.StartType -ne "Disabled") {
        Add-TestResult `
            -Test "Windows Search" `
            -Status "PASS" `
            -Details "Startup type: $($SearchService.StartType); state: $($SearchService.Status)"
    }
    else {
        Add-TestResult `
            -Test "Windows Search" `
            -Status "WARN" `
            -Details "Windows Search is disabled."
    }
}
catch {
    Add-TestResult `
        -Test "Windows Search" `
        -Status "WARN" `
        -Details "Search service was not found."
}

# Optimized services
$ExpectedDisabledServices = @(
    "MapsBroker",
    "PhoneSvc",
    "ScDeviceEnum",
    "SCardSvr",
    "SNMPTRAP",
    "RemoteAccess"
)

foreach ($ServiceName in $ExpectedDisabledServices) {
    $Service = Get-CimInstance Win32_Service `
        -Filter "Name='$ServiceName'" `
        -ErrorAction SilentlyContinue

    if ($null -eq $Service) {
        Add-TestResult `
            -Test "Service: $ServiceName" `
            -Status "PASS" `
            -Details "Service is not present."
    }
    elseif ($Service.StartMode -eq "Disabled") {
        Add-TestResult `
            -Test "Service: $ServiceName" `
            -Status "PASS" `
            -Details "Service is disabled."
    }
    else {
        Add-TestResult `
            -Test "Service: $ServiceName" `
            -Status "WARN" `
            -Details "Start mode is $($Service.StartMode); state is $($Service.State)"
    }
}

# SharedAccess is intentionally not required to be disabled.
try {
    $SharedAccess = Get-CimInstance Win32_Service `
        -Filter "Name='SharedAccess'" `
        -ErrorAction Stop

    Add-TestResult `
        -Test "SharedAccess" `
        -Status "PASS" `
        -Details "Left unchanged. State: $($SharedAccess.State); start mode: $($SharedAccess.StartMode)"
}
catch {
    Add-TestResult `
        -Test "SharedAccess" `
        -Status "PASS" `
        -Details "Service is not present."
}

# System file integrity
Write-Host ""
Write-Host "Running SFC verification. This may take several minutes..." -ForegroundColor Cyan

try {
    $SfcOutput = & sfc.exe /verifyonly 2>&1
    $SfcText = $SfcOutput -join " "

    if ($SfcText -match "did not find any integrity violations") {
        Add-TestResult `
            -Test "System File Checker" `
            -Status "PASS" `
            -Details "No integrity violations were found."
    }
    elseif ($SfcText -match "found integrity violations") {
        Add-TestResult `
            -Test "System File Checker" `
            -Status "WARN" `
            -Details "SFC reported integrity violations."
    }
    else {
        Add-TestResult `
            -Test "System File Checker" `
            -Status "WARN" `
            -Details "SFC completed, but the result was not recognized automatically."
    }
}
catch {
    Add-TestResult `
        -Test "System File Checker" `
        -Status "FAIL" `
        -Details $_.Exception.Message
}

# DISM component-store health
Write-Host ""
Write-Host "Checking the Windows component store..." -ForegroundColor Cyan

try {
    $DismOutput = & dism.exe /Online /Cleanup-Image /CheckHealth 2>&1
    $DismText = $DismOutput -join " "

    if ($LASTEXITCODE -eq 0 -and $DismText -match "No component store corruption detected") {
        Add-TestResult `
            -Test "DISM component store" `
            -Status "PASS" `
            -Details "No component-store corruption was detected."
    }
    elseif ($LASTEXITCODE -eq 0) {
        Add-TestResult `
            -Test "DISM component store" `
            -Status "PASS" `
            -Details "DISM completed successfully."
    }
    else {
        Add-TestResult `
            -Test "DISM component store" `
            -Status "FAIL" `
            -Details "DISM returned exit code $LASTEXITCODE."
    }
}
catch {
    Add-TestResult `
        -Test "DISM component store" `
        -Status "FAIL" `
        -Details $_.Exception.Message
}

# Performance snapshot
try {
    $ProcessCount = (Get-Process).Count
    $OperatingSystem = Get-CimInstance Win32_OperatingSystem
    $UsedMemoryGB = [math]::Round(
        ($OperatingSystem.TotalVisibleMemorySize -
        $OperatingSystem.FreePhysicalMemory) / 1MB,
        2
    )

    Add-TestResult `
        -Test "Performance snapshot" `
        -Status "PASS" `
        -Details "$ProcessCount processes; approximately $UsedMemoryGB GB RAM in use."
}
catch {
    Add-TestResult `
        -Test "Performance snapshot" `
        -Status "WARN" `
        -Details $_.Exception.Message
}

# Write report
$PassCount = ($Results | Where-Object Status -eq "PASS").Count
$WarnCount = ($Results | Where-Object Status -eq "WARN").Count
$FailCount = ($Results | Where-Object Status -eq "FAIL").Count

$ReportHeader = @"
CybistOS Verification Report
Generated: $(Get-Date)
Computer: $env:COMPUTERNAME

Summary
-------
PASS: $PassCount
WARN: $WarnCount
FAIL: $FailCount

Results
-------
"@

$ReportHeader | Set-Content -Path $ReportFile

$Results |
    Format-Table -AutoSize |
    Out-String -Width 240 |
    Add-Content -Path $ReportFile

Write-Host ""
Write-Host "Verification completed." -ForegroundColor Cyan
Write-Host "PASS: $PassCount" -ForegroundColor Green
Write-Host "WARN: $WarnCount" -ForegroundColor Yellow
Write-Host "FAIL: $FailCount" -ForegroundColor Red
Write-Host ""
Write-Host "Report saved to:" -ForegroundColor Cyan
Write-Host $ReportFile