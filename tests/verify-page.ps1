$pagePath = Join-Path $PSScriptRoot '..\index.html'
if (-not (Test-Path -LiteralPath $pagePath)) {
    throw 'index.html 不存在'
}

$html = Get-Content -Raw -LiteralPath $pagePath
$checks = @{
    doctype             = $html -match '(?i)<!doctype html>'
    viewport            = $html -match 'name="viewport"'
    heading             = $html -match '<h1>Hello World</h1>'
    flexCentering       = $html -match 'display:\s*flex' -and
                          $html -match 'align-items:\s*center' -and
                          $html -match 'justify-content:\s*center'
    noHorizontalOverflow = $html -match 'margin:\s*0'
    noExternalResources = $html -notmatch '(?i)<script|<img|<link[^>]+stylesheet|https?://'
}

$failed = @(
    $checks.GetEnumerator() |
        Where-Object { -not $_.Value } |
        ForEach-Object Key
)

if ($failed.Count -gt 0) {
    throw "页面验证失败：$($failed -join ', ')"
}

Write-Output '页面验证通过。'
