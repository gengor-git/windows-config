<#
Installer to setup MiKTeX-Environment, Pandoc and matching environment variables.
Currently Work-in-Progress.
#>

$do_pandoc = $true
$do_miktex = $true

$download_folder = "$env:USERPROFILE\Downloads\documentation-downloads"

$target_root_folder = "C:\Portable"
$target_miktex_folder = "$target_root_folder\miktex"
$target_pandoc_folder = "$target_root_folder\pandoc"

$miktex_installer = "$download_folder\miktex-portable.exe"
$miktex_download_uri = "https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex-20.6.29-x64.exe"
$miktex_install_params = "--portable=`"$target_miktex_folder`" --auto-install=yes --unattended"
$target_miktex_path = "$target_miktex_folder\texmfs\install\miktex\bin\x64"
$target_pandoc_path = ""

$pandoc_installer = "$download_folder\pandoc-2.10.1-windows-x86_64.zip"
$pandoc_download_uri = "https://github.com/jgm/pandoc/releases/download/2.10/pandoc-2.10-windows-x86_64.zip"
#https://github.com/jgm/pandoc/releases/download/2.10.1/pandoc-2.10.1-windows-x86_64.zip"

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

Get-Content -Path titleascii.txt | Write-Host

# Fail-Safe
if (Test-Path -Path $target_miktex_folder) {
    Write-Warning "MiKTeX folder already present. Suggesting to skip install."
    $do_miktex = $false
    $answer = Read-Host "Reinstall anyway? ( y / n )"
    switch($answer) {
        Y {
            $do_miktex = $true
        }
    }
}
if (Test-Path -Path $target_pandoc_folder) {
    Write-Warning "Pandoc folder already present. Suggesting to skip install."
    $do_pandoc = $false
    $answer = Read-Host "Reinstall anyway? ( y / n )"
    switch($answer) {
        Y {
            $do_pandoc = $true
        }
    }
}

# Check if we have the latest download version in our links above
# Pandoc download page is at https://github.com/jgm/pandoc/releases/latest
$web_pandoc_dl_page = Invoke-WebRequest -Uri "https://github.com/jgm/pandoc/releases/latest" -UseBasicParsing
$web_pandoc_dl_page_links = $web_pandoc_dl_page.Links.href | Where-Object {$_ -match "64\.zip"}
# Pandoc typically has only one zip with 64 bit for Windows.
$web_pandoc_download_uri = "https://github.com" + $web_pandoc_dl_page_links
if (-not ($pandoc_download_uri -eq $web_pandoc_download_uri)) {
    Write-Warning "Pandoc: Never version avaiable online: $web_pandoc_download_uri"
    Write-Host "Pandoc: Will use that version for download."
    $pandoc_download_uri = $web_pandoc_download_uri
}
# MiKTeX download page is at https://miktex.org/download/
$web_miktex_dl_page = Invoke-WebRequest -Uri "https://miktex.org/download/" -UseBasicParsing
# MiKTeX has the same download link twice on the page, hence the filter to unique.
$web_miktex_dl_page_links = $web_miktex_dl_page.Links.href | Where-Object {$_ -match "basic.*64"} | Select-Object -Unique
$web_miktex_download_uri = "https://miktex.org/" + $web_miktex_dl_page_links
if (-not ($miktex_download_uri -eq $web_miktex_download_uri)) {
    Write-Warning "MiKTeX: Never version avaiable online: $web_miktex_download_uri"
    Write-Host "MiKTeX: Will use that version for download."
    $miktex_download_uri = $web_miktex_download_uri
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
    if (-not (Test-Path -Path $pandoc_installer)) {
        Download-Installer -DownloadSource $pandoc_download_uri -DownloadTargetFile $pandoc_installer -DownloadName "Pandoc Portable"
    }
    else {
        $answer = Read-Host "Download and overwrite? ( y / n )"
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

# Save all the changes to the path environment for the user.
if ($path_changed) {
    Write-Host "Save path environment ... " -NoNewline
    [System.Environment]::SetEnvironmentVariable("Path", $user_path, "User")
    Write-Host "done."
}


Write-Host "+==================+"
Write-Host "| Script finished. |"
Write-Host "+==================+"