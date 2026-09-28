[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$themeRoot = Split-Path -Parent $PSScriptRoot
$manifest = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $themeRoot 'theme.json') | ConvertFrom-Json
$css = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $themeRoot 'theme.css')
$failures = [Collections.Generic.List[string]]::new()

if ([version]$manifest.version -lt [version]'0.1.28') {
    $failures.Add("expected manifest version 0.1.28 or newer, found $($manifest.version)")
}

foreach ($fragment in @(
    '--ct-accent: #d95f78;'
    '--color-token-primary: var(--ct-accent) !important;'
)) {
    if (-not $css.Contains($fragment)) {
        $failures.Add("missing native pink pipeline declaration: $fragment")
    }
}

$scope = ':root[data-codexthemes-theme="labubu-universe-studio"] [role="img"][class*="--profile-usage-level-0"]'
$requiredRules = [ordered]@{}
$requiredRules[$scope] = @('--profile-usage-level-0: #ffffff !important;')
$requiredRules[($scope + ' [class~="bg-[var(--profile-usage-level-0)]"]')] = @('background-color: #ffffff !important;')
$requiredRules[($scope + ' [class~="bg-[color-mix(in_srgb,var(--color-token-primary)_14%,var(--profile-usage-level-0))]"]')] = @('background-color: #ffffff !important;')

foreach ($rule in $requiredRules.GetEnumerator()) {
    $match = [regex]::Match($css, "(?s)$([regex]::Escape($rule.Key))\s*\{(?<body>.*?)\}")
    if (-not $match.Success) {
        $failures.Add("missing zero-only Token rule: $($rule.Key)")
        continue
    }
    foreach ($declaration in $rule.Value) {
        if (-not $match.Groups['body'].Value.Contains($declaration)) {
            $failures.Add("missing declaration for $($rule.Key): $declaration")
        }
    }
}

foreach ($forbidden in @(
    '--ct-token-usage-'
    '--profile-usage-level-1:'
    '--profile-usage-level-2:'
    '--profile-usage-level-3:'
    '--profile-usage-level-4:'
    'bg-[var(--profile-usage-level-1)]'
    'bg-[var(--profile-usage-level-2)]'
    'bg-[var(--profile-usage-level-3)]'
    'bg-[var(--profile-usage-level-4)]'
    'bg-[color-mix(in_srgb,var(--color-token-primary)_78%,transparent)]'
    'bg-[var(--color-token-primary)]'
)) {
    if ($css.Contains($forbidden)) {
        $failures.Add("forbidden nonzero Token override remains: $forbidden")
    }
}

if ($failures.Count -gt 0) {
    throw ($failures -join [Environment]::NewLine)
}

Write-Output 'LABUBU Token zero-white/native-nonzero contract passed.'
