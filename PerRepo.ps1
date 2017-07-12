param (
    [string]$repo,
    [bool]$test
)

Function Set-File($match, $contents)
{
    Set-Content -Path $match -Value $contents
    return $true
}

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

                return $true
            }
        }
    }

    return $false
}

Function Append($match, $data)
{

    if (Test-Path $match)
    {
        Add-Content $match $data
    }
}

Function Main($repo, $test)
{
    Set-Location $repo
    
    $message = "Move to the new KoreBuild"
    $newBranch = "rybrande/KoreBuild"
    $match = 'build.ps1'
    $content = "Fake!"

    git fetch
    git checkout -tb $newBranch origin/dev
    git clean -xdf
    
    Write-Output "Test: $test"

    if((Set-File $match $content) -and !$test)
    {
        Write-Output "Commiting"
        # git commit -am $message
        # Write-Output "Pushing $repo"
        # git push -f origin $newBranch

        # $PRMessage = $message

        # Write-Output "Creating PR"
        # hub pull-request -b dev -h $newBranch -m $PRMessage
    }
    else
    {
        Write-Output "Didn't commit cause this is a test."
    }

    Set-Location ".."
}

Main $repo $test