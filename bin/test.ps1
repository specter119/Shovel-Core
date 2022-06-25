#!/usr/bin/env pwsh
Invoke-Pester "$PSScriptRoot\..\test"

exit $LASTEXITCODE
