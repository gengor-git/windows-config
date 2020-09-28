<#
Get configurations for the doc tools and install them for the local user.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String]
    $SourceToolkitDirectory,
    [String]
    $TookitFilePattern = "snapshot.*\.zip"
)

if (-not ($SourceToolkitDirectory)) {
  $SourceToolkitDirectory = Read-Host "Please enter a valid directory to look for the tookit zip file of pattern `"$TookitFilePattern`"."
}

$LocalDocumentationToolkitDirectory = "C:\Portable\documentation-toolkit"
Get-ChildItem -Path $SourceToolkitDirectory | Where-Object {$_.Name -match $FilePattern} | Expand-Archive -DestinationPath $LocalDocumentationToolkitDirectory -Force
[System.Environment]::SetEnvironmentVariable("Pandoc_Datadir", $LocalDocumentationToolkitDirectory, "User")

if (Get-Command "code" -ErrorAction SilentlyContinue) {
  Write-Host "VS Code is present."

  # Install Extensions like Pandoc, Markdown and German language
  Start-Process -FilePath "code" -ArgumentList "--install-extension chrischinchilla.vscode-pandoc" -NoNewWindow -Wait
  Start-Process -FilePath "code" -ArgumentList "--install-extension ms-ceintl.vscode-language-pack-de" -NoNewWindow -Wait
  Start-Process -FilePath "code" -ArgumentList "--install-extension eamodio.gitlens" -NoNewWindow -Wait
  Start-Process -FilePath "code" -ArgumentList "--install-extension yzhang.markdown-all-in-one" -NoNewWindow -Wait
  Start-Process -FilePath "code" -ArgumentList "--install-extension darkriszty.markdown-table-prettify" -NoNewWindow -Wait
  Start-Process -FilePath "code" -ArgumentList "--install-extension mechatroner.rainbow-csv" -NoNewWindow -Wait

  $pandoc_opt_pdf = "--number-sections --data-dir $LocalDocumentationToolkitDirectory --template eisvogel --pdf-engine=xelatex -V colorlinks --listings"
  $pandoc_opt_html = "-t html5 -s --self-contained --data-dir $LocalDocumentationToolkitDirectory --template=GitHub --toc"

  Write-Warning "Please add the following lines to your VS Code Settings `"pandoc.pdfOptString:`""
  Write-Host  $pandoc_opt_pdf

  Write-Warning "Please add the following lines to your VS Code Settings `"pandoc.htmlOptString:`""
  Write-Host $pandoc_opt_html

  # TODO: Change these settings automatically in "$env:USERPROFILE\AppData\Roaming\code\user\settings.json"
}

if (Get-Command "pip" -ErrorAction SilentlyContinue) {
  Write-Host "Python is present."
  $LocalPipPackagesInstalled = pip list -l

  $WantedPipPackages = @(
    "pandocfilters",
    "pandoc-latex-environment"
  )

  Write-Host "Checking for installed pip packages."
  foreach ($Package in $WantedPipPackages) {
    if ($LocalPipPackagesInstalled | ForEach-Object {$_ -like $Package+"*"} | Where-Object {$_ -eq $true}) {
      Write-Host "Package $Package already installed."
    } else {
      Write-Host "Installing package $Package to user space."
      Start-Process -FilePath "pip" -ArgumentList "install $Package --user" -NoNewWindow -Wait
    }
  }
}