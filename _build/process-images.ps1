# Processes the supplied source images into assets/project-images/:
#  - renames each file as subha-infra-<category>-NN.jpg
#  - burns a "SUBHA INFRA | CATEGORY" mark into the bottom-right corner
#  - resizes to a maximum width of 1920px and saves as optimised JPEG
# Usage: powershell -ExecutionPolicy Bypass -File _build\process-images.ps1 -Source "C:\path\to\originals"
param([Parameter(Mandatory = $true)][string]$Source)

Add-Type -AssemblyName System.Drawing
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root 'assets\project-images'
New-Item -ItemType Directory -Force $out | Out-Null

$labels = @{
  'steel-structures'      = 'STEEL STRUCTURES'
  'peb-structures'        = 'PEB STRUCTURES'
  'industrial-buildings'  = 'INDUSTRIAL BUILDINGS'
  'tensile-structures'    = 'TENSILE STRUCTURES'
  'facades'               = 'FACADES'
  'commercial-buildings'  = 'COMMERCIAL BUILDINGS'
  'residential-buildings' = 'RESIDENTIAL BUILDINGS'
}

# source file, output name, category, optional crop x,y,w,h
$map = @(
  @('1.png',  'subha-infra-steel-structures-01',      'steel-structures',      @(0, 0, 1774, 441)),
  @('1.png',  'subha-infra-steel-structures-02',      'steel-structures',      @(0, 451, 1774, 436)),
  @('2.jpg',  'subha-infra-peb-structures-01',        'peb-structures',        $null),
  @('40.png', 'subha-infra-peb-structures-02',        'peb-structures',        $null),
  @('38.png', 'subha-infra-industrial-buildings-01',  'industrial-buildings',  $null),
  @('39.png', 'subha-infra-industrial-buildings-02',  'industrial-buildings',  @(820, 0, 780, 800)),
  @('14.jpg', 'subha-infra-tensile-structures-01',    'tensile-structures',    $null),
  @('22.jpg', 'subha-infra-facades-01',               'facades',               $null),
  @('4.jpg',  'subha-infra-facades-02',               'facades',               $null),
  @('30.jpg', 'subha-infra-facades-03',               'facades',               $null),
  @('32.jpg', 'subha-infra-facades-04',               'facades',               $null),
  @('9.jpg',  'subha-infra-facades-05',               'facades',               $null),
  @('21.jpg', 'subha-infra-commercial-buildings-01',  'commercial-buildings',  $null),
  @('24.jpg', 'subha-infra-commercial-buildings-02',  'commercial-buildings',  $null),
  @('25.jpg', 'subha-infra-commercial-buildings-03',  'commercial-buildings',  $null),
  @('28.jpg', 'subha-infra-commercial-buildings-04',  'commercial-buildings',  $null),
  @('31.jpg', 'subha-infra-commercial-buildings-05',  'commercial-buildings',  $null),
  @('33.jpg', 'subha-infra-commercial-buildings-06',  'commercial-buildings',  $null),
  @('36.jpg', 'subha-infra-commercial-buildings-07',  'commercial-buildings',  $null),
  @('37.jpg', 'subha-infra-commercial-buildings-08',  'commercial-buildings',  $null)
)
$res = @('3','5','6','7','8','10','11','12','13','15','16','17','18','19','20','23','26','27','29','34','35')
for ($i = 0; $i -lt $res.Count; $i++) {
  $map += , @("$($res[$i]).jpg", ('subha-infra-residential-buildings-{0:D2}' -f ($i + 1)), 'residential-buildings', $null)
}

$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$ep = New-Object System.Drawing.Imaging.EncoderParameters 1
$ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]84)

foreach ($m in $map) {
  $srcImg = [System.Drawing.Image]::FromFile((Join-Path $Source $m[0]))
  $c = $m[3]
  if ($null -eq $c) { $c = @(0, 0, $srcImg.Width, $srcImg.Height) }
  $scale = [Math]::Min(1.0, 1920.0 / $c[2])
  $w = [int]($c[2] * $scale); $h = [int]($c[3] * $scale)
  $bmp = New-Object System.Drawing.Bitmap $w, $h
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = 'HighQualityBicubic'; $g.SmoothingMode = 'AntiAlias'
  $g.PixelOffsetMode = 'HighQuality'; $g.TextRenderingHint = 'AntiAliasGridFit'
  $g.DrawImage($srcImg, (New-Object System.Drawing.Rectangle 0, 0, $w, $h), (New-Object System.Drawing.Rectangle $c[0], $c[1], $c[2], $c[3]), 'Pixel')

  # watermark
  $base = [Math]::Max(11, [Math]::Min($w, $h * 2.4) * 0.015)
  $f1 = New-Object System.Drawing.Font 'Segoe UI', ([single]($base * 1.25)), ([System.Drawing.FontStyle]::Bold), 'Pixel'
  $f2 = New-Object System.Drawing.Font 'Segoe UI Semibold', ([single]($base * 0.72)), ([System.Drawing.FontStyle]::Regular), 'Pixel'
  $t1 = 'SUBHA INFRA'; $t2 = $labels[$m[2]]
  $s1 = $g.MeasureString($t1, $f1); $s2 = $g.MeasureString($t2, $f2)
  $tw = [Math]::Max($s1.Width, $s2.Width); $pad = $base * 1.6
  $x = $w - $tw - $pad; $y = $h - $s1.Height - $s2.Height - $pad
  $shadow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(110, 10, 18, 28))
  $white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(235, 255, 255, 255))
  $bronze = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(240, 182, 154, 112))
  $o = [Math]::Max(1, $base * 0.08)
  $g.DrawString($t1, $f1, $shadow, ($x + $o), ($y + $o)); $g.DrawString($t1, $f1, $white, $x, $y)
  $y2 = $y + $s1.Height * 0.9
  $g.DrawString($t2, $f2, $shadow, ($x + $o + 2), ($y2 + $o)); $g.DrawString($t2, $f2, $white, ($x + 2), $y2)
  $g.FillRectangle($bronze, [single]($x - $base * 0.7), [single]($y + $s1.Height * 0.18), [single]([Math]::Max(2, $base * 0.16)), [single]($s1.Height * 0.62 + $s2.Height))

  $dest = Join-Path $out ($m[1] + '.jpg')
  $bmp.Save($dest, $codec, $ep)
  "{0,-44} {1}x{2}  {3} KB" -f $m[1], $w, $h, [int]((Get-Item $dest).Length / 1024)
  $g.Dispose(); $bmp.Dispose(); $srcImg.Dispose(); $f1.Dispose(); $f2.Dispose()
}
