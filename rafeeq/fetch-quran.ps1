$ErrorActionPreference = "Stop"
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0")
$wc.Encoding = [System.Text.Encoding]::UTF8
$ids = @(1) + (78..114)
$sb = New-Object System.Text.StringBuilder
[void]$sb.Append("{")
$first = $true
foreach ($n in $ids) {
  $ch = $wc.DownloadString("https://api.quran.com/api/v4/chapters/$n`?language=ar")
  $mn = [regex]::Match($ch, '"name_arabic":"([^"]+)"')
  $mc = [regex]::Match($ch, '"verses_count":(\d+)')
  $name = $mn.Groups[1].Value
  $vc = [int]$mc.Groups[1].Value
  $vs = $wc.DownloadString("https://api.quran.com/api/v4/quran/verses/uthmani`?chapter_number=$n&per_page=all")
  $mm = [regex]::Matches($vs, '"verse_key":"\d+:(\d+)","text_uthmani":"(.*?)(?<!\\)"')
  if ($mm.Count -ne $vc) { Write-Host "WARN surah $n got $($mm.Count) want $vc" }
  if (-not $first) { [void]$sb.Append(",") }
  $first = $false
  [void]$sb.Append("`"$n`":{`"n`":`"$name`",`"a`":[")
  $fa = $true
  foreach ($x in $mm) {
    if (-not $fa) { [void]$sb.Append(",") }
    $fa = $false
    $t = $x.Groups[2].Value.Replace('\', '')
    [void]$sb.Append("`"$t`"")
  }
  [void]$sb.Append("]}")
  Write-Host "surah $n ok ($($mm.Count))"
  Start-Sleep -Milliseconds 200
}
[void]$sb.Append("}")
[System.IO.File]::WriteAllText("rafeeq\quran-data.json", $sb.ToString(), (New-Object System.Text.UTF8Encoding $false))
Write-Host "saved bytes:"
Write-Host ([System.IO.File]::ReadAllBytes("rafeeq\quran-data.json").Length)
