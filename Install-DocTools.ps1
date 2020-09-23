<#
Installer to setup MiKTeX-Environment, Pandoc and matching environment variables.
Currently Work-in-Progress.
#>

# Reasonable defauls what to install and what not.
$do_pandoc = $true
$do_miktex = $true
$do_git = $true
$do_vscode = $true

# python is not really needed, so it defaults to "NO"
$do_python = $false # As is, there's a separate question prior to installing python. This value is not used, yet!
# Don't actually unszip or install anything. Downloads will still be done.
$dryrun = $false

$download_folder = "$env:USERPROFILE\Downloads\documentation-downloads"

# This is were the manual installed software will end up on your machine.
$target_root_folder = "C:\Portable"
$target_miktex_folder = "$target_root_folder\miktex"
$target_pandoc_folder = "$target_root_folder\pandoc"

$pandoc_installer = "$download_folder\pandoc.zip"
$pandoc_base_uri = "https://github.com/jgm/pandoc/releases/latest"
$pandoc_installer_pattern = "64\.zip"
$pandoc_download_uri = "https://github.com/jgm/pandoc/releases/download/2.10/pandoc-2.10-windows-x86_64.zip"
#https://github.com/jgm/pandoc/releases/download/2.10.1/pandoc-2.10.1-windows-x86_64.zip"
$target_pandoc_path = ""

$miktex_installer = "$download_folder\miktex-portable.exe"
$miktex_base_uri = "https://miktex.org/download/"
$miktex_installer_pattern = "basic.*64"
$miktex_download_uri = "https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex-20.6.29-x64.exe"
$miktex_install_params = "--portable=`"$target_miktex_folder`" --auto-install=yes --unattended"
$target_miktex_path = "$target_miktex_folder\texmfs\install\miktex\bin\x64"

$git_installer = "$download_folder\Git-64-bit.exe"
$git_base_uri = "https://git-scm.com/download/win"
$git_installer_pattern ="PortableGit.*-64-bit\.7z\.exe"
$git_download_uri = "https://github.com/git-for-windows/git/releases/download/v2.28.0.windows.1/Git-2.28.0-64-bit.exe"
$target_git_folder = "$target_root_folder\git"
$target_git_path = "$target_git_folder\bin"
$git_install_params = "-o `"$target_git_folder`" -y"

$vscode_installer = "$download_folder\VSCodeUserSetup-x64.exe"
$vscode_download_uri = "https://aka.ms/win32-x64-user-stable"
$vscode_install_params = "/verysilent"

$python_installer = "$download_folder\python-setup.exe"
$python_base_uri = "https://www.python.org/downloads/"
$python_installer_pattern = "\.exe"
$python_download_uri = "https://www.python.org/ftp/python/3.8.5/python-3.8.5.exe"
$python_install_params = "/passive /InstallAllUsers=0"

$user_path = [System.Environment]::GetEnvironmentVariable("Path", "User")
$path_changed = $false

function Get-Installer {
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $DownloadSource,

        [Parameter(Mandatory=$true)]
        [String]
        $DownloadTargetFile,

        [Parameter(Mandatory=$false)]
        [String]
        $DownloadName
    )

    if(-not ($DownloadName)) {
      $SourceName = $DownloadSource
    } else {
      $SourceName = "$DownloadName from $DownloadSource"
    }
    $web = New-Object System.Net.WebClient
    Write-Host "Downloading $SourceName ... " -NoNewline
    $web.DownloadFile($DownloadSource, $DownloadTargetFile)
    Write-Host "complete."
    Write-Host "File saved to $DownloadTargetFile."
}


function Get-LatestDownload {
  param (
    [Parameter(Mandatory=$true)]
    [String]
    $BaseUri,
    [Parameter(Mandatory=$true)]
    [String]
    $SearchPattern
  )
  $site = Invoke-WebRequest -Uri $BaseUri -UseBasicParsing
  $dl_links = $site.Links.href | Where-Object {$_ -match $SearchPattern} | Select-Object -Unique
  if (-not ($dl_links -match "https.*")) {
    $domain = $BaseUri.Split("/")[2]
    $dl_links = "https://$domain$dl_links"
  }
  return $dl_links
}

Write-Host "   _____           _        _ _      ___          _____            _     "
Write-Host "   \_   \_ __  ___| |_ __ _| | |    /   \___   __/__   \___   ___ | |___ "
Write-Host "    / /\/ '_ \/ __| __/ _`` | | |   / /\ / _ \ / __|/ /\/ _ \ / _ \| / __|"
Write-Host " /\/ /_ | | | \__ \ || (_| | | |  / /_// (_) | (__/ / | (_) | (_) | \__ \"
Write-Host " \____/ |_| |_|___/\__\__,_|_|_| /___,' \___/ \___\/   \___/ \___/|_|___/"
Write-Host ""
                                                                        
if ((Test-Path -Path $target_pandoc_folder) -or (Get-Command -Name "pandoc.exe" -ErrorAction SilentlyContinue)) {
    Write-Warning "Pandoc install seems already present. Suggesting to skip install."
    $do_pandoc = $false
    $answer = Read-Host "Reinstall anyway? ( y / n )"
    switch($answer) {
        Y {
            $do_pandoc = $true
        }
    }
}
if ((Test-Path -Path $target_miktex_folder) -or (Get-Command -Name "miktex-cosole.exe" -ErrorAction SilentlyContinue)) {
    Write-Warning "MiKTeX install seems already present. Suggesting to skip install."
    $do_miktex = $false
    $answer = Read-Host "Reinstall anyway? ( y / n )"
    switch($answer) {
        Y {
            $do_miktex = $true
        }
    }
}
if (Get-Command -Name "code" -ErrorAction SilentlyContinue) {
    Write-Warning "VS Code install seems already present. Suggesting to skip install."
    $do_miktex = $false
    $answer = Read-Host "Reinstall anyway? ( y / n )"
    switch($answer) {
        Y {
            $do_vscode = $true
        }
    }
}
if (Get-Command -Name "git.exe" -ErrorAction SilentlyContinue) {
    Write-Warning "Git install seems already present. Suggesting to skip install."
    $do_miktex = $false
    $answer = Read-Host "Reinstall anyway? ( y / n )"
    switch($answer) {
        Y {
            $do_git = $true
        }
    }
}


# Download directory needs to be present to store the installers.
if (Test-Path -Path $download_folder) {
    Write-Host "Download directory exists."
} else {
    Write-Host "Download directory does not exist. Creating new one at $download_folder."
    New-Item -Path $download_folder -ItemType Directory 
}

if ($do_pandoc) {
    Write-Host "====PANDOC===="

    # Check if we have the latest download version in our links above.
    Write-Host "Checking available Pandoc version online."
    # Pandoc download page is at https://github.com/jgm/pandoc/releases/latest
    $web_pandoc_download_uri = Get-LatestDownload -BaseUri $pandoc_base_uri -SearchPattern $pandoc_installer_pattern
    if (-not ($pandoc_download_uri -eq $web_pandoc_download_uri)) {
        Write-Warning "Pandoc: Newer version avaiable online: $web_pandoc_download_uri"
        Write-Host "Pandoc: Script will use that version for download."
        $pandoc_download_uri = $web_pandoc_download_uri
    }
    if (-not (Test-Path -Path $pandoc_installer)) {
        Get-Installer -DownloadSource $pandoc_download_uri -DownloadTargetFile $pandoc_installer -DownloadName "Pandoc Portable"
    }
    else {
        $answer = Read-Host "Download exists. Re-download and overwrite? ( y / n )"
        switch ($answer) {
            Y {
                Get-Installer -DownloadSource $pandoc_download_uri -DownloadTargetFile $pandoc_installer -DownloadName "Pandoc Portable"
            }
        }
    }
    Write-Host "Unzipping Pandoc ..." -NoNewline
    if (-not ($dryrun)) { Expand-Archive -Path $pandoc_installer -DestinationPath $target_pandoc_folder -Force }
    Write-Host "done."
    # Pandoc unzips with a separate folder and that folder must be added
    # to the path instead of the above mentioned target path for pandoc.
    # Thus we look for it here. If there's more than one folder, it is
    # using the most recent one based on last write time.
    $pandoc_subfolder = Get-ChildItem -Path $target_pandoc_folder | Sort-Object -Property LastWriteTime
    $target_pandoc_path = $target_pandoc_folder + "\" + $pandoc_subfolder[-1].name 
    if ($user_path.Contains($target_pandoc_path)) {
        Write-Warning "Pandoc is already in the PATH."
    }
    else {
        Write-Host "Will add Pandoc to PATH variable and save later."
        $user_path += ";" + $target_pandoc_path
        $path_changed = $true
    }
    # Check if there's maybe old pandoc stuff in the path.
    $count_pandoc_in_path = ($user_path.Split(";") | Where-Object {$_ -match "pandoc"}).Count
    if ($count_pandoc_in_path -gt 1) {
        Write-Warning "You have Pandoc in your path more than once. Please fix this manually to avoid errors."
        $user_path.Split(";") | Where-Object {$_ -match "pandoc"} | Write-Warning
    }
}

if ($do_miktex) {
    Write-Host "====MIKTEX===="

    # Check if we have the latest download version in our links above.
    Write-Host "Checking available versions online."
    $web_miktex_download_uri = Get-LatestDownload -BaseUri $miktex_base_uri -SearchPattern $miktex_installer_pattern
    if (-not ($miktex_download_uri -eq $web_miktex_download_uri)) {
        Write-Warning "MiKTeX: Newer version avaiable online: $web_miktex_download_uri"
        Write-Host "MiKTeX: Script will use that version for download."
        $miktex_download_uri = $web_miktex_download_uri
    }

    if (-not (Test-Path -Path $miktex_installer)) {
        Get-Installer -DownloadSource $miktex_download_uri -DownloadTargetFile $miktex_installer -DownloadName "MiKTeX installer"
    }
    else {
        $answer = Read-Host "Download extists. Re-download and overwrite? ( y / n )"
        switch ($answer) {
            Y {
                Get-Installer -DownloadSource $miktex_download_uri -DownloadTargetFile $miktex_installer -DownloadName "MiKTeX installer"
            }
        }
    }
    Write-Host "Installing MiKTeX as portable ... " -NoNewline
    if (-not ($dryrun)) { Start-Process -FilePath $miktex_installer -ArgumentList $miktex_install_params -NoNewWindow -Wait }
    Write-Host "done."

    if ($user_path.Contains($target_miktex_path)) {
        Write-Warning "MiKTeX already in PATH."
    }
    else {
        Write-Host "Will add MiKTeX bin to PATH variable and save later."
        $user_path += ";" + $target_miktex_path
        $path_changed = $true
    }
    $count_miktex_in_path = ($user_path.Split(";") | Where-Object {$_ -match "miktex"}).Count
    if ($count_miktex_in_path -gt 1) {
        Write-Warning "You have MiKTeX in your path more than once! Please fix this manually to avoid errors."
        $user_path.Split(";") | Where-Object {$_ -match "miktex"} | Write-Warning
    }    
}

# TODO: Git client
# https://git-scm.com/download/win
# /silent

if ($do_git) {
    Write-Host "=====GIT======"

    $web_git_download_uri = Get-LatestDownload -BaseUri $git_base_uri -SearchPattern $git_installer_pattern
    if (-not ($git_download_uri -eq $web_git_download_uri)) {
        Write-Warning "Git: Newer version avaiable online: $web_git_download_uri"
        Write-Host "Git: Script will use that version for download."
        $git_download_uri = $web_git_download_uri
    }
    if (-not (Test-Path -Path $git_installer)) {
        Get-Installer -DownloadSource $git_download_uri -DownloadTargetFile $git_installer -DownloadName "Git portable"
    }
    else {
        $answer = Read-Host "Download extists. Re-download and overwrite? ( y / n )"
        switch ($answer) {
            Y {
                Get-Installer -DownloadSource $git_download_uri -DownloadTargetFile $git_installer -DownloadName "Visual Studio Code"
            }
        }
    }
    Write-Host "Installing git as portable version."
    if (-not ($dryrun)) { Start-Process -FilePath $git_installer -ArgumentList $git_install_params -NoNewWindow -Wait }

    if ($user_path.Contains($target_git_path)) {
        Write-Warning "Git already in PATH."
    }
    else {
        Write-Host "Will add Git bin to PATH variable and save later."
        $user_path += ";" + $target_git_path
        $path_changed = $true
    }
    $count_git_in_path = ($user_path.Split(";") | Where-Object {$_ -match "git"}).Count
    if ($count_git_in_path -gt 1) {
        Write-Warning "You have Git in your path more than once! Please fix this manually to avoid errors."
        $user_path.Split(";") | Where-Object {$_ -match "git"} | Write-Warning
    }    
}

if ($do_vscode) {
    Write-Host "====VSCODE===="

    if (-not (Test-Path -Path $vscode_installer)) {
        Get-Installer -DownloadSource $vscode_download_uri -DownloadTargetFile $vscode_installer -DownloadName "Visual Studio Code"
    }
    else {
        $answer = Read-Host "Download extists. Re-download and overwrite? ( y / n )"
        switch ($answer) {
            Y {
                Get-Installer -DownloadSource $vscode_download_uri -DownloadTargetFile $vscode_installer -DownloadName "Visual Studio Code"
            }
        }
    }
    Write-Host "Running VS Code install for single user."
    if (-not ($dryrun)) { Start-Process -FilePath $vscode_installer -ArgumentList $vscode_install_params -NoNewWindow -Wait }
}

# Optional stuff: Python
if (-not (Get-Command -Name "python.exe" -ErrorAction SilentlyContinue)) {
    Write-Host "You don't seem to have Python installed."
    $answer = Read-Host "Do you want to install Python now? ( y / n )"
    switch ($answer) {
        Y {
            $web_python_download_uri = Get-LatestDownload -BaseUri $python_base_uri -SearchPattern $python_installer_pattern
            if (-not ($python_download_uri -eq $web_python_download_uri)) {
                Write-Warning "Python: Newer version avaiable online: $web_python_download_uri"
                Write-Host "Python: Script will use that version for download."
                $python_download_uri = $web_python_download_uri
            }
            Get-Installer -DownloadSource $python_download_uri -DownloadTargetFile $python_installer -DownloadName "Python"
            if (-not ($dryrun)) { Start-Process -FilePath $python_installer -ArgumentList $python_install_params -NoNewWindow -Wait }
        }
    }
}


# Save all the changes to the path environment for the user.
if ($path_changed) {
    Write-Host "Save path environment ... " -NoNewline
    if (-not ($dryrun)) { [System.Environment]::SetEnvironmentVariable("Path", $user_path, "User") }
    Write-Host "done."
}

Write-Host ""
Write-Host "     ___                   "
Write-Host "    /   \___  _ __   ___   "
Write-Host "   / /\ / _ \| '_ \ / _ \  "
Write-Host "  / /_// (_) | | | |  __/_ "
Write-Host " /___,' \___/|_| |_|\___(_)"
Write-Host ""
                       

