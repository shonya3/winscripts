function Install-MonaspaceFonts {
    $desktop = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
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
    $downloadedOtfFontsPath = $dir.FullName |
            Join-Path -ChildPath "fonts" |
            Join-Path -ChildPath "otf"

    mkdir "$desktop\Monaspace fonts" -Force | Out-Null
    Copy-Item "$downloadedOtfFontsPath\*" "$desktop\Monaspace fonts\" -Recurse -Force | Out-Null
    Write-Debug "Fonts dir $downloadedOtfFontsPath"
    $systemFontsFolder = (New-Object -ComObject Shell.Application).Namespace(0x14)
    foreach($file in Get-ChildItem -Path $downloadedOtfFontsPath -Filter "*-Medium.otf") {
        $name = $file.Name
        $systemFontsFolder.CopyHere($file.FullName)
        Write-Output "$name installed"
    }
    Write-Output "Monaspace Medium fonts installed. If you need other Monaspace fonts, check the folder on your Desktop or delete it."
}

winget install --exact --id Microsoft.VisualStudioCode --override '/VERYSILENT /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"'
winget install --exact --id OpenJS.NodeJS --silent
winget install --exact --id Git.Git 
Invoke-WebRequest https://get.pnpm.io/install.ps1 -useb | Invoke-Expression
winget install --exact --id Google.Chrome --silent
winget install --exact --id Mozilla.Firefox --silent
winget install --exact --id VideoLAN.VLC 
winget install --exact --id qBittorrent.qBittorrent.Beta
winget install --exact --id Oven-sh.Bun


# Add Git and GitHub CLI to the PATH environment variable
$gitPath  = "C:\Program Files\Git\cmd" 
$ghPath   = "C:\Program Files\GitHub CLI"
$nodePath = "C:\Program Files\nodejs" 

function Add-ToPath ($path) {
    if (-not ([Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) -contains $path)) {
        [Environment]::SetEnvironmentVariable("Path", $env:Path + ";" + $path, [EnvironmentVariableTarget]::Machine)
        # Update the current session's PATH variable
        $env:Path += ";$path"
    }
}

# Update PATH for Git and GitHub CLI
Add-ToPath $gitPath
Add-ToPath $ghPath
Add-ToPath $nodePath

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

Install-MonaspaceFonts

$desktop = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
Set-Location $desktop
Write-Output 'Make sure you have this in your VSCode settings.json "terminal.integrated.fontFamily": "MesloLGM Nerd Font"' 

winget install --exact --id RiotGames.LeagueOfLegends.EUW
winget install --exact --id Rustlang.Rustup
