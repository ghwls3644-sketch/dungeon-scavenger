#requires -Version 7.0
[CmdletBinding()]
param(
    [string]$GodotBin = $env:GODOT_BIN,
    [ValidateRange(1, 10)][int]$Repetitions = 2,
    [string]$OutputRoot = [IO.Path]::GetTempPath(),
    [ValidateRange(1, 120)][int]$TimeoutSeconds = 30,
    [switch]$AllowCertificateStoreWarning
)

$ErrorActionPreference = 'Stop'

function Invoke-GodotCheck {
    param(
        [string]$Executable,
        [string]$Repository,
        [string]$LogDirectory,
        [string]$Name,
        [string[]]$Arguments,
        [string]$Expected,
        [int]$LimitSeconds = 30,
        [bool]$AllowCertificateWarning = $false
    )
    $consolePath = Join-Path $LogDirectory "$Name.console.log"
    $enginePath = Join-Path $LogDirectory "$Name.engine.log"
    $start = [Diagnostics.ProcessStartInfo]::new()
    $start.FileName = $Executable
    $start.WorkingDirectory = $Repository
    $start.UseShellExecute = $false
    $start.CreateNoWindow = $true
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $start.StandardOutputEncoding = [Text.Encoding]::UTF8
    $start.StandardErrorEncoding = [Text.Encoding]::UTF8
    foreach ($argument in (@('--headless', '--path', $Repository, '--log-file', $enginePath) + $Arguments)) {
        $start.ArgumentList.Add($argument)
    }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $start
    $timer = [Diagnostics.Stopwatch]::StartNew()
    try {
        if (-not $process.Start()) { throw "Cannot launch $Name" }
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        $timedOut = -not $process.WaitForExit($LimitSeconds * 1000)
        if ($timedOut) {
            # Terminate only this runner's process tree, never another Godot session.
            $process.Kill($true)
            $process.WaitForExit()
        }
        $output = $stdout.GetAwaiter().GetResult() + "`n" + $stderr.GetAwaiter().GetResult()
        $exitCode = $process.ExitCode
    } finally {
        $timer.Stop()
        $process.Dispose()
    }
    $plainOutput = [regex]::Replace($output, '\x1b\[[0-9;]*m', '')
    [IO.File]::WriteAllText($consolePath, $plainOutput, [Text.UTF8Encoding]::new($false))
    $combined = $plainOutput
    if (Test-Path -LiteralPath $enginePath) { $combined += "`n" + [IO.File]::ReadAllText($enginePath) }
    $diagnostics = @($combined -split '\r?\n' | Where-Object { $_ -match '^\s*(ERROR|SCRIPT ERROR|WARNING):' } | ForEach-Object { $_.Trim() } | Sort-Object -Unique)
    $ignored = @()
    if ($AllowCertificateWarning) {
        $ignored = @($diagnostics | Where-Object { $_ -eq 'ERROR: Failed to read the root certificate store.' })
        $diagnostics = @($diagnostics | Where-Object { $_ -ne 'ERROR: Failed to read the root certificate store.' })
    }
    $markerFound = $combined -match $Expected
    return [ordered]@{
        name = $Name
        arguments = $Arguments
        expected_pattern = $Expected
        passed = (-not $timedOut -and $exitCode -eq 0 -and $markerFound -and $diagnostics.Count -eq 0)
        exit_code = $exitCode
        timed_out = $timedOut
        marker_found = $markerFound
        duration_ms = $timer.ElapsedMilliseconds
        diagnostics = @($diagnostics)
        ignored_diagnostics = @($ignored)
        console_log = "$Name.console.log"
    }
}

function Get-G2SourceHash {
    param([string]$Repository)
    $files = @(Get-ChildItem -LiteralPath (Join-Path $Repository 'src'), (Join-Path $Repository 'tests') -File -Recurse)
    $files += Get-Item -LiteralPath (Join-Path $Repository 'project.godot')
    $lines = foreach ($file in ($files | Sort-Object FullName)) {
        $relative = [IO.Path]::GetRelativePath($Repository, $file.FullName).Replace('\', '/')
        "$relative $((Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant())"
    }
    $bytes = [Text.Encoding]::UTF8.GetBytes(($lines -join "`n") + "`n")
    return [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
}

function Start-G2Checks {
    if ([string]::IsNullOrWhiteSpace($GodotBin) -or -not (Test-Path -LiteralPath $GodotBin -PathType Leaf)) {
        throw 'Set GODOT_BIN or pass -GodotBin with the Godot 4.7.1 console executable.'
    }
    $repository = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
    $executable = (Resolve-Path -LiteralPath $GodotBin).Path
    $runDirectory = Join-Path ([IO.Path]::GetFullPath($OutputRoot)) ('dungeon-g2-' + [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $runDirectory | Out-Null
    $checks = [Collections.Generic.List[object]]::new()
    $flows = [Collections.Generic.List[object]]::new()
    $revision = & git -c "safe.directory=$repository" -C $repository rev-parse HEAD
    if ($LASTEXITCODE -ne 0) { throw 'Cannot identify the repository revision.' }
    $report = [ordered]@{
        report_version = 1
        scope = 'DEV-0206 / G2 approved prototype loop'
        started_at_utc = [DateTime]::UtcNow.ToString('o')
        repository_commit = "$revision".Trim()
        source_tree_sha256 = Get-G2SourceHash $repository
        requested_repetitions = $Repetitions
        completed_repetitions = 0
        certificate_exception_enabled = [bool]$AllowCertificateStoreWarning
        passed = $false
        failure = $null
        checks = $checks
        flows = $flows
    }
    function Run-Case([string]$Name, [string[]]$Arguments, [string]$Expected) {
        $result = Invoke-GodotCheck -Executable $executable -Repository $repository -LogDirectory $runDirectory -Name $Name -Arguments $Arguments -Expected $Expected -LimitSeconds $TimeoutSeconds -AllowCertificateWarning ([bool]$AllowCertificateStoreWarning)
        $checks.Add($result)
        if (-not $result.passed) { throw "Failed $Name; see $($result.console_log)" }
        Write-Host "PASS $Name"
    }
    function Run-Scene([string]$Name, [string]$Scene, [string]$Expected, [string[]]$UserArguments = @()) {
        $arguments = @('--fixed-fps', '60', '--quit-after', '20000', "res://tests/smoke/$Scene.tscn")
        if ($UserArguments.Count -gt 0) { $arguments += @('--') + $UserArguments }
        Run-Case $Name $arguments $Expected
    }
    try {
        Run-Case 'engine-version' @('--version') '^4\.7\.1\.stable\.'
        Run-Case 'project-import' @('--editor', '--quit') 'Godot Engine v4\.7\.1\.stable\.'
        for ($round = 1; $round -le $Repetitions; $round++) {
            $prefix = "round-$round"
            $survivalSession = Join-Path $runDirectory "$prefix-survival-session"
            $appraisalSession = Join-Path $runDirectory "$prefix-appraisal-session"
            $saleSession = Join-Path $runDirectory "$prefix-sale-session"
            foreach ($scene in (Get-ChildItem -LiteralPath (Join-Path $repository 'tests/smoke') -Filter '*.tscn' | Sort-Object Name)) {
                $marker = $scene.BaseName -replace '_smoke$', '_passed'
                if ($marker -eq 'game_state_flow_passed') { $marker = 'state_flow_passed' }
                $sceneArguments = @()
                if ($scene.BaseName -eq 'g3_survival_flow_smoke') { $sceneArguments = @("--review-progress-directory=$survivalSession") }
                if ($scene.BaseName -eq 'hub_appraisal_smoke') { $sceneArguments = @("--appraisal-directory=$appraisalSession") }
                if ($scene.BaseName -eq 'hub_sale_smoke') { $sceneArguments = @("--sale-directory=$saleSession") }
                Run-Scene "$prefix-$($scene.BaseName)" $scene.BaseName "\[SmokeTest\] $marker(?:\s|$)" $sceneArguments
            }
            Run-Scene "$prefix-survival-continue" 'g3_survival_flow_smoke' '\[SmokeTest\] g3_survival_flow_passed continue' @('--review-continue', "--review-progress-directory=$survivalSession")
            Run-Scene "$prefix-appraisal-continue" 'hub_appraisal_smoke' '\[SmokeTest\] hub_appraisal_passed continue' @('--appraisal-continue', "--appraisal-directory=$appraisalSession")
            Run-Scene "$prefix-sale-continue" 'hub_sale_smoke' '\[SmokeTest\] hub_sale_passed continue' @('--sale-continue', "--sale-directory=$saleSession")
            Run-Scene "$prefix-continue" 'title_screen_smoke' '\[SmokeTest\] title_screen_passed' @('--title-case=continue')
            Run-Scene "$prefix-quit" 'title_screen_smoke' '\[GameEntry\] quit_requested' @('--title-case=quit')
            foreach ($case in @('three', 'failure')) {
                Run-Scene "$prefix-departure-$case" 'hub_departure_smoke' '\[SmokeTest\] hub_departure_passed' @("--departure-case=$case")
            }
            foreach ($case in @('invalid', 'future')) {
                Run-Scene "$prefix-settings-$case" 'settings_smoke' "\[SmokeTest\] settings_passed $case" @("--settings-case=$case")
            }
            foreach ($case in @('replace', 'invalid', 'future', 'unknown_id', 'disappeared')) {
                Run-Scene "$prefix-progress-$case" 'progress_save_smoke' "\[SmokeTest\] progress_save_passed $case" @("--progress-case=$case")
            }
            Run-Case "$prefix-startup" @('--quit-after', '20') 'transition_completed from=Boot to=Title'
            foreach ($state in @('Boot', 'Title', 'Hub', 'Exploration', 'Results')) {
                Run-Case "$prefix-dev-$state" @('--quit-after', '20', '--', "--dev-state=$state") "entry_ready state=$state"
            }
            $session = Join-Path $runDirectory "$prefix-session"
            Run-Scene "$prefix-flow-settings-write" 'settings_smoke' '\[SmokeTest\] settings_passed write' @('--settings-case=write', "--settings-test-directory=$session")
            $settingsPath = Join-Path $session 'settings.cfg'
            $settingsHash = (Get-FileHash -LiteralPath $settingsPath).Hash
            Run-Scene "$prefix-flow-expeditions" 'hub_departure_smoke' '\[SmokeTest\] hub_departure_passed' @('--departure-case=three', "--progress-test-directory=$session", "--settings-test-directory=$session")
            Run-Scene "$prefix-flow-continue" 'progress_save_smoke' '\[SmokeTest\] progress_save_passed read' @('--progress-case=read', '--existing-settings', "--progress-test-directory=$session")
            $progressPath = Join-Path $session 'progress.json'
            $progressHash = (Get-FileHash -LiteralPath $progressPath).Hash
            Run-Scene "$prefix-flow-settings-read" 'settings_smoke' '\[SmokeTest\] settings_passed read' @('--settings-case=read', '--shared-progress', "--settings-test-directory=$session")
            if ((Get-FileHash -LiteralPath $settingsPath).Hash -ne $settingsHash -or (Get-FileHash -LiteralPath $progressPath).Hash -ne $progressHash) {
                throw "Settings/progress files changed across their independent read paths in $prefix."
            }
            $saved = Get-Content -LiteralPath $progressPath -Raw | ConvertFrom-Json
            if ($saved.hub.money -cne '40' -or $saved.hub.bag_slots -ne 3 -or $saved.hub.next_expedition_id -cne '5' -or @($saved.hub.stored_items).Count -ne 1) {
                throw "Unexpected final progress in $prefix."
            }
            $flows.Add([ordered]@{
                repetition = $round
                money = $saved.hub.money
                bag_slots = $saved.hub.bag_slots
                next_expedition_id = $saved.hub.next_expedition_id
                stored_items = $saved.hub.stored_items
                settings_unchanged = $true
                progress_unchanged_by_options = $true
                settings_sha256 = $settingsHash.ToLowerInvariant()
                progress_sha256 = $progressHash.ToLowerInvariant()
            })
            $report.completed_repetitions = $round
        }
        if ((Get-G2SourceHash $repository) -ne $report.source_tree_sha256) { throw 'Source files changed during the checks; result is not reproducible.' }
        $report.passed = $true
    } catch {
        $report.failure = $_.Exception.Message
        throw
    } finally {
        $report.finished_at_utc = [DateTime]::UtcNow.ToString('o')
        $report.check_count = $checks.Count
        $reportPath = Join-Path $runDirectory 'results.json'
        $report | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $reportPath -Encoding utf8NoBOM
        Write-Host "G2 report: $reportPath"
    }
    Write-Host "PASS G2: $($checks.Count) processes, $Repetitions repetitions."
}

# Dot-sourcing exposes the process checker for independent failure-path validation.
if ($MyInvocation.InvocationName -ne '.') {
    try { Start-G2Checks } catch { Write-Error $_ -ErrorAction Continue; exit 1 }
}
