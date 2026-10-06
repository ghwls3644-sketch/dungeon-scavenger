#requires -Version 7.0
[CmdletBinding()]
param([string]$GodotBin, [string]$OutputRoot = [IO.Path]::GetTempPath())
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'run_g2_checks.ps1') -GodotBin $GodotBin -OutputRoot $OutputRoot
$repository = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$directory = Join-Path $OutputRoot ('dungeon-lure-boundaries-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $directory | Out-Null
$scene = 'res://tests/smoke/lure_departure_smoke.tscn'
$checks = [Collections.Generic.List[object]]::new()
$hash = Get-G2SourceHash $repository
foreach ($number in 1..3) {
    foreach ($after in @($false, $true)) {
        $name = "save-$number-" + $(if ($after) { 'after' } else { 'before' })
        $session = Join-Path $directory $name
        New-Item -ItemType Directory -Path $session | Out-Null
        $start = [Diagnostics.ProcessStartInfo]::new()
        $start.FileName = $GodotBin
        $start.WorkingDirectory = $repository
        $start.UseShellExecute = $false
        $start.CreateNoWindow = $true
        $start.RedirectStandardOutput = $true
        $start.RedirectStandardError = $true
        foreach ($arg in @('--headless', '--path', $repository, $scene, '--', '--boundary-mode=stop', "--boundary-call=$number", "--lure-directory=$session")) { $start.ArgumentList.Add($arg) }
        if ($after) { $start.ArgumentList.Add('--boundary-after') }
        $process = [Diagnostics.Process]::new()
        $process.StartInfo = $start
        $null = $process.Start()
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        $timer = [Diagnostics.Stopwatch]::StartNew()
        $ready = Join-Path $session 'boundary.ready'
        while (-not (Test-Path -LiteralPath $ready) -and -not $process.HasExited -and $timer.Elapsed.TotalSeconds -lt 20) { Start-Sleep -Milliseconds 100 }
        $reached = Test-Path -LiteralPath $ready
        if (-not $process.HasExited) { $process.Kill($true) }
        $process.WaitForExit()
        $output = $stdout.GetAwaiter().GetResult() + $stderr.GetAwaiter().GetResult()
        [IO.File]::WriteAllText((Join-Path $session 'stopped.log'), $output)
        $process.Dispose()
        if (-not $reached -or $output -match '(SCRIPT ERROR|ERROR:)') { throw "Failed to reach $name; see $session" }
        $saved = Get-Content -LiteralPath (Join-Path $session 'progress.json') -Raw | ConvertFrom-Json
        $stock = if (($number -eq 2 -and $after) -or ($number -eq 3 -and -not $after)) { 0 } else { 2 }
        $next = if ($number -eq 1 -and -not $after) { 1 } else { 2 }
        $expectedPhase = if (($number -eq 1 -and $after) -or ($number -eq 2 -and -not $after)) { 'reserved' } elseif ($stock -eq 0) { 'started' } else { $null }
        if ($saved.hub.pending_departure.phase -ne $expectedPhase) { throw "Incorrect persisted phase at $name" }
        $modes = if ($null -eq $expectedPhase) { @('resume') } else { @('resume-retry', 'resume') }
        foreach ($mode in $modes) {
            $result = Invoke-GodotCheck -Executable $GodotBin -Repository $repository -LogDirectory $directory -Name "$name-$mode" -Arguments @($scene, '--', "--boundary-mode=$mode", "--lure-directory=$session", "--expected-stock=$stock", "--expected-next=$next") -Expected '\[SmokeTest\] lure_departure_passed' -LimitSeconds 30
            $checks.Add($result)
            if (-not $result.passed) { throw "Failed $name-$mode; see $directory" }
        }
        Write-Host "PASS terminated/restarted $name"
    }
}
$report = [ordered]@{passed=$true; source_tree_sha256=$hash; checks=$checks; interrupted_boundaries=6}
if ((Get-G2SourceHash $repository) -ne $hash) { throw 'Sources changed during boundary checks.' }
$report | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath (Join-Path $directory 'results.json') -Encoding utf8
Write-Host "Results: $directory"
