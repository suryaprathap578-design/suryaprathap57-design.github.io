# Local preview server with the same clean-URL behaviour as the live site.
# Usage: powershell -ExecutionPolicy Bypass -File _build\serve.ps1 [-Port 8080]
# Then open http://localhost:8080/  (Ctrl+C to stop)
param([int]$Port = 8080)
$root = Split-Path -Parent $PSScriptRoot
$types = @{ '.html' = 'text/html; charset=utf-8'; '.css' = 'text/css; charset=utf-8'; '.js' = 'application/javascript; charset=utf-8'; '.json' = 'application/json'
  '.png' = 'image/png'; '.jpg' = 'image/jpeg'; '.jpeg' = 'image/jpeg'; '.svg' = 'image/svg+xml'; '.webp' = 'image/webp'; '.ico' = 'image/x-icon'; '.xml' = 'application/xml'; '.txt' = 'text/plain; charset=utf-8' }
$legacy = @{}
if (Test-Path "$root\_redirects") {
  foreach ($l in Get-Content "$root\_redirects") { if ($l -match '^(/\S+\.html)\s+(\S+)\s+301') { $legacy[$Matches[1]] = $Matches[2] } }
}
$http = New-Object System.Net.HttpListener
$http.Prefixes.Add("http://localhost:$Port/")
$http.Start()
Write-Host "SUBHA INFRA preview running at http://localhost:$Port/  (Ctrl+C to stop)"
try {
  while ($http.IsListening) {
    $ctx = $http.GetContext(); $req = $ctx.Request; $res = $ctx.Response
    try {
    $path = [Uri]::UnescapeDataString($req.Url.AbsolutePath)
    $status = 200; $file = $null; $redirect = $null
    if ($path -match '^/_build(/|$)') { $status = 404 }
    elseif ($legacy.ContainsKey($path)) { $redirect = $legacy[$path] }
    elseif ($path -match '^(.*/)index\.html$') { $redirect = $Matches[1] }
    else {
      $local = Join-Path $root ($path.TrimStart('/') -replace '/', '\')
      if ((Test-Path $local -PathType Container)) {
        if (-not $path.EndsWith('/')) { $redirect = $path + '/' }
        elseif (Test-Path (Join-Path $local 'index.html')) { $file = Join-Path $local 'index.html' }
        else { $status = 404 }
      }
      elseif (Test-Path $local -PathType Leaf) { $file = $local }
      else { $status = 404 }
    }
    if ($redirect) {
      $q = $req.Url.Query
      $res.StatusCode = 301; $res.RedirectLocation = $redirect + $q
    }
    else {
      if ($status -eq 404) { $file = Join-Path $root '404\index.html'; $res.StatusCode = 404 }
      $bytes = [IO.File]::ReadAllBytes($file)
      $ext = [IO.Path]::GetExtension($file).ToLower()
      $res.ContentType = $(if ($types[$ext]) { $types[$ext] } else { 'application/octet-stream' })
      $res.ContentLength64 = $bytes.Length
      if ($req.HttpMethod -ne 'HEAD') { $res.OutputStream.Write($bytes, 0, $bytes.Length) }
    }
    } catch { } finally { try { $res.Close() } catch { } }
  }
}
finally { $http.Stop() }
