Param (
    [string]
    $BuildSystem = (property BuildSystem 'unknown'),

    [string]
    $APPVEYOR_JOB_ID = $(try {property APPVEYOR_JOB_ID} catch {}),

    [string]
    $BuildOutput = (property BuildOutput 'C:\BuildOutput'),

    [string]
    $TestOutputPath = (property TestOutputPath 'testResults')
)

task UploadTestResultToAppVeyor -If ($BuildSystem -eq 'AppVeyor') {

    $TestResultFiles = Get-ChildItem -Path ([io.Path]::Combine($BuildOutput,$TestOutputPath)) -Filter *.xml
    foreach ($file in $TestResultFiles) {
        (New-Object 'System.Net.WebClient').UploadFile(
            "https://ci.appveyor.com/api/testresults/nunit/$APPVEYOR_JOB_ID",
            "$ProjectRoot\$file" )
    }
}

task DoSomething {
    '-'*78
    '-'*78
    '-'*78
    '-'*78
    'DO Something'
}