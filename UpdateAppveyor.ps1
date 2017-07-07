param (
    [string]$repo
)

Function Work($match)
{
    foreach ($sc in dir -recurse -include $match | where ( test-path $_.fullname -pathtype leaf) ) {
        Add-Content $sc "`nenv:`n  global:`n    - DOTNET_SKIP_FIRST_TIME_EXPERIENCE: true`n    - DOTNET_CLI_TELEMETRY_OPTOUT: 1"
    }
}

cd $repo

echo "START: Update Appveyor"

$newBranch = "rybrande/UpdateAppveyor"

git fetch
git checkout -tb $newBranch origin/dev
git clean -xdf

Work 'appveyor.yml'

#$message = "AppVeyor skip first time experience"

#git commit -am $mesage
#git push origin $newBranch

#$PRMessage = $message

#hub pull-request -b dev -h $newBranch -m $PRMessage