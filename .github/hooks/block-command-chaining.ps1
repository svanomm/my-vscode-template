# block-command-chaining.ps1
# PreToolUse hook: blocks any terminal command that uses command-chaining operators
# such as pipes (|), ampersands (&, &&), semicolons (;), or command substitution ($(), ``).

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

# Only enforce on terminal/shell execution tools
if ($toolName -notmatch '(?i)(terminal|execute|bash|shell|command|run_in_terminal|runInTerminal|send_to_terminal)') {
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

function Deny([string]$reason) {
    $output = @{
        hookSpecificOutput = @{
            hookEventName            = "PreToolUse"
            permissionDecision       = "deny"
            permissionDecisionReason = $reason
        }
    } | ConvertTo-Json -Depth 5
    Write-Output $output
    exit 0
}

# Block pipe operator (|) — also catches ||
if ($command -match '\|') {
    Deny "Command chaining with '|' (pipe) is not allowed. Submit each command individually."
}

# Block ampersand operators (& and &&)
if ($command -match '&') {
    Deny "Command chaining with '&' or '&&' is not allowed. Submit each command individually."
}

# Block semicolons used for sequential execution
if ($command -match ';') {
    Deny "Command chaining with ';' is not allowed. Submit each command individually."
}

# Block subexpressions $() which execute and inline command output
if ($command -match '\$\(') {
    Deny "Command substitution with `$() is not allowed. Submit each command individually."
}

# Block backtick command substitution (bash-style)
if ($command -match '`') {
    Deny "Backtick command substitution is not allowed. Submit each command individually."
}

# All checks passed — allow the command
Write-Output '{}'
exit 0
