<#
Installer to setup MiKTeX-Environment, Pandoc and matching environment variables.
Currently Work-in-Progress.
#>

# Reasonable defauls what to install and what not.
$do_pandoc = $true
$do_miktex = $true
# python is not really needed, so it defaults to "NO"
$do_python = $false # As is, there's a separate question prior to installing python. This value is not used, yet!

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

$python_installer = "$download_folder\python-setup.exe"
$python_base_uri = "https://www.python.org/downloads/"
$python_installer_pattern = "\.exe"
$python_download_uri = "https://www.python.org/ftp/python/3.8.5/python-3.8.5.exe"
$python_install_params = "/passive /InstallAllUsers=0"

$user_path = [System.Environment]::GetEnvironmentVariable("Path", "User")
$path_changed = $false

function Download-Installer {
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
  if (-not ($dl_links -match "$\/")) {
    $domain = $BaseUri.Split("/")[2]
    $dl_links = "https://$domain$dl_links"
  }
  return $dl_links
}

Get-Content -Path "titleascii-install-docs-tools.txt" | Write-Host

# Fail-Safe
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
        Write-Warning "Pandoc: Never version avaiable online: $web_pandoc_download_uri"
        Write-Host "Pandoc: Script will use that version for download."
        $pandoc_download_uri = $web_pandoc_download_uri
    }
    if (-not (Test-Path -Path $pandoc_installer)) {
        Download-Installer -DownloadSource $pandoc_download_uri -DownloadTargetFile $pandoc_installer -DownloadName "Pandoc Portable"
    }
    else {
        $answer = Read-Host "Download exists. Re-download and overwrite? ( y / n )"
        switch ($answer) {
            Y {
                Download-Installer -DownloadSource $pandoc_download_uri -DownloadTargetFile $pandoc_installer -DownloadName "Pandoc Portable"
            }
        }
    }
    Write-Host "Unzipping Pandoc ..." -NoNewline
    Expand-Archive -Path $pandoc_installer -DestinationPath $target_pandoc_folder -Force
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
        Write-Warning "MiKTeX: Never version avaiable online: $web_miktex_download_uri"
        Write-Host "MiKTeX: Script will use that version for download."
        $miktex_download_uri = $web_miktex_download_uri
    }

    if (-not (Test-Path -Path $miktex_installer)) {
        Download-Installer -DownloadSource $miktex_download_uri -DownloadTargetFile $miktex_installer -DownloadName "MiKTeX installer"
    }
    else {
        $answer = Read-Host "Download and overwrite? ( y / n )"
        switch ($answer) {
            Y {
                Download-Installer -DownloadSource $miktex_download_uri -DownloadTargetFile $miktex_installer -DownloadName "MiKTeX installer"
            }
        }
    }
    Write-Host "Installing MiKTeX as portable ... " -NoNewline
    Start-Process -FilePath $miktex_installer -ArgumentList $miktex_install_params -NoNewWindow -Wait
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


# Optional stuff: Python
if (-not (Get-Command -Name "python.exe" -ErrorAction SilentlyContinue)) {
    Write-Host "You don't seem to have Python installed."
    $answer = Read-Host "Do you want to install Python now? ( y / n )"
    switch ($answer) {
        Y {
            $web_python_dl_page = Invoke-WebRequest -Uri $python_base_uri -UseBasicParsing
            # python has the same download link twice on the page, hence the filter to unique.
            $web_python_dl_page_links = $web_python_dl_page.Links.href | Where-Object {$_ -match $python_installer_pattern} | Select-Object -Unique
            $web_python_download_uri = $web_python_dl_page_links
            if (-not ($python_download_uri -eq $web_python_download_uri)) {
                Write-Warning "Python: Never version avaiable online: $web_python_download_uri"
                Write-Host "Python: Script will use that version for download."
                $python_download_uri = $web_python_download_uri
            }
            Download-Installer -DownloadSource $python_download_uri -DownloadTargetFile $python_installer -DownloadName "Python"
            Start-Process -FilePath $python_installer -ArgumentList $python_install_params -NoNewWindow -Wait
        }
    }
}


# Save all the changes to the path environment for the user.
if ($path_changed) {
    Write-Host "Save path environment ... " -NoNewline
    [System.Environment]::SetEnvironmentVariable("Path", $user_path, "User")
    Write-Host "done."
}

Write-Host "                   _         _        __  _         _       _                _"
Write-Host "  ___   ___  _ __ (_) _ __  | |_     / _|(_) _ __  (_) ___ | |__    ___   __| |"
Write-Host " / __| / __|| '__|| || '_ \ | __|   | |_ | || '_ \ | |/ __|| '_ \  / _ \ / _`` |"
Write-Host " \__ \| (__ | |   | || |_) || |_    |  _|| || | | || |\__ \| | | ||  __/| (_| |"
Write-Host " |___/ \___||_|   |_|| .__/  \__|   |_|  |_||_| |_||_||___/|_| |_| \___| \__,_|"
Write-Host "                     |_|"