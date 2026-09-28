[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$themeRoot = Split-Path -Parent $PSScriptRoot
$css = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $themeRoot 'theme.css')

if ($css -match 'main\[data-codexthemes-page="home"\]::before\s*\{(?s:.*?)inset:\s*18px') {
    throw 'Home artwork still has an 18px inset that exposes a border around the background.'
}
if ($css -match 'main\[data-codexthemes-page="home"\]::after\s*\{(?s:.*?)inset:\s*18px') {
    throw 'Home decoration layer still has an 18px inset that exposes a border around the background.'
}
if ($css -match 'main\[data-codexthemes-page="home"\]::before\s*\{[^}]*border:\s*1px') {
    throw 'Home artwork still draws a visible border.'
}

if ($css -match 'main\[data-codexthemes-page="home"\]::before\s*\{[^}]*inset:\s*[1-9]') {
    throw 'Home artwork must remain edge-to-edge, including the narrow-window override.'
}
if ($css -notmatch '\[data-app-shell-application-menu-header\]\s*\{[^}]*--app-shell-titlebar-height:\s*0px;[^}]*--app-shell-page-inline-end-inset:\s*0px;[^}]*padding-block-end:\s*0;') {
    throw 'The Windows application-menu shell must not expose top, right, or bottom gutters.'
}
if ($css -notmatch '\[data-app-shell-main-content-top-fade\]\s*>\s*\[class\*="_MainContentTopFade_"\]\s*\{\s*background-image:\s*none;') {
    throw 'The native white scroll fade must not cover the workspace artwork.'
}

Write-Output 'LABUBU background border contract passed.'
