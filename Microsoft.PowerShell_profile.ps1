Import-Module -Name Get-ChilditemColor

Import-Module -Name posh-git
Import-Module -Name oh-my-posh
#Set-Theme Material

Set-Alias -Name vim -Value notepad++.exe
Set-Alias l Get-ChildItemColor -Option AllScope
Set-Alias ls Get-ChildItemColorFormatWide -Option AllScope

function Get-HtmlViaPandoc($MarkdownFile) {
    $stopwatch =  [system.diagnostics.stopwatch]::StartNew()
    Start-Process -FilePath pandoc.exe -ArgumentList "-t html5 -s --data-dir $env:Pandoc_Datadir --template=GitHub --toc -o $MarkdownFile.html $MarkdownFile" -NoNewWindow -Wait
    Invoke-Item -Path "$MarkdownFile.html"
    $stopwatch | Select-Object -Property Elapsed
}

function Get-PdfViaPandoc($MarkdownFile){
    $stopwatch =  [system.diagnostics.stopwatch]::StartNew()
    Start-Process -FilePath pandoc.exe -ArgumentList "--number-sections --data-dir $env:Pandoc_Datadir --template eisvogel --pdf-engine=xelatex -V colorlinks --listings -o $MarkdownFile.pdf $MarkdownFile" -NoNewWindow -Wait
    Invoke-Item -Path "$MarkdownFile.pdf"
    $stopwatch | Select-Object -Property Elapsed
}