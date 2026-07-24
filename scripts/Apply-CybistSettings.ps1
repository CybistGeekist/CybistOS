# CybistOS 0.2a
# Safe Windows settings configuration
# Run as the currently logged-in user.

Write-Host "Applying CybistOS settings..." -ForegroundColor Cyan

# Show known file extensions in File Explorer.
Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "HideFileExt" `
    -Type DWord `
    -Value 0

# Show hidden files and folders.
Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "Hidden" `
    -Type DWord `
    -Value 1

# Disable Windows suggestion notifications.
Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SubscribedContent-338389Enabled" `
    -Type DWord `
    -Value 0

# Disable suggested content in the Settings application.
Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SubscribedContent-338393Enabled" `
    -Type DWord `
    -Value 0

# Disable tailored experiences using diagnostic data.
Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" `
    -Name "TailoredExperiencesWithDiagnosticDataEnabled" `
    -Type DWord `
    -Value 0

# Disable the post-update Windows welcome screen.
Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SubscribedContent-310093Enabled" `
    -Type DWord `
    -Value 0

# Hide Widgets from the taskbar.
Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "TaskbarDa" `
    -Type DWord `
    -Value 0

Write-Host "CybistOS settings applied successfully." -ForegroundColor Green
Write-Host "Restart File Explorer or sign out to see every change."