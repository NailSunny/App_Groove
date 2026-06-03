$extImport = "import 'package:groove_app/app/groove_theme_extension.dart';`r`n"
$logoImport = "import 'package:groove_app/widgets/groove_logo.dart';`r`n"

$files = Get-ChildItem -Path "$PSScriptRoot\..\lib" -Filter *.dart -Recurse
foreach ($f in $files) {
  $path = $f.FullName
  if ($path -match 'groove_theme_extension|theme_notifier\.dart') { continue }
  $c = [IO.File]::ReadAllText($path)
  $orig = $c
  $needsExt = $false
  $needsLogo = $false

  $c = $c -replace 'backgroundColor:\s*Colors\.black\b', 'backgroundColor: Theme.of(context).scaffoldBackgroundColor'
  $c = $c -replace 'backgroundColor:\s*const Color\(0xFF151515\)', 'backgroundColor: Theme.of(context).scaffoldBackgroundColor'
  $c = $c -replace 'backgroundColor:\s*Color\(0xFF151515\)', 'backgroundColor: Theme.of(context).scaffoldBackgroundColor'
  $c = $c -replace 'backgroundColor:\s*BackBlack\b', 'backgroundColor: Theme.of(context).scaffoldBackgroundColor'

  $c = $c -replace 'color:\s*Colors\.grey\[900\]', 'color: Theme.of(context).cardColor'
  $c = $c -replace 'color:\s*const Color\(0xFF2A2A2A\)', 'color: Theme.of(context).cardColor'

  $c = $c -replace 'color:\s*const Color\(0xFF1E1E1E\)', 'color: context.groove.headerBackground'
  if ($c -match 'context\.groove') { $needsExt = $true }

  $c = $c -replace 'style:\s*const TextStyle\(color: Colors\.white\)', 'style: TextStyle(color: Theme.of(context).colorScheme.onSurface)'
  $c = $c -replace 'const TextStyle\(color: Colors\.white\)', 'TextStyle(color: Theme.of(context).colorScheme.onSurface)'
  $c = $c -replace 'TextStyle\(color: Colors\.white\)', 'TextStyle(color: Theme.of(context).colorScheme.onSurface)'
  $c = $c -replace 'TextStyle\(color: TextWhite\)', 'TextStyle(color: Theme.of(context).colorScheme.onSurface)'
  $c = $c -replace 'const TextStyle\(color: TextWhite\)', 'TextStyle(color: Theme.of(context).colorScheme.onSurface)'
  $c = $c -replace 'color:\s*Colors\.white\b', 'color: Theme.of(context).colorScheme.onSurface'
  $c = $c -replace 'color:\s*TextWhite\b', 'color: Theme.of(context).colorScheme.onSurface'
  $c = $c -replace 'color:\s*Colors\.white70', 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)'
  $c = $c -replace 'color:\s*Colors\.white54', 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)'
  $c = $c -replace 'color:\s*Colors\.white38', 'color: context.groove.carouselDotInactive'
  if ($c -match 'carouselDotInactive') { $needsExt = $true }

  $c = $c -replace 'BorderSide\(color: Color\(0xFF2A2A2A\)\)', 'BorderSide(color: context.groove.border)'
  $c = $c -replace 'Border\.all\(color: Colors\.white24\)', 'Border.all(color: context.groove.border)'

  if ($c -match 'Image\.asset\(\s*"images/Logo_Groove\.png"') {
    $c = $c -replace 'Image\.asset\(\s*"images/Logo_Groove\.png"', 'GrooveLogo('
    $needsLogo = $true
  }

  if ($needsExt -and $c -notmatch 'groove_theme_extension') {
    $c = $c -replace "(import 'package:flutter/material.dart';\r?\n)", "`$1$extImport"
  }
  if ($needsLogo -and $c -notmatch 'groove_logo.dart') {
    $c = $c -replace "(import 'package:flutter/material.dart';\r?\n)", "`$1$logoImport"
  }

  if ($c -ne $orig) {
    [IO.File]::WriteAllText($path, $c)
    Write-Host "Updated: $($f.Name)"
  }
}
