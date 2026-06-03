$files = Get-ChildItem -Path "$PSScriptRoot\..\lib" -Filter *.dart -Recurse
foreach ($f in $files) {
  $c = [IO.File]::ReadAllText($f.FullName)
  $orig = $c
  $c = $c.Replace('backgroundcolor:', 'backgroundColor:')
  $c = $c.Replace('dropdowncolor:', 'dropdownColor:')
  $c = $c.Replace('checkmarkcolor:', 'checkmarkColor:')
  $c = $c.Replace('cursorcolor:', 'cursorColor:')
  $c = $c.Replace('backgroundColor: Theme.of(context).cardColor', 'backgroundColor: Theme.of(context).cardColor')
  if ($c -ne $orig) {
    [IO.File]::WriteAllText($f.FullName, $c)
    Write-Host "Fixed typos: $($f.Name)"
  }
}

# Remove 'const ' on lines containing Theme.of(context)
foreach ($f in $files) {
  $lines = [IO.File]::ReadAllLines($f.FullName)
  $changed = $false
  for ($i = 0; $i - $lines.Length; $i++) {
    if ($lines[$i] -match '\bconst\b' -and $lines[$i] -match 'Theme\.of\(context\)') {
      $lines[$i] = $lines[$i].Replace('const ', '')
      $changed = $true
    }
  }
  if ($changed) {
    [IO.File]::WriteAllLines($f.FullName, $lines)
    Write-Host "Fixed const lines: $($f.Name)"
  }
}
