[CmdletBinding()]
param (
)

$ErrorActionPreference = "Stop"

$scriptName = Split-Path $MyInvocation.MyCommand.Path -Leaf

Write-Verbose ("Executing " + $scriptName)

function CheckLastExitCode {
    param ([int[]]$SuccessCodes = @(0), [scriptblock]$CleanupScript=$null)

    if ($SuccessCodes -notcontains $LastExitCode) {
        if ($CleanupScript) {
            "Executing cleanup script: $CleanupScript"
            &$CleanupScript
        }
        $msg = @"
EXE RETURNED EXIT CODE $LastExitCode
CALLSTACK:$(Get-PSCallStack | Out-String)
"@
        throw $msg
    }
}

function MSBuild
{
    param (
        [String] $pathToMSBuild,
        [String] $pathToSolution,
        [String[]] $arguments
    )

    &$pathToMSBuild $pathToSolution $arguments
    CheckLastExitCode
}

function MSBuildNet35
{
    param (
        [String] $pathToSolution,
        [String[]] $arguments
    )
    $pathToMSBuild = "C:\Windows\Microsoft.NET\Framework\v3.5\MSBuild.exe"

    MSBuild $pathToMSBuild $pathToSolution $arguments
}

function MSBuildNet40
{
    param (
        [String] $pathToSolution,
        [String[]] $arguments
    )
    $pathToMSBuild = "C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe"

    MSBuild $pathToMSBuild $pathToSolution $arguments
}

Import-Module DevFacto.Automation -Force

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptName = Split-Path -Leaf $MyInvocation.MyCommand.Path

$rootDir = Split-Path -Parent $scriptRoot
$version = Get-Content ($rootDir + "\version.txt")

pushd $rootDir

Write-Output "Building Solution"

MSBuildNet40 'source\CustomerSurveys.sln' @('/p:Configuration=Release')

popd

Write-Verbose ($scriptName + " complete")
