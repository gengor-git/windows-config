# Windows Config Stuff

Scripts and configs for my Windows environment

## Install-Docs-Tools.ps1

Script to install my documentation tools and make some relevant config
settings.

### Features

- Create Download directory (if not present)
- Basic pre-checks to see tools are already installed
- Download Pandoc & install as portable
- Download MiKTeX (installer) and silent install as portable
- Set path variable (w/ some error checking before)
- Optionally install Python silent for single user

### Backlog

- [ ] Possibly switch to [DSC](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_desiredstateconfiguration?view=powershell-5.1) for environment variables