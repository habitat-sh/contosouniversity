$pkg_name="contosouniversity"
$pkg_origin="mwrock"
$pkg_version="0.1.0"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=@("Apache-2.0")
$pkg_deps=@("core/dsc-core")
$pkg_build_deps=@("core/nuget")
$pkg_binds=@{"database"="username password port"}

  function Invoke-Build {
    Copy-Item $PLAN_CONTEXT/../* $HAB_CACHE_SRC_PATH/$pkg_dirname -recurse -force
    nuget restore "$HAB_CACHE_SRC_PATH/$pkg_dirname/C#/$pkg_name/packages.config" -PackagesDirectory "$HAB_CACHE_SRC_PATH/$pkg_dirname/C#/packages" -Source "https://www.nuget.org/api/v2"
    nuget install MSBuild.Microsoft.VisualStudio.Web.targets -Version 14.0.0.3 -OutputDirectory $HAB_CACHE_SRC_PATH/$pkg_dirname/
    $env:VSToolsPath = "$HAB_CACHE_SRC_PATH/$pkg_dirname/MSBuild.Microsoft.VisualStudio.Web.targets.14.0.0.3/tools/VSToolsPath"
    ."$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe" "$HAB_CACHE_SRC_PATH/$pkg_dirname/C#/$pkg_name/${pkg_name}.csproj" /t:Build /p:VisualStudioVersion=14.0
    if($LASTEXITCODE -ne 0) {
        Write-Error "dotnet build failed!"
    }
  }
  
  function Invoke-Install {
    ."$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe" "$HAB_CACHE_SRC_PATH/$pkg_dirname/C#/$pkg_name/${pkg_name}.csproj" /t:WebPublish /p:WebPublishMethod=FileSystem /p:publishUrl=$pkg_prefix/www
  }