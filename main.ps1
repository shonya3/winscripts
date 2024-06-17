function Add-PowershellProfile {
    # Define the path to the settings.json file
    $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    # Read the current settings.json content
    $settings = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json

    # Define the new PowerShell Preview profile
    $pwshProfile = @{
        name              = "PowerShell Preview"
        commandline       = "C:\\Program Files\\PowerShell\\7-preview\\pwsh.exe"
        startingDirectory = "%USERPROFILE%\\Desktop"
        icon              = "C:\\Program Files\\PowerShell\\7-preview\\assets\\Powershell_av_colors.ico"
        guid              = "{7db34565-02bd-4c6a-967f-1c10d5b8c15d}"
    }

    # Check if the profile already exists by GUID
    $alreadyExists = $settings.profiles.list | Where-Object { $_.guid -eq $pwshProfile.guid }
    if (-not $alreadyExists) {
        # Add the new profile to the profiles list
        $settings.profiles.list += [pscustomobject]$pwshProfile
    }

    # Add the minimizeToNotificationArea property to the root of the settings
    $settings | Add-Member -NotePropertyName minimizeToNotificationArea -NotePropertyValue $true -Force
    
    # Add font name for oh-my-posh further installation and customization
    $defaults = @{
        font = @{
            face = "MesloLGM Nerd Font"
        }
    }
    $settings.profiles.defaults = $defaults

    # Set default profile
    $settings.defaultProfile = $pwshProfile.guid

    # Convert the modified settings object back to JSON with appropriate depth
    $settings | ConvertTo-Json -Depth 32 | Out-File -FilePath $settingsPath -Encoding utf8
    Write-Host "New PowerShell Preview profile added to Windows Terminal settings."
}


winget install --exact --id Microsoft.PowerShell.Preview
Add-PowershellProfile
$env:Path += ";C:\Program Files\PowerShell\7-preview\pwsh.exe"
$scriptPath = "./commands.ps1"
# Start PowerShell 7 Preview in elevated mode
Start-Process -FilePath pwsh -ArgumentList "-NoExit -File `"$scriptPath`"" -Verb RunAs


