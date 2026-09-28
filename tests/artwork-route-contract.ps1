[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$themeRoot = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $themeRoot 'theme.json'
$cssPath = Join-Path $themeRoot 'theme.css'
$manifest = Get-Content -Raw -Encoding UTF8 -LiteralPath $manifestPath | ConvertFrom-Json
$css = Get-Content -Raw -Encoding UTF8 -LiteralPath $cssPath
$failures = [Collections.Generic.List[string]]::new()

if ([version]$manifest.version -lt [version]'0.1.29') {
    $failures.Add("expected manifest version 0.1.29 or newer, found $($manifest.version)")
}

foreach ($fragment in @(
    '--ct-titlebar-bg: #ffe6dc;'
    '--ct-titlebar-menu-fg: #000000;'
)) {
    if (-not $css.Contains($fragment)) {
        $failures.Add("missing LABUBU titlebar declaration: $fragment")
    }
}

$currentTopbar = [regex]::Match(
    $css,
    '(?s):root\[data-codexthemes-theme="labubu-universe-studio"\]\s+div:has\(> div > #application-menu-trigger-file-menu\)\s*\{(?<body>.*?)\}'
)
if (-not $currentTopbar.Success) {
    $failures.Add('missing stable current-build application-menu topbar rule')
}
elseif (-not $currentTopbar.Groups['body'].Value.Contains('background: var(--ct-titlebar-bg) !important;')) {
    $failures.Add('current-build application-menu topbar does not own the LABUBU titlebar background')
}

$artPath = Join-Path $themeRoot ([string]$manifest.art)
if (-not (Test-Path -LiteralPath $artPath -PathType Leaf)) {
    $failures.Add("manifest artwork is missing: $artPath")
}
elseif ((Get-Item -LiteralPath $artPath).Length -le 0) {
    $failures.Add("manifest artwork is empty: $artPath")
}

if ($css -notmatch '--ct-art\s*:\s*url\(') {
    $failures.Add('theme CSS does not declare the local --ct-art token')
}
if ($css -notmatch 'main\[data-codexthemes-page=["'']home["'']\]::before') {
    $failures.Add('home artwork is not anchored to the runtime-owned page marker')
}
if ($css -notmatch 'main\[data-codexthemes-page=["'']conversation["'']\]::before') {
    $failures.Add('conversation artwork is not anchored to the runtime-owned page marker')
}
if ($css -match 'main\.main-surface\[data-codexthemes-page=') {
    $failures.Add('route styling is still coupled to the removed native .main-surface class')
}
if ($css -notmatch '\.sidebar-item\s*>\s*span\[class\*=["'']text-token-charts-purple["'']\]') {
    $failures.Add('sidebar profile monogram has no theme-owned contrast override')
}
if ($css -notmatch 'color\s*:\s*#71368a\s*!important') {
    $failures.Add('sidebar profile monogram contrast color is missing')
}

$sidebarPendingApprovalSelector = ':root[data-codexthemes-theme="labubu-universe-studio"] .sidebar-item[data-app-action-sidebar-thread-row] [class~="bg-token-charts-green/20"][class~="text-token-charts-green"]'
$sidebarPendingApprovalRule = [regex]::Match(
    $css,
    "(?s)$([regex]::Escape($sidebarPendingApprovalSelector).Replace('\ ', '\s+'))\s*\{(?<body>.*?)\}"
)
if (-not $sidebarPendingApprovalRule.Success) {
    $failures.Add('sidebar pending-approval badge must be rooted at the theme marker and scoped to its native thread-row badge')
}
else {
    if ($sidebarPendingApprovalRule.Groups['body'].Value -notmatch '(?m)(?<![-\w])color\s*:\s*var\(--ct-success\)\s*!important\s*;') {
        $failures.Add('sidebar pending-approval badge selector must own color: var(--ct-success) !important;')
    }
    if ($sidebarPendingApprovalRule.Groups['body'].Value -notmatch '(?m)(?<![-\w])background-color\s*:\s*rgba\(\s*47\s*,\s*118\s*,\s*93\s*,\s*0\.18\s*\)\s*!important\s*;') {
        $failures.Add('sidebar pending-approval badge selector must own background-color: rgba(47, 118, 93, 0.18) !important;')
    }
}

$composerSelector = ':root[data-codexthemes-theme="labubu-universe-studio"] [data-composer-navigation-target="permissions"] [class*="ComposerDropdownLabelValue"]'
$composerRule = [regex]::Match(
    $css,
    "(?s)$([regex]::Escape($composerSelector))\s*\{(?<body>.*?)\}"
)
if (-not $composerRule.Success) {
    $failures.Add('Composer permissions value must be rooted at the theme marker and scoped through the native permissions control')
}
else {
    if ($composerRule.Groups['body'].Value -notmatch '--composer-dropdown-label-value-color\s*:\s*var\(--ct-warning\)\s*!important\s*;') {
        $failures.Add('Composer permissions value selector must own --composer-dropdown-label-value-color: var(--ct-warning) !important;')
    }
    if ($composerRule.Groups['body'].Value -notmatch '(?m)(?<![-\w])color\s*:\s*var\(--ct-warning\)\s*!important\s*;') {
        $failures.Add('Composer permissions value selector must own color: var(--ct-warning) !important;')
    }
}

if ($css -match '\.composer-surface-chrome\s+\[class\*=["'']ComposerDropdownLabelValue["'']\]') {
    $failures.Add('obsolete dead Composer selector must be absent')
}

if ($failures.Count -gt 0) {
    throw ($failures -join [Environment]::NewLine)
}

Write-Output 'LABUBU artwork route contract passed.'
