#!/usr/bin/env pwsh -c

[cmdletbinding()]
param(

)

$ErrorActionPreference = 'Stop'

function Invoke-Block([scriptblock]$cmd) {
    $cmd | Out-String | Write-Verbose
    & $cmd

    # Need to check both of these cases for errors as they represent different items
    # - $?: did the powershell script block throw an error
    # - $lastexitcode: did a windows command executed by the script block end in error
    if ((-not $?) -or ($lastexitcode -ne 0)) {
        Write-Warning $error[0]
        throw "Command failed to execute: $cmd"
    }
}

$repos = Get-ChildItem -Path "D:\dd"

foreach ($repo in $repos) {
    Push-Location -Path $repo
    try {
        if (Test-Path -Path ".git") {
            Write-Host "Repo $repo"
            Invoke-Block { git fetch }
        
            $branches = Invoke-Block { git branch --list }
            foreach ($branch in $branches) {
                $branch = $branch.Trim()
                Write-Host "    $branch"
                try {
                    Invoke-Block { git checkout $branch }
                    Invoke-Block { git pull --rebase }
                }
                catch($ex) {
                    Write-Error "EX: $ex"
                    Write-Error "$repo is probably dirty"
                    break
                }
            }
        }
        else {
            Write-Host "$repo is not a Git repo"
        }
        break
    }
    finally {
        Pop-Location
    }
}