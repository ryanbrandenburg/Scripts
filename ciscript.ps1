param (
    [bool]$test = $true
)
$ErrorActionPreference = 'Stop'

$cirepos = @(
    "AADIntegration",
    "Antiforgery",
    "AuthSamples",
    "AzureIntegration",
    "BasicMiddleware",
    "BrowserLink",
    "CORS",
    "Caching",
    #"Common",
    "Configuration",
    "DataProtection",
    "DependencyInjection",
    "Diagnostics",
    "DotNetTools",
    "EntityFrameworkCore",
    "EventNotification",
    "FileSystem",
    "Hosting",
    "HtmlAbstractions",
    "HttpAbstractions",
    "HttpClientFactory",
    "HttpSysServer",
    #"IISIntegration",
    "Identity",
    "JavaScriptServices",
    "JsonPatch",
    "KestrelHttpServer",
    "Localization",
    "Logging",
    "MetaPackages",
    "Microsoft.Data.Sqlite",
    "MusicStore",
    #"Mvc",
    "MvcPrecompilation",
    "Options",
    "Proxy",
    "Razor",
    "ResponseCaching",
    "Routing",
    "Scaffolding",
    "Security",
    "ServerTests",
    "Session",
    #"SignalR",
    "StaticFiles",
    "Templating",
    "WebHooks",
    "WebSockets"
)

$allReposPresent = $TRUE

$repoDir = ".r"

if (-Not(Test-Path $repoDir)) {
    mkdir $repoDir
}

Push-Location $repoDir

try {
    foreach ($repo in $cirepos) {
        Write-Output "Looking for $repo"
        if (-Not(Test-Path $repo)) {
            Write-Output "Could not locate repo '$repo'."

            $clone = "y"

            if ($clone -eq "y") {
                git clone "git@github.com:aspnet/$repo"
            }
            else {
                $allReposPresent = $FALSE
            }
        }
        else {
            Write-Output "Found $repo"
        }
    }
    if (-Not ($allReposPresent)) {
        Write-Output "Not all repos are present, aborting." 
    }
    else {
        foreach ($repo in $cirepos) {
            Write-Output "START Repo: $repo"
            . "$PSScriptRoot/PerRepo.ps1"
            PerRepo $repo $test
            Write-Output "END Repo: $repo"
        }
    }
}
finally {
    Pop-Location
}
