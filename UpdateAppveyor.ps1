param (
    [string]$repo
)

Function Replace($match, $find, $replace)
{
    foreach ($path in Get-ChildItem -recurse -include $match | Where-Object { test-path $_.fullname -pathtype leaf} ) {
        if ((Select-String -path $path -pattern $replace -CaseSensitive))
        {
            Write-Output "$path has already been worked on. Skipping."
        }
        else
        {
            if ((select-string -path $path -pattern $find -CaseSensitive)) {
                $fileContent = get-content -Raw $path -Encoding UTF8
                $fileContent = $fileContent -creplace $find, $replace
                
                [IO.File]::WriteAllText($path, $fileContent, [Text.Encoding]::UTF8)
            }
        }
    }
}

Function Append($match, $data)
{

    if (Test-Path $match)
    {
        Add-Content $match $data
    }
}

Set-Location $repo

Write-Output "START: Update Appveyor"

$newBranch = "rybrande/UpdateAppveyor"

git fetch
git checkout -tb $newBranch origin/dev
git clean -xdf
Replace 'appveyor.yml' "clone_depth: 1" "clone_depth: 1`nenvironment:`n  global:`n    DOTNET_SKIP_FIRST_TIME_EXPERIENCE: true`n    DOTNET_CLI_TELEMETRY_OPTOUT: 1"

$message = "Skip first time experience on Appveyor"

Write-Output "Commiting"
git commit -am $message
Write-Output "Pushing $repo"
git push -f origin $newBranch

$PRMessage = $message

Write-Output "Creating PR"
hub pull-request -b dev -h $newBranch -m $PRMessage

Set-Location ".."