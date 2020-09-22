# Windows Config Stuff

Scripts and configs for my Windows environment

## Install-DocTools.ps1

Script to install my documentation tools and make some relevant config
settings.

### Features

- Create Download directory (if not present)
- Basic pre-checks to see tools are already installed
- Download Pandoc & install as portable
- Download MiKTeX (installer) and silent install as portable
- Set path variable (w/ some error checking before)
- Optionally install Python silent for single user

### How to use

```PowerShell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/gengor-git/windows-config/master/Install-DocTools.ps1'))
```

### Backlog

- [ ] Possibly switch to [DSC](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_desiredstateconfiguration?view=powershell-5.1) for environment variables