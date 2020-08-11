# We need to install the xWebAdministration DSC resource.
# Habitat runs its hooks inside of Powershell Core but DSC
# configurations are applied in a hosted WMI process by
# Windows Powershell. In order for Windows Powershell to locate
# the installed resource, it must be installed using Windows
# Powershell instead of Powershell Core. We can use Invoke-Command
# and point to localhost to "remote" from Powershell Core to
# Windows Powershell.
Invoke-Command -ComputerName localhost -EnableNetworkAccess {
    $ProgressPreference="SilentlyContinue"
    Write-Host "Checking for nuget package provider..."
    if(!(Get-PackageProvider -Name nuget -ErrorAction SilentlyContinue -ListAvailable)) {
        Write-Host "Installing Nuget provider..."
        Install-PackageProvider -Name NuGet -Force | Out-Null
    }
    Write-Host "Checking for xWebAdministration PS module..."
    if(!(Get-Module xWebAdministration -ListAvailable)) {
        Write-Host "Installing xWebAdministration PS Module..."
        Install-Module xWebAdministration -Force | Out-Null
    }
}
