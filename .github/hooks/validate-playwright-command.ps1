# validate-playwright-command.ps1
# PreToolUse hook: ensures terminal commands from the web-researcher agent
# start with "playwright-cli" and contain no command concatenation.

$ErrorActionPreference = "Stop"

try {
    $jsonInput = [Console]::In.ReadToEnd()
    $data = $jsonInput | ConvertFrom-Json
} catch {
    # If we can't parse input, allow (don't break other workflows)
    Write-Output '{}'
    exit 0
}

$toolName = if ($data.PSObject.Properties["toolName"]) { $data.toolName } else { "" }

# Only enforce on terminal/execute tools
if ($toolName -notmatch '(?i)(terminal|execute|bash|shell|command|run_in_terminal|runInTerminal)') {
    Write-Output '{}'
    exit 0
}

# Only enforce for the web-researcher agent
$agentName = ""
if ($data.PSObject.Properties["agentName"]) {
    $agentName = $data.agentName
} elseif ($data.PSObject.Properties["agent"]) {
    $agentName = $data.agent
} elseif ($data.PSObject.Properties["session"] -and $data.session.PSObject.Properties["agentName"]) {
    $agentName = $data.session.agentName
}

if ($agentName -and $agentName -notmatch '(?i)web[-_]?researcher') {
    Write-Output '{}'
    exit 0
}

# Extract the command string from tool input
$command = ""
if ($data.PSObject.Properties["toolInput"]) {
    $ti = $data.toolInput
    if ($ti.PSObject.Properties["command"]) {
        $command = $ti.command
    } elseif ($ti.PSObject.Properties["input"]) {
        $command = $ti.input
    }
}

if (-not $command -or $command.Trim().Length -eq 0) {
    Write-Output '{}'
    exit 0
}

$command = $command.Trim()

function Deny($reason) {
    $output = @{
        hookSpecificOutput = @{
            hookEventName           = "PreToolUse"
            permissionDecision      = "deny"
            permissionDecisionReason = $reason
        }
    } | ConvertTo-Json -Depth 5
    Write-Output $output
    exit 0
}

# --- Validation 1: command must start with "playwright-cli" ---
if ($command -notmatch '^playwright-cli(\s|$)') {
    Deny "web-researcher terminal commands must start with 'playwright-cli'. Received: $command"
}

# --- Validation 2: no command concatenation operators ---
# Block semicolons (sequential execution)
if ($command -match ';') {
    Deny "Command concatenation with ';' is not allowed."
}

# Block pipeline chain operators (&& and ||)
if ($command -match '&&|\|\|') {
    Deny "Command concatenation with '&&' or '||' is not allowed."
}

# Block pipe operator (playwright-cli does not need pipes)
if ($command -match '\|') {
    Deny "Piping commands with '|' is not allowed."
}

# Block subexpressions $() which can execute arbitrary code
if ($command -match '\$\(') {
    Deny "Subexpressions '$()' are not allowed in commands."
}

# Block backtick (PowerShell escape/line-continuation that can obfuscate)
if ($command -match '`') {
    Deny "Backtick characters are not allowed in commands."
}

# All checks passed — allow the command
Write-Output '{}'
exit 0
