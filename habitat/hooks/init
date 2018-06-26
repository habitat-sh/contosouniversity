Set-Location {{pkg.svc_path}}
if(Test-Path var) { Remove-Item var -Recurse -Force }
New-Item -Name var -ItemType Junction -target "{{pkg.path}}/www" | Out-Null
Set-Location {{pkg.svc_path}}\var
New-Item -Name Web.config -ItemType SymbolicLink -target "{{pkg.svc_config_path}}/Web.config" -Force | Out-Null
