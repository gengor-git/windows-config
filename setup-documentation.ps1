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
$target_miktex_path = "C:\Portable\miktex\texmfs\install\miktex\bin\x64"
$target_pandoc_path = ""

$pandoc_installer = "$download_folder\pandoc-2.10.1-windows-x86_64.zip"
$pandoc_download_uri = "https://github.com/jgm/pandoc/releases/download/2.10.1/pandoc-2.10.1-windows-x86_64.zip"

$user_path = [System.Environment]::GetEnvironmentVariable("Path", "User")

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

# Download directory needs to be present to store the installers.
if (Test-Path -Path $download_folder) {
    Write-Host "Download directory exists."
} else {
    Write-Host "Download directory does not exist. Creating new one at $download_folder."
    New-Item -Path $download_folder -ItemType Directory 
}

# Download web client, because Invoke-WebRequest is too slow.
$dl = New-Object System.Net.WebClient

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
            N {

            }
            Default {

            }
        }
    }
    Write-Host "Unzipping Pandoc ..." -NoNewline
    Expand-Archive -Path $pandoc_installer -DestinationPath $target_pandoc_folder -Force
    Write-Host "done."
    $pandoc_subfolder = Get-ChildItem -Path $target_pandoc_folder
    $target_pandoc_path = $target_pandoc_folder + "\" + $pandoc_subfolder[0].name 
    if ($user_path.Contains($target_pandoc_path)) {
        Write-Warning "Pandoc is already in the PATH. Check if this is correct!"
    }
    else {
        Write-Host "Will add Pandoc to PATH variable and save later."
        $user_path += ";" + $target_pandoc_path
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
            N {

            }
            Default {

            }
        }
    }
    Write-Host "Installing MiKTeX as portable ... " -NoNewline
    Start-Process -FilePath $miktex_installer -ArgumentList $miktex_install_params -NoNewWindow -Wait
    Write-Host "done."

    if ($user_path.Contains($target_miktex_path)) {
        Write-Warning "MiKTeX already in PATH. Check if this is correct!"
    }
    else {
        Write-Host "Will add MiKTeX bin to PATH variable and save later."
        $user_path += ";" + $target_miktex_path
    }
}

# Save all the changes to the path environment for the user.
Write-Host "Save path environment ... " -NoNewline
[System.Environment]::SetEnvironmentVariable("Path", $user_path, "User")
Write-Host "done."
