param(
    [string]$MainFile = "main.tex",
    [switch]$KeepSyncTeX
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $PSCommandPath
$pdfFile = [System.IO.Path]::ChangeExtension($MainFile, ".pdf")
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($MainFile)
$basePath = Join-Path $scriptDir $baseName

Push-Location $scriptDir
try {
    latexmk -pdf -interaction=nonstopmode -synctex=1 $MainFile
    $buildExitCode = $LASTEXITCODE

    if ($buildExitCode -ne 0) {
        latexmk -pdf -g -f -interaction=nonstopmode -synctex=1 $MainFile
        $buildExitCode = $LASTEXITCODE
    }

    if (Test-Path -LiteralPath $pdfFile) {
        if ($KeepSyncTeX) {
            @(
                '.aux',
                '.bcf',
                '.blg',
                '.fdb_latexmk',
                '.fls',
                '.idx',
                '.ilg',
                '.ind',
                '.lof',
                '.log',
                '.lot',
                '.nav',
                '.out',
                '.run.xml',
                '.snm',
                '.toc',
                '.vrb'
            ) | ForEach-Object {
                $target = "$basePath$_"
                if (Test-Path -LiteralPath $target) {
                    Remove-Item -LiteralPath $target -Force
                }
            }
        }
        else {
            latexmk -c $MainFile
            if ($LASTEXITCODE -ne 0 -and $buildExitCode -eq 0) {
                exit $LASTEXITCODE
            }
        }
    }

    exit $buildExitCode
}
finally {
    Pop-Location
}
