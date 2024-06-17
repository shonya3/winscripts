winget install --exact --id Microsoft.VisualStudioCode.Insiders
winget install --exact --id OpenJS.NodeJS --silent
winget install --exact --id Git.Git 
winget install --exact --id pnpm.pnpm
winget install --exact --id Rustlang.Rustup

# git global config
git config --global user.name  shonya3
git config --global user.email poeshonya3@gmail.com

# # github cli auth
winget install --exact --id GitHub.cli --silent
$authStatus = gh auth status
if(-Not $authStatus){
    gh auth login
}

winget install --exact --id Google.Chrome --silent
winget install --exact --id Mozilla.Firefox --silent
winget install --exact --id VideoLAN.VLC 


winget install --exact --id Rustlang.Rustup 