# Windows Config Stuff

Scripts and configs for my Windows environment

## Install-DocTools.ps1

Script to install my documentation tools and make some relevant config
settings.

### Features

- Create Download directory (if not present)
- Basic pre-checks to see if tools are already installed (confirm, to reinstall)
- Download **[Pandoc](https://pandoc.org/)** (zip) and _install as portable_
- Download **[MiKTeX](https://miktex.org/)** (installer) and _silent install as portable_
- Download **[Git](https://git-scm.com/)** (zip) and _install as portable_
- Download **[Visual Studio Code](https://code.visualstudio.com/)** (user installer) and _install as single user_
- Download **[XMind 8](https://www.xmind.net/xmind8-pro/)** (zip) and _install as portable_
- _Set path variable_ (w/ some error checking before)
- Optionally (user confirmation required)
  - Install **Python** silently for single user (if it doesn't find it in path)

### How to use

```PowerShell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/gengor-git/windows-config/master/Install-DocTools.ps1'))
```

## Install-DocConfiguration.ps1

Installs the configurations and templates needed to run pandoc with nicer outputs.

Requires a local directory (`C:\temp\`), network-share or WebDAV-Source (`\\server\folder`) which contains the snapshot zip of the toolkit!!

### How to use

```PowerShell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/gengor-git/windows-config/master/Install-DocConfiguration.ps1'))
```

## Backlog

- [ ] Possibly switch to [DSC](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_desiredstateconfiguration?view=powershell-5.1) for environment variables
