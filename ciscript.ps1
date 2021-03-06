param (
   [string]$script
)

$cirepos = @(
    "Antiforgery",
    "AspNetCoreModule",
    "AzureIntegration",
    "BasicMiddleware",
    "BrowserLink",
    "Caching",    
    "Coherence",
    "Coherence-Signed",
    "Common",
    "Configuration",
    "CORS",
    "DataProtection",
    "DependencyInjection",
    "Diagnostics",
    "DotNetTools",
    "EntityFramework",    
    "Entropy",
    "EventNotification",
    "FileSystem",
    "Hosting",
    "HtmlAbstractions",
    "HttpAbstractions",
    "HttpSysServer",
    "Identity",
    "IISIntegration",
    "JavaScriptServices",
    "JsonPatch",
    "KestrelHttpServer",
    "Localization",
    "Logging",
    "MetaPackages",
    "Microsoft.Data.Sqlite",
    "MusicStore",
    "Mvc",
    "MvcPrecompilation",
    "Options",
    "PlatformAbstractions",
    "Proxy",
    "Razor",
    "ResponseCaching",
    "Routing",
    "Scaffolding",
    "Security",
    "ServerTests",
    "Session",
    "Setup",
    "SignalR",
    "StaticFiles",
    "Testing",
    "WebSockets")

$allReposPresent = $TRUE

$repoDir = ".r"

if (-Not(Test-Path $repoDir))
{
    mkdir $repoDir
}

Set-Location $repoDir

foreach ($repo in $cirepos)
{
	if (-Not(Test-Path $repo))
	{
		Write-Output "Could not locate repo '$repo'."
		
		$clone = "y"
		
		if ($clone -eq "y")
		{
			git clone "git@github.com:aspnet/$repo"
		}
		else
		{
			$allReposPresent = $FALSE
		}
	}
}

if (-Not ($allReposPresent))
{
	Write-Output "Not all repos are present, aborting." 
	return
}
	
foreach ($repo in $cirepos)
{
	Write-Output "START Repo: $repo"
	& $script $repo
	Write-Output "END Repo: $repo"
}

Set-Location ".."
