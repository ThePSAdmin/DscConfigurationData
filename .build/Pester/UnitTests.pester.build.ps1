Param (
    [io.DirectoryInfo]
    $ProjectPath = (property ProjectPath (Join-Path $PSScriptRoot '../..' -Resolve -ErrorAction SilentlyContinue)),

    [string]
    $BuildOutput = (property BuildOutput 'C:\BuildOutput'),

    [string]
    $ProjectName = (property ProjectName (Split-Path -Leaf (Join-Path $PSScriptRoot '../..')) ),

    [string]
    $RelativePathToUnitTests = (property RelativePathToUnitTests 'tests/Unit'),

    [string]
    $LineSeparation = (property LineSeparation ('-' * 78))
)

task UnitTest {
    $LineSeparation
    "`t`t`t RUNNING UNIT TESTS"
    $LineSeparation
    "`tProject Path = $ProjectPath"
    "`tProject Name = $ProjectName"
    "`tUnit Tests   = $RelativePathToUnitTests"
    $UnitTestPath = [io.DirectoryInfo][system.io.path]::Combine($ProjectPath,$ProjectName,$RelativePathToUnitTests)
    
    if (!$UnitTestPath.Exists -and
        (   #Try a module structure where the
            $UnitTestPath = [io.DirectoryInfo][system.io.path]::Combine($ProjectPath,$RelativePathToUnitTests) -and
            !$UnitTestPath.Exists
        )
    )
    {
        Throw ('Cannot Execute Unit tests, Path Not found {0}' -f $UnitTestPath)
    }

    "`tUnitTest Path: $UnitTestPath"
    if (![io.path]::IsPathRooted($BuildOutput)) {
        $BuildOutput = Join-Path -Path $ProjectPath.FullName -ChildPath $BuildOutput
    }
    # $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(".\nonexist\foo.txt")
    $PSVersion = $PSVersionTable.PSVersion.Major
    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $FileName = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $TestFilePath = Join-Path -Path $BuildOutput -ChildPath $FileName
    
    if (!(Test-Path $BuildOutput)) {
        mkdir $BuildOutput -Force
    }
    ''
    Push-Location $UnitTestPath

    $script:UnitTestResults = Invoke-Pester -ErrorAction Stop -OutputFormat NUnitXml -OutputFile $TestFilePath -PassThru
    
    Pop-Location
}

task FailBuildIfFailedUnitTest -If ($script:UnitTestResults.FailedCount -ne 0) {
    assert ($script:UnitTestResults.FailedCount -eq 0) ('Failed {0} Unit tests. Aborting Build' -f $script:UnitTestResults.FailedCount)
}

task UnitTestsStopOnFail UnitTests,FailBuildIfFailedUnitTest