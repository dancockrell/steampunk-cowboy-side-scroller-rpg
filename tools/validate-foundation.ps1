param()
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$requiredFiles = @(
  'README.md', 'AGENTS.md', 'CONTRIBUTING.md', 'project.godot',
  'scenes/bootstrap.tscn', 'docs/source-context.md', 'docs/game-vision.md',
  'docs/art-direction.md', 'docs/gameplay-pillars.md', 'docs/weapon-tool-kit.md',
  'docs/temple-emergence.md', 'docs/relationships.md', 'docs/sprite-animation-pipeline.md',
  'docs/vertical-slice.md', 'docs/implementation-roadmap.md', 'docs/parallel-task-plan.md',
  'docs/TODO.md', 'docs/decisions.md', 'docs/data-contracts.md', 'docs/asset-policy.md',
  'docs/architecture/engine-decision.md', 'docs/templates/implementation-brief.md',
  'assets/references/reference-register.json', 'tests/README.md'
)
foreach ($relative in $requiredFiles) {
  if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $relative) -PathType Leaf)) {
    throw "Missing required file: $relative"
  }
}
$markdownFiles = Get-ChildItem -LiteralPath $repoRoot -Filter '*.md' -Recurse -File |
  Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]|[\\/]\.godot[\\/]' }
$linkCount = 0
foreach ($file in $markdownFiles) {
  $body = Get-Content -LiteralPath $file.FullName -Raw
  foreach ($match in [regex]::Matches($body, '\[[^\]]*\]\(([^)]+)\)')) {
    $target = $match.Groups[1].Value
    if ($target -match '^([a-zA-Z][a-zA-Z0-9+.-]*:|#)') { continue }
    $local = [Uri]::UnescapeDataString(($target -split '#')[0])
    if (-not (Test-Path -LiteralPath (Join-Path $file.DirectoryName $local))) {
      throw "Broken local link in $($file.Name): $target"
    }
    $linkCount++
  }
}
$jsonFiles = Get-ChildItem -LiteralPath $repoRoot -Filter '*.json' -Recurse -File |
  Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]|[\\/]\.godot[\\/]' }
foreach ($file in $jsonFiles) {
  $null = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
}
$register = Get-Content -LiteralPath (Join-Path $repoRoot 'assets/references/reference-register.json') -Raw | ConvertFrom-Json
if ($register.references.Count -eq 0) { throw 'Reference provenance is required.' }
foreach ($reference in $register.references) {
  if ($reference.status -eq 'original_files_unavailable' -and $reference.local_files.Count -ne 0) {
    throw 'Unavailable-reference record must not claim imported files.'
  }
}
$project = Get-Content -LiteralPath (Join-Path $repoRoot 'project.godot') -Raw
$mainScene = [regex]::Match($project, 'run/main_scene="res://([^"]+)"')
if (-not $mainScene.Success) { throw 'No main scene declared.' }
if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $mainScene.Groups[1].Value))) {
  throw 'Main scene file does not exist.'
}
Write-Output "PASS: $($requiredFiles.Count) required files, $($markdownFiles.Count) Markdown files, $linkCount local links, $($jsonFiles.Count) JSON files, main scene and reference record."
