$ErrorActionPreference = "Stop"
$enc = New-Object System.Text.UTF8Encoding $false
$data = [System.IO.File]::ReadAllText("rafeeq\quran-data.json", [System.Text.Encoding]::UTF8)
if (-not $data.StartsWith("{")) { Write-Host "BAD DATA"; exit 1 }
function B64($p) { [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($p)) }
$T = $env:TEMP
$css = ""
$css += "@font-face{font-family:'Amiri';font-weight:400;src:url(data:font/woff2;base64," + (B64 "$T\amiri400.woff2") + ") format('woff2');}"
$css += "@font-face{font-family:'Amiri';font-weight:700;src:url(data:font/woff2;base64," + (B64 "$T\amiri700.woff2") + ") format('woff2');}"
$css += "@font-face{font-family:'Tajawal';font-weight:400;src:url(data:font/woff2;base64," + (B64 "$T\tajawal400.woff2") + ") format('woff2');}"
$css += "@font-face{font-family:'Tajawal';font-weight:700;src:url(data:font/woff2;base64," + (B64 "$T\tajawal400.woff2") + ") format('woff2');}"
$html = [System.IO.File]::ReadAllText("rafeeq\rafeeq-src.html", [System.Text.Encoding]::UTF8)
$html = $html.Replace("__DATA__", $data)
$html = $html.Replace("__FONTS__", "<style>" + $css + "</style>")
[System.IO.File]::WriteAllText("rafeeq\rafeeq.html", $html, $enc)
Write-Host "rafeeq.html bytes:"
Write-Host ([System.IO.File]::ReadAllBytes("rafeeq\rafeeq.html").Length)
