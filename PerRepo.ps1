Function Set-File($match, $contents)
{
    Set-Content -Path $match -Value $contents
    return $true
}

Function Update-File($match, $find, $replace)
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
                . "$PSScriptRoot/Remove-Utf8BOM.ps1"
                Remove-Utf8BOM $path

                return $true
            }
        }
    }

    return $false
}

Function PerRepo($repo, $test)
{
    Set-Location $repo
    Write-Output "$repo"
    
    $message = "Set AspNetCoreVersion"
    $newBranch = "rybrande/AspNetCoreVersion"
    $match = 'dependencies.props'
    $find = "<AspNetCoreVersion>2.0.0-*</AspNetCoreVersion>"
    $replace = "<AspNetCoreVersion>2.1.0-*</AspNetCoreVersion>"

    git branch -d $newBranch
    git fetch
    git checkout -tb $newBranch origin/dev
    #git clean -xdf
    
    Write-Output "Test: $test"

    $updateResult = Update-File $match $find $replace

    if($updateResult -and !$test)
    {
        Write-Output "Commiting"
        # git commit -am $message
        # Write-Output "Pushing $repo"
        # git push origin $newBranch:dev

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
