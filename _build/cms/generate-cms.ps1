# SUBHA INFRA CMS generator
# 1. Tags every managed <img> in _build/pages + partials with a permanent placement key (data-slot="HOME-HERO-1").
# 2. Gives every existing website image a permanent image ID (ARCH-001, PEB-001 ...).
# 3. Writes:  apps-script/Seed.gs   (initial database for the Apps Script CMS)
#             IMAGE-MAP.md          (text inventory: every placement, every image, where it is used)
#             image-map.html        (visual inventory with thumbnails - open in a browser)
# Safe to re-run (idempotent). Run before build.ps1 when you add a new <img> to a page:
#   powershell -ExecutionPolicy Bypass -File _build\cms\generate-cms.ps1
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$CmsDir = $PSScriptRoot
$B = Split-Path -Parent $CmsDir
$root = Split-Path -Parent $B
$utf8 = New-Object System.Text.UTF8Encoding($false)
function Read-Text($p) { [IO.File]::ReadAllText($p, [Text.Encoding]::UTF8) }
function Write-Text($p, $s) { [IO.File]::WriteAllText($p, $s, $utf8) }
function Enc($s) { [System.Net.WebUtility]::HtmlEncode([string]$s) }
function Dec($s) { [System.Net.WebUtility]::HtmlDecode([string]$s) }

# ------------------------------------------------------------------
# PLACEMENTS (website_sections). One line per <img> in source order.
# Format: KEY|Section · Item
# ------------------------------------------------------------------
$Pages = [ordered]@{
  'partials\header.html' = @{ page = 'Header menus (every page)'; url = '/'; slots = @(
    'NAV-SVC-ARCH|Services menu · Architectural Design', 'NAV-SVC-STR|Services menu · Structural Engineering', 'NAV-SVC-INT|Services menu · Interior Design',
    'NAV-SVC-DB|Services menu · Design & Build', 'NAV-SVC-STEEL|Services menu · Steel Structures', 'NAV-SVC-PEB|Services menu · PEB Structures',
    'NAV-SVC-FACADE|Services menu · Facade Engineering', 'NAV-SVC-TENS|Services menu · Tensile & Special',
    'NAV-PRJ-RES|Projects menu · Residential', 'NAV-PRJ-COM|Projects menu · Commercial', 'NAV-PRJ-IND|Projects menu · Industrial', 'NAV-PRJ-PEB|Projects menu · PEB Structures',
    'NAV-PRJ-STEEL|Projects menu · Steel Structures', 'NAV-PRJ-FACADE|Projects menu · Facades', 'NAV-PRJ-TENS|Projects menu · Tensile Structures', 'NAV-PRJ-PKG|Projects menu · Packages & Estimate') }
  'partials\journey.html' = @{ page = 'Design journey (Home + Packages)'; url = '/#journey'; slots = @(
    'JOURNEY-1|Design journey · Step 1 Consultation & brief', 'JOURNEY-2|Design journey · Step 2 Architectural floor plan', 'JOURNEY-3|Design journey · Step 3 3D space layout',
    'JOURNEY-4|Design journey · Step 4 Structural drawings', 'JOURNEY-5|Design journey · Step 5 3D elevation design', 'JOURNEY-6|Design journey · Step 6 Approval drawings',
    'JOURNEY-7|Design journey · Step 7 3D interior design', 'JOURNEY-8|Design journey · Step 8 Construction & handover') }
  'pages\index.html' = @{ page = 'Home (landing page)'; url = '/'; slots = @(
    'HOME-HERO-1|Hero slider · Slide 1 (first image visitors see)', 'HOME-HERO-2|Hero slider · Slide 2', 'HOME-HERO-3|Hero slider · Slide 3', 'HOME-HERO-4|Hero slider · Slide 4', 'HOME-HERO-5|Hero slider · Slide 5', 'HOME-HERO-6|Hero slider · Slide 6',
    'HOME-ABOUT-1|Who we are · Large image', 'HOME-ABOUT-2|Who we are · Small overlapping image',
    'HOME-SVC-ARCH|Core capabilities · 01 Architecture & Interior', 'HOME-SVC-STR|Core capabilities · 02 Structural Design', 'HOME-SVC-DB|Core capabilities · 03 Design & Build',
    'HOME-SVC-PEB|Core capabilities · 04 Steel & PEB', 'HOME-SVC-FACADE|Core capabilities · 05 Facades', 'HOME-SVC-TENS|Core capabilities · 06 Tensile & Special',
    'HOME-PROJECTS-FEATURE|Selected work · Large featured project', 'HOME-PROJECTS-1|Selected work · Card 1', 'HOME-PROJECTS-2|Selected work · Card 2', 'HOME-PROJECTS-3|Selected work · Card 3', 'HOME-PROJECTS-4|Selected work · Card 4',
    'HOME-INDUSTRIAL-1|Industrial portfolio · Tile 1 (large)', 'HOME-INDUSTRIAL-2|Industrial portfolio · Tile 2', 'HOME-INDUSTRIAL-3|Industrial portfolio · Tile 3', 'HOME-INDUSTRIAL-4|Industrial portfolio · Tile 4', 'HOME-INDUSTRIAL-5|Industrial portfolio · Tile 5',
    'HOME-ENGINEERING|Engineering expertise · Side image',
    'HOME-SECTOR-1|Industries we serve · 01 Residential & villas', 'HOME-SECTOR-2|Industries we serve · 02 Commercial', 'HOME-SECTOR-3|Industries we serve · 03 Industrial', 'HOME-SECTOR-4|Industries we serve · 04 Warehouses & logistics',
    'HOME-SECTOR-5|Industries we serve · 05 Manufacturing', 'HOME-SECTOR-6|Industries we serve · 06 Corporate workspaces', 'HOME-SECTOR-7|Industries we serve · 07 Institutional', 'HOME-SECTOR-8|Industries we serve · 08 Special structures',
    'HOME-PKG-RES|Packages · Residential', 'HOME-PKG-COM|Packages · Commercial', 'HOME-PKG-PEB|Packages · PEB & steel sheds', 'HOME-PKG-TENS|Packages · Tensile fabric', 'HOME-PKG-DESIGN|Packages · Architectural design',
    'HOME-CTA-BG|Start a project (CTA) · Background image') }
  'pages\about.html' = @{ page = 'About Us'; url = '/about/'; slots = @(
    'ABOUT-HERO|Page header · Side image', 'ABOUT-PHILOSOPHY|Our philosophy · Image', 'ABOUT-APPROACH-1|Our approach · Space first, then form', 'ABOUT-APPROACH-2|Our approach · Structure as part of design',
    'ABOUT-CEO|Leadership · CEO portrait', 'ABOUT-CTA-BG|Work with us (CTA) · Background image') }
  'pages\services.html' = @{ page = 'Services overview'; url = '/services/'; slots = @(
    'SERVICES-LIST-ARCH|Service list hover · 01 Architectural Design', 'SERVICES-LIST-STR|Service list hover · 02 Structural Engineering', 'SERVICES-LIST-INT|Service list hover · 03 Interior Design',
    'SERVICES-LIST-DB|Service list hover · 04 Design & Build', 'SERVICES-LIST-STEEL|Service list hover · 05 Steel Structures', 'SERVICES-LIST-PEB|Service list hover · 06 PEB Structures',
    'SERVICES-LIST-FACADE|Service list hover · 07 Facade Engineering', 'SERVICES-LIST-TENS|Service list hover · 08 Tensile & Special',
    'SERVICES-MOSAIC-1|Image mosaic · 1', 'SERVICES-MOSAIC-2|Image mosaic · 2', 'SERVICES-MOSAIC-3|Image mosaic · 3', 'SERVICES-MOSAIC-4|Image mosaic · 4', 'SERVICES-MOSAIC-5|Image mosaic · 5') }
  'pages\service-architectural-design.html' = @{ page = 'Service · Architectural Design'; url = '/services/architectural-design/'; slots = @(
    'SVC-ARCH-HERO|Page header · Full-width background', 'SVC-ARCH-DUO-1|Image pair · Left', 'SVC-ARCH-DUO-2|Image pair · Right', 'SVC-ARCH-TYPOLOGIES|Typologies · Image',
    'SVC-ARCH-PREV|Bottom navigation · Previous service', 'SVC-ARCH-NEXT|Bottom navigation · Next service') }
  'pages\service-structural-engineering.html' = @{ page = 'Service · Structural Engineering'; url = '/services/structural-engineering/'; slots = @(
    'SVC-STR-HERO|Page header · Image', 'SVC-STR-OVERVIEW|Overview · Image', 'SVC-STR-PROCESS|How we work · Image',
    'SVC-STR-PREV|Bottom navigation · Previous service', 'SVC-STR-NEXT|Bottom navigation · Next service') }
  'pages\service-interior-design.html' = @{ page = 'Service · Interior Design'; url = '/services/interior-design/'; slots = @(
    'SVC-INT-HERO|Page header · Side image',
    'SVC-INT-GALLERY-1|Interior gallery · 1 Living room', 'SVC-INT-GALLERY-2|Interior gallery · 2 Kitchen & dining', 'SVC-INT-GALLERY-3|Interior gallery · 3 Master bedroom',
    'SVC-INT-GALLERY-4|Interior gallery · 4 Lounge', 'SVC-INT-GALLERY-5|Interior gallery · 5 Home office', 'SVC-INT-GALLERY-6|Interior gallery · 6 Showroom',
    'SVC-INT-GALLERY-7|Interior gallery · 7 Hospitality', 'SVC-INT-GALLERY-8|Interior gallery · 8 Lobby', 'SVC-INT-GALLERY-9|Interior gallery · 9 Workspace',
    'SVC-INT-RESIDENTIAL|Sectors · Residential interiors', 'SVC-INT-COMMERCIAL|Sectors · Commercial interiors', 'SVC-INT-CORPORATE|Sectors · Corporate interiors',
    'SVC-INT-PREV|Bottom navigation · Previous service', 'SVC-INT-NEXT|Bottom navigation · Next service') }
  'pages\service-design-and-build.html' = @{ page = 'Service · Design & Build'; url = '/services/design-and-build/'; slots = @(
    'SVC-DB-HERO|Page header · Full-width background', 'SVC-DB-SUITED|Suited to · Image', 'SVC-DB-PREV|Bottom navigation · Previous service', 'SVC-DB-NEXT|Bottom navigation · Next service') }
  'pages\service-steel-structures.html' = @{ page = 'Service · Steel Structures'; url = '/services/steel-structures/'; slots = @(
    'SVC-STEEL-HERO|Photo band under header · Wide image', 'SVC-STEEL-GALLERY-1|Steel gallery · Image 1', 'SVC-STEEL-GALLERY-2|Steel gallery · Image 2',
    'SVC-STEEL-PREV|Bottom navigation · Previous service', 'SVC-STEEL-NEXT|Bottom navigation · Next service') }
  'pages\service-peb-structures.html' = @{ page = 'Service · PEB Structures'; url = '/services/peb-structures/'; slots = @(
    'SVC-PEB-HERO|Page header · Full-width background', 'SVC-PEB-WHATIS|What is a PEB · Image',
    'SVC-PEB-TYPE-1|PEB building types · Industrial warehouse', 'SVC-PEB-TYPE-2|PEB building types · Factory building', 'SVC-PEB-TYPE-3|PEB building types · Logistics loading bays', 'SVC-PEB-TYPE-4|PEB building types · Multi-span facility',
    'SVC-PEB-PREV|Bottom navigation · Previous service', 'SVC-PEB-NEXT|Bottom navigation · Next service') }
  'pages\service-facade-engineering.html' = @{ page = 'Service · Facade Engineering'; url = '/services/facade-engineering/'; slots = @(
    'SVC-FACADE-HERO|Page header · Side image', 'SVC-FACADE-DETAIL|Technical detailing · Image',
    'SVC-FACADE-GALLERY-1|Facade gallery · 1', 'SVC-FACADE-GALLERY-2|Facade gallery · 2', 'SVC-FACADE-GALLERY-3|Facade gallery · 3', 'SVC-FACADE-GALLERY-4|Facade gallery · 4',
    'SVC-FACADE-PREV|Bottom navigation · Previous service', 'SVC-FACADE-NEXT|Bottom navigation · Next service') }
  'pages\service-tensile-structures.html' = @{ page = 'Service · Tensile & Special Structures'; url = '/services/tensile-structures/'; slots = @(
    'SVC-TENS-HERO|Page header · Full-width background', 'SVC-TENS-OVERVIEW|Overview · Image', 'SVC-TENS-SCOPE|Our scope · Image',
    'SVC-TENS-PREV|Bottom navigation · Previous service', 'SVC-TENS-NEXT|Bottom navigation · Next service') }
  'pages\projects.html' = @{ page = 'Projects (portfolio page)'; url = '/projects/'; slots = @('PROJECTS-HERO|Page header · Full-width background', 'PROJECTS-STEEL|Steel on site · Image') }
  'pages\packages.html' = @{ page = 'Packages & Estimate'; url = '/packages/'; slots = @(
    'PACKAGES-HERO|Page header · Side image', 'PACKAGES-ADDON-STR|Specialist scopes · Structural engineering', 'PACKAGES-ADDON-STEEL|Specialist scopes · Steel structures',
    'PACKAGES-ADDON-FACADE|Specialist scopes · Facade design', 'PACKAGES-ADDON-INT|Specialist scopes · Interior design') }
  'pages\process.html' = @{ page = 'Our Process'; url = '/process/'; slots = @(
    'PROCESS-1|Process stages · 01 Client consultation', 'PROCESS-2|Process stages · 02 Requirement analysis', 'PROCESS-3|Process stages · 03 Concept development',
    'PROCESS-4|Process stages · 04 Architectural planning', 'PROCESS-5|Process stages · 05 Structural engineering', 'PROCESS-6|Process stages · 06 Technical coordination',
    'PROCESS-7|Process stages · 07 Execution planning', 'PROCESS-8|Process stages · 08 Construction & installation', 'PROCESS-9|Process stages · 09 Quality review', 'PROCESS-10|Process stages · 10 Project handover') }
  'pages\quality.html' = @{ page = 'Quality'; url = '/quality/'; slots = @(
    'QUALITY-HERO|Page header · Full-width background', 'QUALITY-GATES-1|Three gates of quality · Image 1', 'QUALITY-GATES-2|Three gates of quality · Image 2 (wide)', 'QUALITY-CTA-BG|Engineered to endure (CTA) · Background') }
  'pages\team.html' = @{ page = 'Team'; url = '/team/'; slots = @(
    'TEAM-CEO|Leadership · CEO portrait', 'TEAM-MEMBER-1|Team grid · Member 1', 'TEAM-MEMBER-2|Team grid · Member 2', 'TEAM-MEMBER-3|Team grid · Member 3', 'TEAM-CTA-BG|Meet the team (CTA) · Background') }
  'pages\careers.html' = @{ page = 'Careers'; url = '/careers/'; slots = @('CAREERS-HERO|Page header · Side image') }
  'pages\contact.html' = @{ page = 'Contact'; url = '/contact/'; slots = @('CONTACT-HERO|Page header · Background image') }
}
# Placements rendered by js/main.js (no <img> in the source)
$ExtraSlots = @(
  @{ key = 'TEAM-MEMBER-4'; label = 'Team grid · Member 4'; page = 'Team'; url = '/team/' },
  @{ key = 'TEAM-MEMBER-5'; label = 'Team grid · Member 5'; page = 'Team'; url = '/team/' },
  @{ key = 'TEAM-MEMBER-6'; label = 'Team grid · Member 6'; page = 'Team'; url = '/team/' },
  @{ key = 'TEAM-GROUP'; label = 'One team · Group photo'; page = 'Team'; url = '/team/' }
)

# ------------------------------------------------------------------
# CATEGORIES & SUBCATEGORIES
# ------------------------------------------------------------------
$Categories = @(
  @('HOME', 'Landing Page', 'Landing Page Images', '/', 'Hero,Banner,Slider,About,Services,Projects,CTA,Background'),
  @('ARCH', 'Architectural Design', 'Architectural & Interior Design', '/services/architectural-design/', 'Modern Houses,Contemporary Houses,Luxury Villas,Residential Buildings,Commercial Buildings,Elevation Designs,Exterior Designs,Landscape Architecture,Facade Concepts'),
  @('INT', 'Interior Design', 'Architectural & Interior Design', '/services/interior-design/', 'Living Rooms,Bedrooms,Kitchens,Bathrooms,False Ceilings,Office Interiors,Commercial Interiors,Furniture Designs,Lighting Designs,Custom Interiors'),
  @('STR', 'Structural Design & Engineering', 'Structural Design & Engineering', '/services/structural-engineering/', 'Structural Drawings,RCC Structures,Steel Structures,Foundation Designs,Industrial Structures,Structural Analysis,Framing Systems,Technical Drawings,Engineering Details'),
  @('DB', 'Design & Build', 'Design & Build', '/services/design-and-build/', 'Residential Construction,Commercial Construction,Industrial Construction,Turnkey Projects,Building Construction,Renovation,Site Development,Complete Project Execution'),
  @('PEB', 'PEB Structures', 'PEB Structures', '/services/peb-structures/', 'Industrial Sheds,Warehouses,Factory Buildings,Logistics Buildings,Manufacturing Units,PEB Structures,Steel Framework,Roof Structures,Site Offices,Industrial Parks'),
  @('STEEL', 'Structural Steel', 'Steel, Roofing & Cladding', '/services/steel-structures/', 'Structural Steel,Steel Fabrication,Steel Trusses,Canopies'),
  @('ROOF', 'Roofing & Cladding', 'Steel, Roofing & Cladding', '/services/steel-structures/', 'Roofing Systems,Wall Cladding,Metal Roofing,Industrial Roofing,Sandwich Panels,PUF Panels'),
  @('FACADE', 'Facades', 'Facades, Skylights & Tensile', '/services/facade-engineering/', 'Architectural Facades,Glass Facades,Aluminium Facades,Metal Facades,Special Architectural Structures'),
  @('SKY', 'Skylights', 'Facades, Skylights & Tensile', '/services/facade-engineering/', 'Skylight Systems,Roof Skylights'),
  @('TENS', 'Tensile Structures', 'Facades, Skylights & Tensile', '/services/tensile-structures/', 'Tensile Structures,Entrance Canopies,Fabric Structures,Car Park Structures,Special Structures'),
  @('PROJECT', 'Project Photographs', 'Projects', '/projects/', 'Project Photos,Before,After,Site Progress,Completed'),
  @('PROC', 'Process & Design Journey', 'Company', '/process/', 'Consultation,Drawings,3D Visualisation,Construction'),
  @('TEAM', 'Team', 'Company', '/team/', 'Leadership,Team Members,Group Photos'),
  @('ABOUT', 'About Us', 'Company', '/about/', 'Company,Office,Events,Awards')
)

# ------------------------------------------------------------------
# EXISTING IMAGES -> permanent image IDs
# ------------------------------------------------------------------
$buildSrc = Read-Text "$B\build.ps1"
$rx = [regex]"@\('([A-Z]\d\d)','([^']+)','((?:[^']|'')+)','([^']+)','([^']+)','((?:[^']|'')*)'"
$Projects = @()
foreach ($m in $rx.Matches($buildSrc)) {
  $Projects += [pscustomobject]@{ code = $m.Groups[1].Value; slug = $m.Groups[2].Value; title = $m.Groups[3].Value.Replace("''", "'"); filters = $m.Groups[4].Value; primary = $m.Groups[5].Value; concept = $m.Groups[6].Value.Replace("''", "'") }
}
if ($Projects.Count -lt 1) { throw 'Could not read the project list from build.ps1' }
$catDir = @{ R = 'residential-buildings'; C = 'commercial-buildings'; F = 'facades'; P = 'peb-structures'; I = 'industrial-buildings'; S = 'steel-structures'; T = 'tensile-structures' }
$catLabel = @{ residential = 'Residential Buildings'; commercial = 'Commercial Buildings'; facades = 'Facades'; peb = 'PEB Structures'; industrial = 'Industrial Buildings'; steel = 'Steel Structures'; tensile = 'Tensile Structures' }
function ImgPath($code) { '/assets/project-images/subha-infra-{0}-{1}.jpg' -f $catDir[$code.Substring(0, 1)], $code.Substring(1) }

$Images = New-Object System.Collections.ArrayList
$byPath = @{}; $byCode = @{}
$seq = [ordered]@{}
function Add-Img($prefix, $name, $sub, $path, $alt, $code) {
  if (-not $seq.Contains($prefix)) { $seq[$prefix] = 0 }
  $seq[$prefix]++
  $id = '{0}-{1:D3}' -f $prefix, $seq[$prefix]
  $full = Join-Path $root $path.TrimStart('/')
  $w = 0; $h = 0; $bytes = 0
  if (Test-Path $full) { $i = [System.Drawing.Image]::FromFile($full); $w = $i.Width; $h = $i.Height; $i.Dispose(); $bytes = (Get-Item $full).Length }
  $o = [pscustomobject]@{ image_id = $id; prefix = $prefix; seq = $seq[$prefix]; original_filename = [IO.Path]::GetFileName($path); display_name = $name; category_code = $prefix
    subcategory = $sub; url = $path; alt_text = $alt; width = $w; height = $h; bytes = $bytes; notes = ''; display_order = $seq[$prefix] }
  [void]$Images.Add($o); $byPath[$path] = $o; if ($code) { $byCode[$code] = $o }
}
function Sub-For($p) {
  $t = $p.title
  switch ($p.code.Substring(0, 1)) {
    'R' { if ($t -match 'Villa') { 'Luxury Villas' } elseif ($t -match 'Apartment') { 'Residential Buildings' } elseif ($t -match 'Brick|Duplex|Townhouse') { 'Contemporary Houses' } else { 'Modern Houses' } }
    'C' { 'Commercial Buildings' }
    'F' { switch ($p.code) { 'F01' { 'Aluminium Facades' } 'F04' { 'Glass Facades' } default { 'Architectural Facades' } } }
    'P' { if ($p.code -eq 'P01') { 'Warehouses' } else { 'Logistics Buildings' } }
    'I' { if ($p.code -eq 'I01') { 'Factory Buildings' } else { 'Logistics Buildings' } }
    'S' { if ($p.code -eq 'S01') { 'Structural Steel' } else { 'Steel Fabrication' } }
    'T' { 'Car Park Structures' }
  }
}
$prefixFor = @{ R = 'ARCH'; C = 'ARCH'; F = 'FACADE'; P = 'PEB'; I = 'PEB'; S = 'STEEL'; T = 'TENS' }
foreach ($letter in 'R', 'C', 'F', 'P', 'I', 'S', 'T') {
  foreach ($p in ($Projects | Where-Object { $_.code.StartsWith($letter) } | Sort-Object code)) {
    Add-Img $prefixFor[$letter] $p.title (Sub-For $p) (ImgPath $p.code) ("{0} — {1} by SUBHA INFRA" -f $p.title, $catLabel[$p.primary]) $p.code
  }
}
$int = @(@('Living room interior', 'Living Rooms'), @('Kitchen and dining interior', 'Kitchens'), @('Master bedroom interior', 'Bedrooms'), @('Lounge interior', 'Living Rooms'),
  @('Home office interior', 'Office Interiors'), @('Showroom interior', 'Commercial Interiors'), @('Hospitality interior', 'Commercial Interiors'), @('Lobby interior', 'Commercial Interiors'), @('Workspace interior', 'Office Interiors'))
for ($k = 0; $k -lt $int.Count; $k++) { Add-Img 'INT' $int[$k][0] $int[$k][1] ('/assets/service-images/interiors/interior-{0:D2}.jpg' -f ($k + 1)) ($int[$k][0] + ' by SUBHA INFRA') $null }
$jr = @(@('Consultation and brief', 'Consultation'), @('Architectural floor plan', 'Drawings'), @('3D space layout', '3D Visualisation'), @('Structural drawings', 'Drawings'),
  @('3D elevation design', '3D Visualisation'), @('Approval drawings', 'Drawings'), @('3D interior design', '3D Visualisation'), @('Construction and handover', 'Construction'))
for ($k = 0; $k -lt $jr.Count; $k++) { Add-Img 'PROC' $jr[$k][0] $jr[$k][1] ('/assets/service-images/journey/journey-{0:D2}.jpg' -f ($k + 1)) $jr[$k][0] $null }
Add-Img 'TEAM' 'Surya Prathap — CEO & Founder' 'Leadership' '/assets/images/team/ceo-surya-prathap.jpg' 'Surya Prathap, CEO and Founder of SUBHA INFRA' $null

# Flag placeholder files that are byte-identical copies of another image
$hash = @{}
foreach ($im in $Images) { $f = Join-Path $root $im.url.TrimStart('/'); if (Test-Path $f) { $hk = (Get-FileHash $f -Algorithm MD5).Hash; if ($hash[$hk]) { $im.notes = "PLACEHOLDER: same photo as $($hash[$hk].image_id) ($($hash[$hk].display_name)). Replace with a real photo." } else { $hash[$hk] = $im } } }

# ------------------------------------------------------------------
# TAG SOURCES + collect placements
# ------------------------------------------------------------------
$Slots = New-Object System.Collections.ArrayList
$Assign = [ordered]@{}
function SizeHint($key) {
  if ($key -match 'HERO|CTA-BG|FEATURE|STEEL-HERO|TEAM-GROUP') { return @(2400, 1350, '100vw') }
  if ($key -match '^NAV-|PREV$|NEXT$|SERVICES-LIST') { return @(800, 600, '(max-width: 760px) 50vw, 320px') }
  if ($key -match 'TEAM-MEMBER|TEAM-CEO|ABOUT-CEO') { return @(900, 1100, '(max-width: 760px) 100vw, 33vw') }
  return @(1600, 1200, '(max-width: 760px) 100vw, 50vw')
}
$sort = 0
foreach ($file in $Pages.Keys) {
  $def = $Pages[$file]; $path = Join-Path $B $file
  $src = Read-Text $path
  $src = [regex]::Replace($src, '<img data-slot="[^"]*" ', '<img ')
  $n = 0; $found = @()
  $src = [regex]::Replace($src, '<img ', { param($m) $script:n++; $k = ($def.slots[$script:n - 1] -split '\|')[0]; '<img data-slot="' + $k + '" ' })
  if ($n -ne $def.slots.Count) { throw "$file has $n <img> tags but $($def.slots.Count) placements are defined. Update the table in generate-cms.ps1." }
  Write-Text $path $src
  foreach ($m in [regex]::Matches($src, '<img data-slot="([^"]+)"[^>]*?src="([^"]+)"')) { $found += , @($m.Groups[1].Value, $m.Groups[2].Value) }
  for ($k = 0; $k -lt $def.slots.Count; $k++) {
    $parts = $def.slots[$k] -split '\|'; $key = $parts[0]; $lab = $parts[1]
    $sec = ($lab -split ' · ')[0]; $item = ($lab -split ' · ', 2)[1]
    $s = $found[$k][1]; $img = $null
    if ($s -match '^\{\{([A-Z]\d\d)\}\}$') { $img = $byCode[$Matches[1]] } elseif ($byPath.ContainsKey($s)) { $img = $byPath[$s] }
    $hint = SizeHint $key; $sort++
    [void]$Slots.Add([pscustomobject]@{ slot_key = $key; page = $def.page; page_url = $def.url; section = $sec; label = $item; recommended_w = $hint[0]; recommended_h = $hint[1]; sizes = $hint[2]; sort = $sort; source_file = '_build\' + $file })
    $Assign[$key] = $(if ($img) { $img.image_id } else { '' })
  }
}
foreach ($x in $ExtraSlots) { $hint = SizeHint $x.key; $sort++
  [void]$Slots.Add([pscustomobject]@{ slot_key = $x.key; page = $x.page; page_url = $x.url; section = ($x.label -split ' · ')[0]; label = ($x.label -split ' · ')[1]; recommended_w = $hint[0]; recommended_h = $hint[1]; sizes = $hint[2]; sort = $sort; source_file = 'js\main.js' })
  $Assign[$x.key] = '' }
$dupe = $Slots | Group-Object slot_key | Where-Object Count -gt 1
if ($dupe) { throw "Duplicate placement keys: $($dupe.Name -join ', ')" }

# ------------------------------------------------------------------
# PROJECTS (PRJ-001 ... in website order)
# ------------------------------------------------------------------
$homeFeatured = @('evening-pool-pavilion-villa', 'timber-frame-corner-residence', 'corporate-office-pergola-crown', 'feature-colour-facade-residence', 'curved-terrace-apartment-building')
$PrjRows = @(); $n = 0
foreach ($p in $Projects) { $n++
  $PrjRows += [pscustomobject]@{ project_no = ('PRJ-{0:D3}' -f $n); slug = $p.slug; name = $p.title; category = $catLabel[$p.primary]; location = ''; description = $p.concept
    featured_image_id = $byCode[$p.code].image_id; status = $(if ($p.primary -eq 'steel') { 'Construction stage' } else { 'Design visualisation' }); year = ''
    featured = ($homeFeatured -contains $p.slug); published = $true; sort = $n }
}

# ------------------------------------------------------------------
# WRITE Seed.gs
# ------------------------------------------------------------------
$cats = @(); $subs = @(); $ci = 0
foreach ($c in $Categories) { $ci++
  $cats += [pscustomobject]@{ code = $c[0]; name = $c[1]; group = $c[2]; service_url = $c[3]; sort = $ci }
  $si = 0; foreach ($s in $c[4].Split(',')) { $si++; $subs += [pscustomobject]@{ category_code = $c[0]; name = $s; sort = $si } }
}
$counters = [ordered]@{}; foreach ($c in $Categories) { $counters[$c[0]] = 0 }; foreach ($k in $seq.Keys) { $counters[$k] = $seq[$k] }; $counters['PRJ'] = $Projects.Count
$seed = [ordered]@{ generated = (Get-Date -Format 'yyyy-MM-dd HH:mm'); categories = $cats; subcategories = $subs; images = @($Images); slots = @($Slots)
  assignments = $Assign; projects = $PrjRows; counters = $counters }
$json = $seed | ConvertTo-Json -Depth 6 -Compress
New-Item -ItemType Directory -Force "$CmsDir\apps-script" | Out-Null
Write-Text "$CmsDir\apps-script\Seed.gs" ("/* GENERATED by _build/cms/generate-cms.ps1 on $($seed.generated) — do not edit by hand.`n   Initial database: every existing website image, placement and project. Used once by setup(). */`nvar SEED = " + $json + ";`n")

# ------------------------------------------------------------------
# WRITE IMAGE-MAP.md + image-map.html
# ------------------------------------------------------------------
$use = @{}; foreach ($k in $Assign.Keys) { $v = $Assign[$k]; if ($v) { if (-not $use[$v]) { $use[$v] = @() }; $use[$v] += $k } }
$prjUse = @{}; foreach ($p in $PrjRows) { $prjUse[$p.featured_image_id] = @($prjUse[$p.featured_image_id]) + $p.project_no | Where-Object { $_ } }
$imgById = @{}; foreach ($im in $Images) { $imgById[$im.image_id] = $im }
$md = New-Object System.Text.StringBuilder
[void]$md.AppendLine("# SUBHA INFRA — Image map`n`nGenerated $($seed.generated) by ``_build/cms/generate-cms.ps1``. **$($Images.Count) images, $($Slots.Count) placements, $($PrjRows.Count) projects.**`n")
[void]$md.AppendLine("- **Image ID** (e.g. ``PEB-001``) = the photo itself. Permanent; never reused, even after deletion.`n- **Placement key** (e.g. ``HOME-HERO-1``) = a fixed spot on the website. In the HTML it is ``data-slot=""HOME-HERO-1""``.`n- One image can fill many placements; changing a placement never copies the file.`n- See any page with labels on every image: open ``https://www.subhainfra.com/?cms_labels=1`` (any page works).`n")
[void]$md.AppendLine("## 1. Placements — where every image appears`n")
foreach ($grp in ($Slots | Group-Object page)) {
  [void]$md.AppendLine("### $($grp.Name) — ``$($grp.Group[0].page_url)```n`n| Placement key | Section · item | Image ID | Image | Size |`n|---|---|---|---|---|")
  foreach ($s in $grp.Group) { $iid = $Assign[$s.slot_key]; $nm = $(if ($iid) { $imgById[$iid].display_name } else { '_(placeholder — empty)_' })
    [void]$md.AppendLine("| ``$($s.slot_key)`` | $($s.section) · $($s.label) | $(if ($iid) { '``' + $iid + '``' } else { '—' }) | $nm | $($s.recommended_w)×$($s.recommended_h) |") }
  [void]$md.AppendLine()
}
[void]$md.AppendLine("## 2. Image library — every image and where it is used`n`n| Image ID | Name | Category › Subcategory | File | Used in placements | Project | Note |`n|---|---|---|---|---|---|---|")
foreach ($im in $Images) { [void]$md.AppendLine("| ``$($im.image_id)`` | $($im.display_name) | $($im.category_code) › $($im.subcategory) | ``$($im.url)`` | $((@($use[$im.image_id]) | Where-Object { $_ }) -join ', ') | $((@($prjUse[$im.image_id]) | Where-Object { $_ }) -join ', ') | $($im.notes) |") }
[void]$md.AppendLine("`n## 3. Projects`n`n| Project no. | Name | Page | Featured image |`n|---|---|---|---|")
foreach ($p in $PrjRows) { [void]$md.AppendLine("| ``$($p.project_no)`` | $($p.name) | ``/projects/$($p.slug)/`` | ``$($p.featured_image_id)`` |") }
[void]$md.AppendLine("`nProject pages: the main image of each project (portfolio card, page header, previous/next links, gallery) uses the project's **featured image**; the gallery uses the project's photos when any are added in the CMS.")
Write-Text "$CmsDir\IMAGE-MAP.md" $md.ToString()

$h = New-Object System.Text.StringBuilder
[void]$h.Append('<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>SUBHA INFRA Image Map</title><style>:root{--navy:#101D2B;--gold:#B69A70;--line:#e6e2da}*{box-sizing:border-box}body{margin:0;font:14px/1.45 Inter,Segoe UI,Arial,sans-serif;color:#1d2733;background:#fff}header{background:var(--navy);color:#fff;padding:22px 24px;position:sticky;top:0;z-index:2;display:flex;gap:16px;align-items:center;flex-wrap:wrap}header b{letter-spacing:.14em}header small{color:var(--gold);letter-spacing:.2em;font-size:11px}input{flex:1;min-width:200px;padding:10px 12px;border-radius:8px;border:0;font:inherit}main{padding:16px;max-width:1400px;margin:auto}h2{font-size:18px;margin:34px 0 4px;color:var(--navy);border-bottom:2px solid var(--gold);padding-bottom:6px}h2 code{font-size:13px;color:#7a6a50}.g{display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:14px;margin-top:14px}.c{border:1px solid var(--line);border-radius:10px;overflow:hidden;background:#fff}.c img{width:100%;aspect-ratio:4/3;object-fit:cover;display:block;background:#f3f1ec}.c div{padding:9px 11px}.k{font:600 12px ui-monospace,Consolas,monospace;color:var(--navy)}.id{display:inline-block;background:var(--navy);color:#fff;border-radius:4px;padding:1px 6px;font:600 11px ui-monospace,Consolas,monospace;margin-top:4px}.id.e{background:#c9c3b8}.l{color:#5b6672;font-size:12.5px}.w{color:#a3541b;font-size:12px;margin-top:4px}.ph{display:grid;place-items:center;aspect-ratio:4/3;background:#f3f1ec;color:#8a8478;font-size:12px}</style></head><body><header><div><b>SUBHA INFRA</b><br><small>IMAGE MAP</small></div><input id="q" placeholder="Search placement key, image ID, name or page…  e.g. HOME-HERO, PEB-001, interior"><span>' + $Images.Count + ' images · ' + $Slots.Count + ' placements</span></header><main>')
foreach ($grp in ($Slots | Group-Object page)) {
  [void]$h.Append('<section><h2>' + (Enc $grp.Name) + ' <code>' + (Enc $grp.Group[0].page_url) + '</code></h2><div class="g">')
  foreach ($s in $grp.Group) { $iid = $Assign[$s.slot_key]; $im = $(if ($iid) { $imgById[$iid] } else { $null })
    $thumb = $(if ($im) { '<img loading="lazy" src="../..' + $im.url + '" alt="">' } else { '<div class="ph">Empty placeholder</div>' })
    [void]$h.Append('<div class="c" data-q="' + (Enc ("$($s.slot_key) $iid $($im.display_name) $($s.page) $($s.section) $($s.label)").ToLower()) + '">' + $thumb + '<div><div class="k">' + $s.slot_key + '</div><div class="l">' + (Enc "$($s.section) · $($s.label)") + '</div>' + $(if ($im) { '<span class="id">' + $iid + '</span> <span class="l">' + (Enc $im.display_name) + '</span>' } else { '<span class="id e">no image</span>' }) + $(if ($im -and $im.notes) { '<div class="w">⚠ placeholder copy</div>' } else { '' }) + '</div></div>') }
  [void]$h.Append('</div></section>')
}
[void]$h.Append('<section><h2>All images <code>image library</code></h2><div class="g">')
foreach ($im in $Images) { $u = (@($use[$im.image_id]) | Where-Object { $_ }) -join ', '
  [void]$h.Append('<div class="c" data-q="' + (Enc ("$($im.image_id) $($im.display_name) $($im.subcategory) $u").ToLower()) + '"><img loading="lazy" src="../..' + $im.url + '" alt=""><div><span class="id">' + $im.image_id + '</span><div class="k" style="margin-top:4px">' + (Enc $im.display_name) + '</div><div class="l">' + $im.category_code + ' › ' + (Enc $im.subcategory) + '</div><div class="l">Used in: ' + $(if ($u) { $u } else { '<i>not placed</i>' }) + '</div>' + $(if ($im.notes) { '<div class="w">⚠ ' + (Enc $im.notes) + '</div>' } else { '' }) + '</div></div>') }
[void]$h.Append('</div></section></main><script>q.oninput=()=>{const v=q.value.toLowerCase().trim();document.querySelectorAll(".c").forEach(c=>c.style.display=!v||c.dataset.q.includes(v)?"":"none");document.querySelectorAll("section").forEach(s=>s.style.display=[...s.querySelectorAll(".c")].some(c=>c.style.display!=="none")?"":"none")}</script></body></html>')
Write-Text "$CmsDir\image-map.html" $h.ToString()

"CMS seed: $($Images.Count) images, $($Slots.Count) placements, $($PrjRows.Count) projects -> $CmsDir\apps-script\Seed.gs, IMAGE-MAP.md, image-map.html"
