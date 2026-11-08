# Builds transparent logo files in assets/images/brand/ from the supplied logo artwork.
# Usage: powershell -ExecutionPolicy Bypass -File _build\process-logo.ps1 -Source "C:\path\to\logo.jpg"
param([Parameter(Mandatory = $true)][string]$Source)
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @"
using System; using System.Drawing; using System.Drawing.Imaging; using System.Runtime.InteropServices;
public static class LogoFx {
  // mode 0 = original colours, 1 = navy recoloured to ivory (for dark backgrounds)
  public static Bitmap Knockout(Bitmap src, Rectangle crop, int mode) {
    Bitmap o = new Bitmap(crop.Width, crop.Height, PixelFormat.Format32bppArgb);
    for (int y = 0; y < crop.Height; y++) for (int x = 0; x < crop.Width; x++) {
      Color c = src.GetPixel(crop.X + x, crop.Y + y);
      int mn = Math.Min(c.R, Math.Min(c.G, c.B));
      double a = Math.Min(1.0, (255 - mn) / 200.0);
      if (a < 0.04) { o.SetPixel(x, y, Color.Transparent); continue; }
      int r = Clamp((c.R - 255 * (1 - a)) / a), g = Clamp((c.G - 255 * (1 - a)) / a), b = Clamp((c.B - 255 * (1 - a)) / a);
      if (mode == 1 && b > r + 15) { r = 245; g = 243; b = 238; }
      o.SetPixel(x, y, Color.FromArgb((int)(a * 255), r, g, b));
    }
    return o;
  }
  static int Clamp(double v) { return (int)Math.Max(0, Math.Min(255, v)); }
}
"@
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root 'assets\images\brand'
New-Item -ItemType Directory -Force $out | Out-Null
$src = New-Object System.Drawing.Bitmap $Source
$mark = New-Object System.Drawing.Rectangle 225, 730, 1000, 1090
$full = New-Object System.Drawing.Rectangle 225, 730, 3135, 1090
$jobs = @(@($mark, 0, 'subha-infra-mark.png'), @($mark, 1, 'subha-infra-mark-light.png'), @($full, 0, 'subha-infra-logo.png'), @($full, 1, 'subha-infra-logo-light.png'))
foreach ($j in $jobs) {
  $b = [LogoFx]::Knockout($src, $j[0], $j[1])
  $h = 360; $w = [int]($b.Width * $h / $b.Height)
  $s = New-Object System.Drawing.Bitmap $w, $h
  $g = [System.Drawing.Graphics]::FromImage($s); $g.InterpolationMode = 'HighQualityBicubic'; $g.PixelOffsetMode = 'HighQuality'
  $g.DrawImage($b, 0, 0, $w, $h)
  $s.Save((Join-Path $out $j[2]), [System.Drawing.Imaging.ImageFormat]::Png)
  "$($j[2]) $w x $h"
  $g.Dispose(); $s.Dispose(); $b.Dispose()
}
$src.Dispose()
