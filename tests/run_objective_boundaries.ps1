#requires -Version 7.0
[CmdletBinding()]
param([string]$GodotBin, [string]$OutputRoot = [IO.Path]::GetTempPath())
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'run_g2_checks.ps1') -GodotBin $GodotBin -OutputRoot $OutputRoot
$repository = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$directory = Join-Path $OutputRoot ('dungeon-objective-boundaries-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $directory | Out-Null
$scene = 'res://tests/smoke/objective_boundary_smoke.tscn'
$checks = [Collections.Generic.List[object]]::new()
$hash = Get-G2SourceHash $repository
foreach ($action in @('select', 'cancel', 'reserve', 'start', 'settle', 'recover_reserved', 'recover_started')) {
    foreach ($after in @($false, $true)) {
        $name = $action + $(if ($after) { '-after' } else { '-before' })
        $session = Join-Path $directory $name
        New-Item -ItemType Directory -Path $session | Out-Null
        $start = [Diagnostics.ProcessStartInfo]::new()
        $start.FileName = $GodotBin
        $start.WorkingDirectory = $repository
        $start.UseShellExecute = $false
        $start.CreateNoWindow = $true
        $start.RedirectStandardOutput = $true
        $start.RedirectStandardError = $true
        $arguments = @('--headless', '--path', $repository, '--fixed-fps', '60', $scene, '--', '--boundary-mode=stop', "--action=$action", "--objective-directory=$session")
        if ($after) { $arguments += '--boundary-after' }
        foreach ($argument in $arguments) { $start.ArgumentList.Add($argument) }
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
        $arguments = @('--fixed-fps', '60', $scene, '--', '--boundary-mode=verify', "--action=$action", "--objective-directory=$session")
        if ($after) { $arguments += '--boundary-after' }
        $result = Invoke-GodotCheck -Executable $GodotBin -Repository $repository -LogDirectory $directory -Name $name -Arguments $arguments -Expected '\[SmokeTest\] objective_boundary_passed' -LimitSeconds 30
        $checks.Add($result)
        if (-not $result.passed) { throw "Failed $name; see $directory" }
        Write-Host "PASS terminated/restarted $name"
    }
}
$report = [ordered]@{passed=$true; source_tree_sha256=$hash; checks=$checks; interrupted_boundaries=14}
if ((Get-G2SourceHash $repository) -ne $hash) { throw 'Sources changed during boundary checks.' }
$report | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath (Join-Path $directory 'results.json') -Encoding utf8
Write-Host "Results: $directory"
