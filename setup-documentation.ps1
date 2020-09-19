<#
Installer to setup MikTeX-Environment, Pandoc and matching environment variables.
Currently Work-in-Progress.
#>
$download_folder = "$env:USERPROFILE\Downloads\documentation-downloads"

$target_root_folder = "C:\Portable"
$target_miktex_folder = "$target_root_folder\miktex"

$miktex_installer = "$download_folder\miktex-portable.exe"
$miktex_download_uri = "https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex-20.6.29-x64.exe"
$miktext_install_params = "--portable=`"$target_miktex_folder`" --auto-install=yes --unattended"

$pandoc_installer = "$download_folder\pandoc-2.10.1-windows-x86_64.zip"
$pandoc_download_uri = "https://github.com/jgm/pandoc/releases/download/2.10.1/pandoc-2.10.1-windows-x86_64.zip"

# Download directory needs to be present to store the installers.
if(Test-Path -Path $download_folder) {
    Write-Host "Download directory exists."
} else {
    Write-Host "Download directory does not exist. Creating new one at $download_folder."
    New-Item -Path $download_folder -ItemType Directory 
}

# Download web client, because Invoke-WebRequest is too slow.
$dl = New-Object System.Net.WebClient

# Pandoc download
Write-Host "Downloading Pandoc portable zip ... " -NoNewline
$dl.DownloadFile($pandoc_download_uri, $pandoc_installer)
Write-Host "done."


# MiKTeX download
Write-Host "Downloading MikTeX installer ... " -NoNewline
$dl.DownloadFile($miktex_download_uri, $miktex_installer)
Write-Host "done."




