<#
Get configurations for the doc tools and install them for the local user.
#>

param (
    [Parameter(Mandatory=$true)]
    [String]
    $SourceDirectory,
    [String]
    $FilePattern = "snapshot.*\.zip"
)

# Install the pandoc templates from a WebDAV source, that is given as parameter.
$documentation_toolkit_webdav = $SourceDirectory

if (-not ($documentation_toolkit_webdav)) {
  $documentation_toolkit_webdav = Read-Host "Please enter the folder (local/WebDav) to load the toolkit from"
}

$documentation_toolkit_local = "C:\Portable\documentation-toolkit"
Get-ChildItem -Path $documentation_toolkit_webdav | ? {$_.Name -match $FilePattern} | Expand-Archive -DestinationPath $documentation_toolkit_local -Force
[System.Environment]::SetEnvironmentVariable("Pandoc_Datadir", $documentation_toolkit_local, "User")


if (Get-Command "code" -ErrorAction SilentlyContinue) {
  Write-Host "VS Code is present."

  # Install Extensions like Pandoc, Markdown and German language
  Start-Process -FilePath "code" -ArgumentList "--install-extension chrischinchilla.vscode-pandoc" -NoNewWindow -Wait
  Start-Process -FilePath "code" -ArgumentList "--install-extension ms-ceintl.vscode-language-pack-de" -NoNewWindow -Wait
  Start-Process -FilePath "code" -ArgumentList "--install-extension eamodio.gitlens" -NoNewWindow -Wait
  Start-Process -FilePath "code" -ArgumentList "--install-extension yzhang.markdown-all-in-one" -NoNewWindow -Wait
  Start-Process -FilePath "code" -ArgumentList "--install-extension darkriszty.markdown-table-prettify" -NoNewWindow -Wait
  Start-Process -FilePath "code" -ArgumentList "--install-extension mechatroner.rainbow-csv" -NoNewWindow -Wait

  $pandoc_opt_pdf = "--number-sections --data-dir $documentation_toolkit_local --template eisvogel --pdf-engine=xelatex -V colorlinks --listings"
  $pandoc_opt_html = "-t html5 -s --self-contained --data-dir $documentation_toolkit_local --template=GitHub --toc"

  Write-Warning "Please add the following lines to your VS Code Settings `"pandoc.pdfOptString:`""
  Write-Host  $pandoc_opt_pdf

  Write-Warning "Please add the following lines to your VS Code Settings `"pandoc.htmlOptString:`""
  Write-Host $pandoc_opt_html

  # TODO: Change these settings automatically in "$env:USERPROFILE\AppData\Roaming\code\user\settings.json"
}

if (Get-Command "pip" -ErrorAction SilentlyContinue) {
  Write-Host "Python is present."
  $pip_local = pip list -l

  $packages = @(
    "pandocfilters",
    "pandoc-latex-environment"
  )

  Write-Host "Checking for installed pip packages."
  foreach ($package in $packages) {
    if ($pip_local | % {$_ -like $package+"*"} | ? {$_ -eq $true}) {
      Write-Host "Package $package already installed."
    } else {
      Write-Host "Installing package $package to user space."
      Start-Process -FilePath "pip" -ArgumentList "install $package --user" -NoNewWindow -Wait
    }
  }
}