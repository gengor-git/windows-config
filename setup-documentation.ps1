<#
Installer to setup MikTeX-Environment, Pandoc and matching environment variables.
Currently Work-in-Progress.
#>
$download_folder = "$env:USERPROFILE\Downloads\documentation-downloads"

$target_root_folder = "C:\Portable"
$target_miktex_folder = "$target_root_folder\miktex"
$target_pandoc_folder ="$target_root_folder\pandoc"

$miktex_installer = "$download_folder\miktex-portable.exe"
$miktex_download_uri = "https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex-20.6.29-x64.exe"
$miktext_install_params = "--portable=`"$target_miktex_folder`" --auto-install=yes --unattended"

$pandoc_installer = "$download_folder\pandoc-2.10.1-windows-x86_64.zip"
$pandoc_download_uri = "https://github.com/jgm/pandoc/releases/download/2.10.1/pandoc-2.10.1-windows-x86_64.zip"

$user_path = [System.Environment]::GetEnvironmentVariable("Path", "User")

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
#$dl.DownloadFile($pandoc_download_uri, $pandoc_installer)
Write-Host "done."
Write-Host "Unzipping Pandoc ..." -NoNewline
Expand-Archive -Path $pandoc_installer -DestinationPath $target_pandoc_folder -Force
Write-Host "done."
if ($user_path.Contains($target_pandoc_path)) {
    Write-Host "Pandoc already in Path. Check if this is correct!"
} else {
    Write-Host "Will add Pandoc to PATH variable and save later."
    $pandoc_subfolder = Get-ChildItem -Path $target_pandoc_folder
    $target_pandoc_path = $target_pandoc_folder + "\" + $pandoc_subfolder[0].name 
    $user_path += ";"+$target_pandoc_path
}

# Save all the changes to the path environment for the user.
Write-Host "Save path environment ... " -NoNewline
[System.Environment]::SetEnvironmentVariable("Path", $user_path, "User")
Write-Host "done."

# MiKTeX download
Write-Host "Downloading MikTeX installer ... " -NoNewline
#$dl.DownloadFile($miktex_download_uri, $miktex_installer)
Write-Host "done."




