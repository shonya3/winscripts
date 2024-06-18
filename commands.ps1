function Add-MonaspaceFonts {
    Write-Output "Monaspace fonts installation..."
    $release = gh api -H "Accept: application/vnd.github+json" /repos/githubnext/monaspace/releases/latest | ConvertFrom-Json 
    $zip = $release.assets | Where-Object { $_.content_type -eq "application/zip" -and $_.name.StartsWith("monaspace-") } | Select-Object -First 1
    if(-not $zip){
        Write-Output "Failed to retrieve latest release files. Download manually https://github.com/githubnext/monaspace/releases/latest"
        Return
    }
    $url = $zip.browser_download_url
    if(-not $url){
        Write-Output "Failed to retrieve latest release files. Download manually https://github.com/githubnext/monaspace/releases/latest"
        Return
    }

    $downloadDir = Join-Path -Path $env:TEMP -ChildPath "Downloads"
    $extractDir = Join-Path  -Path $env:TEMP -ChildPath "Extracted"

    New-Item -ItemType Directory -Force -Path $downloadDir | Out-Null
    New-Item -ItemType Directory -Force -Path $extractDir  | Out-Null

    $zipPath = Join-Path -Path $downloadDir -ChildPath "assets.zip"
    Invoke-WebRequest -Uri $url -OutFile $zipPath
    if(-not (Test-Path $zipPath)){
        Write-Output "Failed to download fonts archive from $url"
        Return
    }

    Write-Debug "Asset downloaded successfully to: $zipPath"
    Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force
    Remove-Item -Path $downloadDir -Recurse
    Write-Debug "Asset extracted to: $extractDir"
    $dir = Get-ChildItem -Path $extractDir | Where-Object { $_.Name.StartsWith("monaspace") } 
    if(-not $dir){
        Write-Output "Extracted monaspace dir not found"
        Return
    }

    $fontsDir = $dir.FullName |
            Join-Path -ChildPath "fonts" |
            Join-Path -ChildPath "otf"
    Write-Debug "Fonts dir $fontsDir"
    $files = Get-ChildItem -Path $fontsDir -Filter "*.otf"
    foreach ($file in $files) {
        $destination = $env:windir | 
                        Join-Path -ChildPath "Fonts" |
                        Join-Path -ChildPath $file.Name
        Move-Item -Path $file.FullName -Destination $destination -Force
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "$file.BaseName (OpenType)" -Value $fontFile.Name -PropertyType String -Force | Out-Null
    }
    Write-Output "Monaspace fonts successfully installed!"
    Write-Output "Now you can set one of them in VS Code"
}

# configure oh-my-posh
oh-my-posh font install Meslo
New-Item -Path $PROFILE -Type File -Force
Add-Content $PROFILE "oh-my-posh init pwsh | Invoke-Expression"

winget install --exact --id Microsoft.VisualStudioCode.Insiders
winget install --exact --id OpenJS.NodeJS --silent
winget install --exact --id Git.Git 
winget install --exact --id pnpm.pnpm
winget install --exact --id Google.Chrome --silent
winget install --exact --id Mozilla.Firefox --silent
winget install --exact --id VideoLAN.VLC 
winget install --exact --id Rustlang.Rustup
winget install --exact --id qBittorrent.qBittorrent.Beta
winget install --exact --id RiotGames.LeagueOfLegends.EUW

# git global config
$gitUsername = Read-Host "Git config. Enter Git username" | ForEach-Object { $_.Trim() }
$gitEmail = Read-Host "Git Config. Enter Git email" | ForEach-Object { $_.Trim() }
if($gitUsername){
    git config --global user.name $gitUsername
}
if($gitEmail){
    git config --global user.email $gitEmail
}

# # github cli auth
winget install --exact --id GitHub.cli --silent
$authStatus = gh auth status
if(-Not $authStatus){
    gh auth login
}

Add-MonaspaceFonts

Set-Location "$env:USERPROFILE\Desktop"
git clone https://github.com/shonya3/divicards.git
git clone https://github.com/shonya3/divicards-site.git

Write-Output 'Make sure you have this in your VSCode settings.json "terminal.integrated.fontFamily": "MesloLGM Nerd Font"'