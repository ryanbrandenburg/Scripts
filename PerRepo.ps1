Function Set-File($match, $contents) {
    Set-Content -Path $match -Value $contents
    return $true
}

Function Replace-File($source, $destination) {
    Copy-Item -Path $source -Destination $destination -Force
    return $true
}

Function Update-Files($path, $match, $find, $replace) {
    if (Test-Path $path) {
        Write-Output "$path found"
        $csprojs = Get-ChildItem -Path $path -Include $match -Recurse -File
        foreach ($csproj in $csprojs) {
            Write-Output "Updating $($csproj.FullName)"
            Update-File $csproj.FullName $find $replace
        }
    }
}

Function Update-Regex($path, $regex, $replace) {
    $content = Get-Content $path -Raw
    $content = $content -replace $regex, $replace

    Set-Content -Path $path -Value $content -NoNewline
}

Function Update-File($path, $find, $replace) {
    $fileContent = Get-Content $path -Raw -Encoding UTF8
    if ($fileContent -eq $null) {
        return $false
    }

    if ($fileContent.Contains($find)) {
        $fileContent.replace($find, $replace) | Set-Content -Path $path -NoNewline

        $fileInfo = Get-Item $path

        . "$PSScriptRoot/Remove-Utf8BOM.ps1"
        Remove-Utf8BOM $fileInfo -Verbose

        return $true
    }
    else {
        $fileContent = get-content -Raw $path -Encoding UTF8
        Write-Output "Couldn't find '$find' in '$fileContent'"
    }

    return $false
}

Function Create-PR($newBranch, $prMessage) {
    hub pull-request -m `"$prMessage`" -b dev -h $newBranch 
}

Function Exists-InFile($string, $file) {
    return Select-String -Pattern $string -Path $file -Quiet 
}

Function PerRepo($repo, $test) {
    Push-Location $repo
    try {
        $message = "Adding VSTS file"
        $newBranch = "rybrande/VSTS"

        $upstreamBranch = "origin/dev"

        git fetch
        git checkout .
        git checkout $upstreamBranch
        git branch -D $newBranch

        git checkout -tb $newBranch $upstreamBranch
        git clean -xdf

        Write-Output "Creating folder"
        
        $buildDir = ".vsts-pipelines/builds"

        if (!(Test-Path $buildDir)) {
            New-Item -Path $buildDir -ItemType Directory
        }

        $publicUrl = "https://raw.githubusercontent.com/aspnet/Common/dev/.vsts-pipelines/builds/ci-public.yml"
        $publicFile = Join-Path $buildDir "ci-public.yml"

        $internalUrl = "https://raw.githubusercontent.com/aspnet/Common/dev/.vsts-pipelines/builds/ci-internal.yml"
        $internalFile = Join-Path $buildDir "ci-internal.yml"

        if (!(Test-Path -Path $publicFile)) {
            Invoke-WebRequest -Uri $publicUrl -OutFile $publicFile
        }
        
        if (!(Test-Path -Path $internalFile)) {
            Invoke-WebRequest -Uri $internalUrl -OutFile $internalFile
        }

        if (!$test) {
            Write-Output "Creating PR for $repo"
            git add $buildDir
            git commit -am $message
            git push -f origin HEAD:$newBranch
            Create-PR $newBranch $message
        }
        else {
            Write-Output "Didn't commit cause this is a test."
        }
        Write-Output "\n"
    }
    finally {
        Pop-Location
    }
}
