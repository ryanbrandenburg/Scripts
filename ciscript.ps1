param (
   [string]$script
)

$cirepos = @(
"PlatformAbstractions",
                "Common",
                "JsonPatch",
                "FileSystem",
                "Configuration",
                "DependencyInjection",
                "EventNotification",
                "Options",
                "Logging",
                "dnx-watch",
                "HtmlAbstractions",
                "UserSecrets",
                "DataProtection",
                "HttpAbstractions",
                "Testing",
                "aspnet.xunit",
                "Microsoft.Data.Sqlite",
                "Caching",
                "Razor",
                "RazorTooling",
                "Hosting",
                "EntityFramework",
                "WebListener",
                "KestrelHttpServer",
                "IISIntegration",
                "ServerTests",
                "Session",
                "CORS",
                "Routing",
                "StaticFiles",
                "Diagnostics",
                "Security",
                "Antiforgery",
                "WebSockets",
                "Localization",
                "BasicMiddleware",
                "Proxy",
                "Mvc",
                "Identity",
                "Scaffolding",
                "SignalR-Server",
                "SignalR-SQLServer",
                "SignalR-Redis",
                "SignalR-ServiceBus",
                "BrowserLink",
                "Entropy",
                "MusicStore",
			  "DNX",
              "Coherence",
              "Coherence-Signed",
              "dnvm",
              "Setup")

# $cirepos = @(
# "PlatformAbstractions"
# "HtmlAbstractions",
# "Testing",
# "dnx",
# "CompilationAbstractions",
# "dnvm",
# "Common",
# "Configuration",
# "DependencyInjection",
# "Microsoft.Data.Sqlite",
# "EventNotification",
# "Options",
# "Logging",
# "UserSecrets",
# "DataProtection",
# "Caching",
# "HttpAbstractions",
# "aspnet.xunit",
# "FileSystem",
# "JsonPatch",
# "Razor",
# "RazorTooling",
# "Hosting",
# "EntityFramework",
# "WebListener",
# "libuv-build",
# "KestrelHttpServer",
# "IISIntegration",
# "ServerTests",
# "Diagnostics",
# "Antiforgery",
# "CORS",
# "Security",
# "Routing",
# "StaticFiles",
# "WebSockets",
# "Localization",
# "Session",
# "BasicMiddleware",
# "Proxy",
# "Mvc",
# "Identity",
# "Scaffolding",
# "SignalR-Server",
# "SignalR-SQLServer",
# "SignalR-Redis",
# "BrowserLink",
# "dnx-watch",
# "Entropy",
# "MusicStore",
# "Coherence",
# "Coherence-Signed"
# )

$allReposPresent = $TRUE

foreach ($repo in $cirepos)
{
	if (-Not(test-path $repo))
	{
		echo "Could not locate repo '$repo'."
		
		$clone = "y"
		#$clone = Read-Host "Clone?"
		
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
	echo "Not all repos are present, aborting." 
	return
}
	
foreach ($repo in $cirepos)
{
	echo "START Repo: $repo"
	& $script $repo
	echo "END Repo: $repo"
}