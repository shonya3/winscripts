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

Write-Output 'Make sure you have this in your VSCode settings.json "terminal.integrated.fontFamily": "MesloLGM Nerd Font"'