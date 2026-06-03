$files = Get-ChildItem -Path "$PSScriptRoot\..\lib" -Filter *.dart -Recurse
foreach ($f in $files) {
  $lines = [IO.File]::ReadAllLines($f.FullName)
  $changed = $false
  for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match '^\s*const\s+' -and $lines[$i] -match 'Theme\.of\(context\)') {
      $lines[$i] = $lines[$i].Replace('const ', '')
      $changed = $true
    }
  }
  if ($changed) {
    [IO.File]::WriteAllLines($f.FullName, $lines)
    Write-Host "Fixed const: $($f.Name)"
  }
}
