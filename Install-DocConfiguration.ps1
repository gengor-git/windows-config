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
  Start-Process -FilePath "code" -ArgumentList "--install-extension chrischinchilla.vscode-pandoc"
  Start-Process -FilePath "code" -ArgumentList "--install-extension ms-ceintl.vscode-language-pack-de"
  Start-Process -FilePath "code" -ArgumentList "--install-extension eamodio.gitlens"
  Start-Process -FilePath "code" -ArgumentList "--install-extension yzhang.markdown-all-in-one"
  Start-Process -FilePath "code" -ArgumentList "--install-extension darkriszty.markdown-table-prettify"
  Start-Process -FilePath "code" -ArgumentList "--install-extension mechatroner.rainbow-csv"

  $pandoc_opt_pdf = "--number-sections --data-dir $LocalDocumentationToolkitDirectory --template eisvogel --pdf-engine=xelatex -V colorlinks --listings"
  $pandoc_opt_html = "-t html5 -s --self-contained --data-dir $LocalDocumentationToolkitDirectory --template=GitHub --toc"

  Write-Warning "Please add the following lines to your VS Code Settings `"pandoc.pdfOptString:`""
  Write-Host  $pandoc_opt_pdf

  Write-Warning "Please add the following lines to your VS Code Settings `"pandoc.htmlOptString:`""
  Write-Host $pandoc_opt_html
  #Get-Content -Path "$env:USERPROFILE\AppData\Roaming\code\user\settings.json"
}