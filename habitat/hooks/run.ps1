# The Powershell Progress stream can sometimes interfere
# with the Supervisor output. Its non critical so turn it off
$ProgressPreference="SilentlyContinue"

# Leverage the Powershell Module in the dsc-core package
# that makes applying DSC configurations in Powershell
# Core simple.
Start-DscCore (Join-Path {{pkg.svc_config_path}} website.ps1) NewWebsite

# The svc_config_path lacks an ACL for the USERS group
# so we need to ensure the app pool user can access those files
$pool = "{{cfg.app_pool}}"
$access = New-Object System.Security.AccessControl.FileSystemAccessRule `
"IIS APPPOOL\$pool",`
"ReadAndExecute",`
"Allow"
$acl = Get-Acl "{{pkg.svc_config_path}}/Web.config"
$acl.SetAccessRule($access)
$acl | Set-Acl "{{pkg.svc_config_path}}/Web.config"

# The run hook must run indefinitely or else the Supervisor
# will think the service has terminated and will loop
# trying to restart it. The above DSC apply starts our
# application in IIS. We will continuously poll our app
# and cleanly shut down only if the application stops
# responding or if the Habitat service is stopped or
# unloaded.
try {
    Write-Host "{{pkg.name}} is running"
    $running = $true
    while($running) {
        Start-Sleep -Seconds 1
        $resp = Invoke-WebRequest "http://localhost:{{cfg.port}}/{{cfg.app_name}}" -Method Head
        if($resp.StatusCode -ne 200) { $running = $false }
    }
}
catch {
    Write-Host "{{pkg.name}} HEAD check failed"
}
finally {
    # Add any cleanup here which will run after supervisor stops the service
    Write-Host "{{pkg.name}} is stoping..."
    ."$env:SystemRoot\System32\inetsrv\appcmd.exe" stop apppool "{{cfg.app_pool}}"
    ."$env:SystemRoot\System32\inetsrv\appcmd.exe" stop site "{{cfg.site_name}}"
    Write-Host "{{pkg.name}} has stopped"
}
