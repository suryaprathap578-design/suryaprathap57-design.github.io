# SUBHA INFRA static site builder
# Assembles _build/pages/*.html with shared partials into clean-URL folders (/about/index.html etc.),
# generates one detail page per portfolio project, sitemap.xml and robots.txt.
# Usage: powershell -ExecutionPolicy Bypass -File _build\build.ps1
#   Site served from a sub-folder (e.g. a GitHub Pages project site without a custom domain):
#   powershell -ExecutionPolicy Bypass -File _build\build.ps1 -Base /suryaprathap57-design.github.io
#   Run again without -Base before serving from a domain root (www.subhainfra.com or localhost).
param([string]$Base = '')
$ErrorActionPreference = 'Stop'
$Base = ('/' + $Base.Trim().Trim('/')).TrimEnd('/')   # '' or '/folder'
Add-Type -AssemblyName System.Drawing
$B = $PSScriptRoot
$root = Split-Path -Parent $B
$utf8 = New-Object System.Text.UTF8Encoding($false)
function Read-Text($p) { [IO.File]::ReadAllText($p, [Text.Encoding]::UTF8) }
function Write-Text($p, $s) { [IO.File]::WriteAllText($p, $s, $utf8) }
function Enc($s) { [System.Net.WebUtility]::HtmlEncode($s) }

$site = 'https://www.subhainfra.com/'
$head = Read-Text "$B\partials\head.html"
$header = Read-Text "$B\partials\header.html"
$footer = Read-Text "$B\partials\footer.html"

$AR = '<svg class="ar" viewBox="0 0 18 10" fill="none" stroke="currentColor" stroke-width="1.4" aria-hidden="true"><path d="M0 5h16M12 1l4 4-4 4"/></svg>'
$LOGO = '<img class="logo-mark" src="/assets/images/brand/subha-infra-mark-light.png" alt="" width="44" height="48">'
$LOCKUP = '<a class="logo" href="/" aria-label="SUBHA INFRA — home"><img class="logo-mark" src="/assets/images/brand/subha-infra-mark-light.png" alt="" width="44" height="48"><span class="logo-t"><b>SUBHA</b><span class="logo-infra"><i></i>INFRA<i></i></span><small>Designed to inspire</small></span></a>'
$WA_PATH = '<path d="M12.04 2C6.58 2 2.13 6.45 2.13 11.91c0 1.75.46 3.45 1.32 4.95L2.05 22l5.25-1.38a9.9 9.9 0 0 0 4.74 1.21c5.46 0 9.91-4.45 9.91-9.91C21.95 6.45 17.5 2 12.04 2zm0 18.15a8.2 8.2 0 0 1-4.19-1.15l-.3-.18-3.12.82.83-3.04-.2-.31a8.23 8.23 0 0 1-1.26-4.38c0-4.54 3.7-8.24 8.24-8.24 4.54 0 8.23 3.7 8.23 8.24 0 4.54-3.69 8.24-8.23 8.24zm4.52-6.16c-.25-.12-1.47-.72-1.69-.81-.23-.08-.39-.12-.56.13-.17.25-.64.81-.78.97-.14.17-.29.19-.54.06-.25-.12-1.05-.39-1.99-1.23-.74-.66-1.23-1.47-1.38-1.72-.14-.25-.02-.38.11-.51.11-.11.25-.29.37-.43.12-.14.17-.25.25-.41.08-.17.04-.31-.02-.43-.06-.12-.56-1.34-.76-1.84-.2-.48-.41-.42-.56-.43h-.48c-.17 0-.43.06-.66.31-.22.25-.86.85-.86 2.07 0 1.22.89 2.4 1.01 2.56.12.17 1.75 2.67 4.23 3.74.59.26 1.05.41 1.41.52.59.19 1.13.16 1.56.1.48-.07 1.47-.6 1.67-1.18.21-.58.21-1.07.14-1.18-.06-.11-.22-.17-.47-.29z"/>'
$soc = [ordered]@{
  whatsapp  = @('WhatsApp', ('<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">' + $WA_PATH + '</svg>'))
  linkedin  = @('LinkedIn', '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M4.98 3.5A2.5 2.5 0 1 1 5 8.5a2.5 2.5 0 0 1-.02-5zM3 9.75h4V21H3zM9.5 9.75h3.8v1.6h.06c.53-1 1.83-2.05 3.77-2.05 4.03 0 4.77 2.65 4.77 6.1V21h-4v-4.9c0-1.17-.02-2.67-1.63-2.67-1.63 0-1.88 1.27-1.88 2.59V21h-4z"/></svg>')
  instagram = @('Instagram', '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.5" cy="6.5" r=".6" fill="currentColor"/></svg>')
  facebook  = @('Facebook', '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M13.5 21v-7.5h2.5l.4-3h-2.9V8.6c0-.87.25-1.46 1.5-1.46h1.55V4.47A20 20 0 0 0 14.3 4.3c-2.2 0-3.7 1.34-3.7 3.8v2.4H8.1v3h2.5V21z"/></svg>')
  youtube   = @('YouTube', '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M21.6 7.2a2.5 2.5 0 0 0-1.76-1.77C18.25 5 12 5 12 5s-6.25 0-7.84.43A2.5 2.5 0 0 0 2.4 7.2 26 26 0 0 0 2 12a26 26 0 0 0 .4 4.8 2.5 2.5 0 0 0 1.76 1.77C5.75 19 12 19 12 19s6.25 0 7.84-.43a2.5 2.5 0 0 0 1.76-1.77A26 26 0 0 0 22 12a26 26 0 0 0-.4-4.8zM10 15V9l5.2 3z"/></svg>')
  twitter   = @('X (Twitter)', '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M17.75 3h3.07l-6.7 7.66L22 21h-6.17l-4.83-6.32L5.47 21H2.4l7.17-8.19L2 3h6.33l4.37 5.77zm-1.08 16.17h1.7L7.4 4.73H5.58z"/></svg>')
}
$SOCIALS = '<div class="socials">' + (($soc.Keys | ForEach-Object { '<a data-social="' + $_ + '" href="#" target="_blank" rel="noopener" aria-label="SUBHA INFRA on ' + $soc[$_][0] + '">' + $soc[$_][1] + '</a>' }) -join '') + '</div>'
$CHECK = '<svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true"><path d="M2.5 8.5l3.5 3.5 7.5-8"/></svg>'
$PLUS = '<svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5" aria-hidden="true"><circle cx="8" cy="8" r="6.5"/><path d="M8 5v6M5 8h6"/></svg>'
$MINUS = '<svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5" aria-hidden="true"><path d="M3 8h10"/></svg>'

$catDir = @{ R = 'residential-buildings'; C = 'commercial-buildings'; F = 'facades'; P = 'peb-structures'; I = 'industrial-buildings'; S = 'steel-structures'; T = 'tensile-structures' }
function ImgPath($code) { '/assets/project-images/subha-infra-{0}-{1}.jpg' -f $catDir[$code.Substring(0, 1)], $code.Substring(1) }
$dims = @{}
function Dim($code) {
  if (-not $dims.ContainsKey($code)) {
    $i = [System.Drawing.Image]::FromFile((Join-Path $root (ImgPath $code).TrimStart('/')))
    $dims[$code] = @($i.Width, $i.Height); $i.Dispose()
  }
  $dims[$code]
}

# ---------------- Project data ----------------
# code, slug, title, filter categories, primary category, concept, materials (;-separated)
$Projects = @(
 @('S01','multi-bay-steel-frame','Multi-Bay Steel Frame','steel industrial','steel','A multi-bay structural steel frame at erection stage, with primary columns, rafters and secondary members in place ahead of roofing and cladding.','Hot-rolled and built-up steel sections;Bolted moment connections;Purlins and girts;Protective paint system;RCC pedestals and footings'),
 @('S02','portal-frame-erection','Portal Frame Erection','steel industrial','steel','Crane-assisted erection of portal frames and bracing, showing column alignment, cross-bracing and site sequencing during steel installation.','Built-up columns and rafters;Cross-bracing;Anchor bolts and base plates;Mobile crane erection;Secondary framing'),
 @('P01','logistics-warehouse-dock-canopy','Logistics Warehouse with Dock Canopy','peb industrial','peb','A large-span logistics warehouse with a continuous loading-dock canopy, a glazed office block at the corner and colour-banded metal cladding that breaks down the length of the building.','Pre-engineered steel frame;Profiled metal roof and wall cladding;Curtain-wall glazing;Cantilevered steel dock canopy;Concrete plinth wall'),
 @('P02','peb-distribution-centre','PEB Distribution Centre','peb industrial','peb','A distribution centre pairing a two-storey glazed office front with a long PEB shed and numbered dock doors under a continuous steel canopy.','PEB primary and secondary framing;Insulated wall panels;Rolling shutters;Aluminium glazing;Timber-finish feature fin'),
 @('I01','industrial-facility-glazed-entrance','Industrial Facility with Glazed Entrance','industrial','industrial','A metal-clad industrial facility given a civic face: a double-height glazed entrance pavilion framed by a deep illuminated portal and warm timber-finish fins.','Profiled metal cladding;Double-height curtain wall;Timber-finish aluminium fins;Linear LED soffit;Steel dock canopy'),
 @('I02','loading-bays-dock-canopy','Loading Bays and Dock Canopy','industrial','industrial','The service side of an industrial facility: numbered roller-shutter bays protected by a lit cantilevered canopy and steel bollards, planned for clear truck movement.','Roller shutters;Cantilevered steel canopy;Clerestory glazing band;Impact bollards;Concrete apron'),
 @('T01','steel-glass-carport-canopy','Steel and Glass Car-Park Canopy','tensile residential','tensile','A residence fronted by a raking steel and glass car-park canopy on splayed supports, a special structure that doubles as the architectural signature of the entrance.','Steel box-section frame;Toughened laminated glass;Splayed steel supports;Paver driveway;Exposed concrete panels'),
 @('F01','orange-fin-facade-office','Orange Fin Facade Office','facades commercial','facades','A corporate facade composed of full-height orange metal fins of varying widths over glazing, set on a stone-clad ground floor with a rooftop garden terrace.','Powder-coated aluminium fins;Unitised glazing;Granite cladding;Glass balustrade;Rooftop planters'),
 @('F02','timber-stone-composite-facade','Timber and Stone Composite Facade','facades residential','facades','A multi-storey residence where timber-look louvres, a punched stone screen and framed glazed boxes are composed into a layered street elevation.','Timber-look aluminium louvres;Stone-finish panels with punched openings;Framed glazing boxes;Metal screens'),
 @('F03','feature-colour-facade-residence','Feature Colour Facade Residence','facades residential','facades','A bold residential facade using saturated yellow frames, random rubble stone and horizontal glazing transoms to create strong, legible volumes.','Coloured ACP frames;Random rubble stone cladding;Aluminium glazing with horizontal transoms;Glass balustrades'),
 @('F04','geometric-mullion-glass-facade','Geometric Mullion Glass Facade','facades residential','facades','A single-storey home anchored by a full-height glazed tower whose irregular steel mullion pattern turns the stair volume into a feature.','Steel mullion grid;Double-glazed units;Textured plaster;Vertical timber cladding;Fibre-cement panels'),
 @('F05','timber-rainscreen-central-volume','Timber Rainscreen Central Volume','facades residential','facades','A central timber-clad volume with punched square windows separates two white rendered wings, giving the elevation a clear and balanced rhythm.','Timber-look rainscreen cladding;Rendered masonry;Framed balcony boxes;Glass balustrades'),
 @('C01','brick-glass-retail-office','Brick and Glass Retail-Office Block','commercial','commercial','A three-storey retail and office building combining brick piers, stone banding, deep timber soffits and a glazed top floor above a street-level shopfront.','Facing brick;Precast stone banding;Aluminium shopfront glazing;Timber-finish soffits;Fabric awnings'),
 @('C02','corporate-office-pergola-crown','Corporate Office with Pergola Crown','commercial','commercial','A six-storey office building crowned by a timber pergola, with planted balcony ledges, vertical fins and a marble-clad glazed atrium marking the entrance.','Stone and ACP cladding;Timber-finish pergola;Vertical aluminium fins;Glazed atrium;Planter ledges'),
 @('C03','terraced-green-boutique-building','Terraced Green Boutique Building','commercial','commercial','A boutique commercial building of stacked, cantilevered floor plates with rounded planted edges, glazed corners and timber-batten soffits.','Exposed concrete;Curved slab edges;Timber batten cladding;Perforated screens;Integrated planters'),
 @('C04','stone-clubhouse-reflecting-pool','Stone Clubhouse with Reflecting Pool','commercial','commercial','A horizontal stone clubhouse with deep timber overhangs and a ceremonial stair, set behind a reflecting pool that doubles the composition.','Sandstone cladding;Timber-finish soffits;Floor-to-ceiling glazing;Stone planters;Reflecting pool'),
 @('C05','garden-restaurant-pavilion','Garden Restaurant Pavilion','commercial','commercial','A glazed restaurant pavilion with an upper dining terrace, approached by a central stair framed by cascading water features.','Timber-look cladding;Frameless glazing;Steel canopy structure;Stone stair and water features'),
 @('C06','stone-timber-commercial-pavilion','Stone and Timber Commercial Pavilion','commercial','commercial','A commercial pavilion where a cantilevered timber-clad box floats above a fully glazed ground floor, anchored by a stone feature wall.','Natural stone cladding;Timber-finish panels;Structural glazing;Cantilevered upper volume;Paved forecourt'),
 @('C07','colour-clad-hospitality-pavilion','Colour-Clad Hospitality Pavilion','commercial facades','commercial','A hospitality pavilion with a long glazed upper floor framed in red panels, pierced by a steel pergola and set on a stone podium beside a water edge.','Coloured metal panels;Continuous glazing;Steel pergola;Stone podium;Timber-clad columns'),
 @('C08','mixed-use-tower-terraced-podium','Mixed-Use Tower on Terraced Podium','commercial','commercial','A slender mixed-use tower rising from a glazed podium, with a framed vertical spine, planted terraces and a landscaped stepped plinth.','Concrete frame;Stone and timber-finish cladding;Vertical louvres;Glazed podium;Terraced landscaping'),
 @('R01','angular-white-villa','Angular White Villa with Louvred Fins','residential','residential','A villa defined by raked white planes, illuminated louvred fins and cantilevered balconies wrapped in glass.','Rendered masonry;Aluminium louvres;Marble-effect cladding;Glass balustrades;Concealed LED lighting'),
 @('R02','timber-frame-corner-residence','Timber-Frame Corner Residence','residential','residential','A corner residence organised as stacked, timber-framed boxes projecting over a recessed base, each with a glazed balcony.','Timber-look cladding;Textured grey render;Glass balustrades;Recessed downlights;Planted ledges'),
 @('R03','timber-ivory-duplex','Timber and Ivory Duplex','residential','residential','A duplex home balancing horizontal timber cladding with ivory render, a framed upper balcony and a matching compound wall.','Timber-look cladding;Smooth render;Aluminium windows;Glass balcony;Slatted metal gate'),
 @('R04','stone-timber-charcoal-corner-home','Stone, Timber and Charcoal Corner Home','residential','residential','A corner home layering charcoal cladding, ashlar stone, warm timber and white frames, with a deep cantilevered soffit over the entrance.','Ashlar stone cladding;Charcoal fibre-cement;Timber-finish soffits;Jaali-pattern panels;Glass balustrades'),
 @('R05','glass-pavilion-residence','Glass Pavilion Residence','residential','residential','A highly glazed residence of floating white frames, slatted timber screens and a lit vertical blade beside the entrance.','Structural glazing;White rendered frames;Timber slat screens;Stone-clad boundary wall;Timber garage door'),
 @('R06','colonnaded-contemporary-villa','Colonnaded Contemporary Villa','residential','residential','A contemporary villa with a two-storey colonnade, wide timber eaves and full-height glazing opening onto a paved forecourt.','Limestone-finish cladding;Timber soffits;Black-framed glazing;Metal railings;Hipped roof'),
 @('R07','framed-balcony-urban-residence','Framed-Balcony Urban Residence','residential','residential','An urban residence built around a deep framed balcony with timber battens, terraced glass balconies and a slatted gated carport.','Smooth render;Timber battens;Glass balustrades;Slatted metal gates;Stone-finish boundary wall'),
 @('R08','cantilevered-roof-garden-residence','Cantilevered-Roof Garden Residence','residential','residential','A residence capped by a sweeping timber-soffit roof, with planted terraces at every level and a slatted gate to the parking level.','Timber-finish soffit;Rendered walls;Stone feature column;Integrated planters;Slatted metal gates'),
 @('R09','planted-terrace-residence','Planted-Terrace Residence','residential','residential','A variation of the cantilevered-roof typology with a louvred pergola, cascading planters and a stone chimney element.','Louvred aluminium pergola;Timber-finish soffit;Stone cladding;Glass balustrades;Planter edges'),
 @('R10','compact-timber-soffit-townhouse','Compact Timber-Soffit Townhouse','residential','residential','A narrow-plot townhouse with a deep timber-lined roof frame, a planted balcony ledge and a double-height glazed living space.','Timber-finish soffits;Vertical timber battens;Large-format glazing;Rendered frame;Planters'),
 @('R11','stone-timber-villa-plunge-pool','Stone and Timber Villa with Plunge Pool','residential','residential','A villa combining vertical timber cladding, a stone fireplace wall and a raised plunge pool on the entrance terrace.','Natural stone cladding;Vertical timber cladding;Frameless glazing;Stone steps;Plunge pool'),
 @('R12','brick-two-storey-residence','Brick Two-Storey Residence','residential','residential','A traditional two-storey brick residence with a covered porch, upper balcony and generous divided-light windows.','Facing brick;Precast lintels and sills;Steel railings;Hipped metal roof;Timber porch ceiling'),
 @('R13','travertine-glass-residence','Travertine Glass Residence','residential','residential','A travertine-clad residence with a double-height glazed volume and cantilevered planted terraces stepping across the elevation.','Travertine cladding;Double-height glazing;Concrete cantilevers;Timber louvres;Trailing planters'),
 @('R14','vertical-fin-timber-villa','Vertical-Fin Timber Villa','residential','residential','A wide villa with vertical timber fins, dark stone panels and a framed glass balcony above a covered car porch.','Timber-finish fins;Slate-finish stone;Rendered frame;Glass balustrade;Slatted garage gate'),
 @('R15','narrow-plot-stone-townhouse','Narrow-Plot Stone Townhouse','residential','residential','A narrow-plot townhouse with a stone-clad stair tower, louvred slot window and stacked timber-soffit balconies above stilt parking.','Split-face stone cladding;Aluminium louvres;Timber-finish soffits;Metal railings;Slatted gate'),
 @('R16','curved-terrace-apartment-building','Curved Terrace Apartment Building','residential','residential','A multi-storey residential building of sinuous white slabs, timber soffits and continuous glass balustrades above a glazed ground-floor lobby.','Curved concrete slab edges;Timber-finish soffits;Continuous glass balustrades;Floor-to-ceiling glazing'),
 @('R17','poolside-timber-cantilever-villa','Poolside Timber Cantilever Villa','residential','residential','A pool-facing villa with two timber-clad cantilevers, a stone core and a deck with fire pit stepping down to the water.','Timber-look cladding;Stacked stone;Glass balustrades;Timber deck;Tiled pool'),
 @('R18','grand-stone-pier-villa','Grand Stone-Pier Entrance Villa','residential','residential','A symmetrical villa whose entrance is framed by twin stone piers and a full-height timber door, approached by a broad terraced stair.','Natural stone piers and planters;Vertical timber cladding;Hipped tiled roof;Glass balustrades;Stone steps'),
 @('R19','floating-roof-waterside-villa','Floating-Roof Waterside Villa','residential','residential','A two-storey villa with deep floating roof planes, full-height glazing and a reflecting water channel along the garden edge.','Timber-finish soffits;Rendered piers;Full-height glazing;Timber louvres;Water channel'),
 @('R20','infinity-pool-cantilever-villa','Infinity-Pool Cantilever Villa','residential','residential','A white cantilevered upper volume with a recessed glass balcony floats above a stone-clad living level opening onto an infinity pool.','Rendered cantilever frame;Marble-finish cladding;Frameless glazing;Infinity-edge pool;Step lighting'),
 @('R21','evening-pool-pavilion-villa','Evening Pool Pavilion Villa','residential','residential','A villa composed of a gabled glass volume and a flat-roofed wing, linked by a timber pergola over an outdoor living terrace and pool.','Marble and stone cladding;Timber pergola;Gabled glazing;Vertical timber slats;Infinity pool')
)

$svc = @{
  arch = @('Architectural Design', '/services/architectural-design/'); struct = @('Structural Engineering', '/services/structural-engineering/')
  db = @('Design &amp; Build', '/services/design-and-build/'); facade = @('Facade Engineering', '/services/facade-engineering/')
  peb = @('PEB Structures', '/services/peb-structures/'); steel = @('Steel Structures', '/services/steel-structures/')
  tensile = @('Tensile &amp; Special Structures', '/services/tensile-structures/'); interior = @('Interior Design', '/services/interior-design/')
}
$cat = @{
  residential = @{ label = 'Residential Buildings'; filter = 'residential'; services = @('arch', 'struct', 'db')
    overview = 'This residential design study explores how plan, structure and facade are resolved together. It represents a typology SUBHA INFRA designs and engineers for independent houses, villas and multi-storey homes.'
    scope = @('Architectural concept and space planning', 'Elevations, sections and working drawings', 'RCC structural design and detailing', 'Facade and material specification', 'Construction execution under Design &amp; Build')
    struct = 'Typically an RCC framed structure of columns, beams and slabs on footings designed to site soil data. Cantilevered balconies and deep slab edges are sized and detailed in the structural design so the architecture can be built exactly as drawn.' }
  commercial = @{ label = 'Commercial Buildings'; filter = 'commercial'; services = @('arch', 'struct', 'facade')
    overview = 'A commercial design study in which the identity, structure and envelope of the building are developed as one system. This is the approach SUBHA INFRA applies to offices, retail, showrooms and hospitality buildings.'
    scope = @('Architectural planning and massing', 'Structural design in RCC or steel-composite', 'Facade development and detailing', 'Interior coordination', 'Technical coordination and execution')
    struct = 'Commercial buildings of this kind are typically RCC or steel-composite frames with larger spans for flexible floor plates. Cantilevers, canopies and facade support brackets are coordinated with the structural grid from the start.' }
  facades = @{ label = 'Facades'; filter = 'facades'; services = @('facade', 'arch')
    overview = 'A facade study in which cladding, glazing and shading are composed into a single envelope, designed for appearance, weather performance and buildability.'
    scope = @('Facade concept and material selection', 'ACP, aluminium, glass or metal systems', 'Bracketry and technical detailing', 'Execution coordination')
    struct = 'Facade systems are carried on aluminium or steel sub-frames fixed back to the primary structure through engineered brackets and anchors, with movement joints and drainage detailed at every module.' }
  industrial = @{ label = 'Industrial Buildings'; filter = 'industrial'; services = @('peb', 'steel', 'facade')
    overview = 'An industrial facility planned around operations first, with clear spans, truck movement and service access, and given a considered entrance and envelope.'
    scope = @('Site and layout planning', 'PEB or structural steel engineering', 'Roofing and wall cladding', 'Facade treatment for office blocks', 'Fabrication and erection coordination')
    struct = 'Large-span steel portal frames (PEB or conventional structural steel) with purlins, girts and bracing on RCC footings and plinth walls. Office blocks are typically RCC or steel-composite frames.' }
  peb = @{ label = 'PEB Structures'; filter = 'peb'; services = @('peb', 'steel')
    overview = 'A pre-engineered building conceived for wide clear spans, fast erection and efficient steel tonnage, the core typology for warehouses, logistics hubs and factories.'
    scope = @('PEB structural engineering', 'Primary and secondary framing', 'Roof and wall cladding systems', 'Structural detailing', 'Fabrication and erection coordination')
    struct = 'Tapered built-up primary frames sized to the bending moment along their length, cold-formed purlins and girts, rod or angle bracing, and anchor-bolted base plates on RCC pedestals and footings.' }
  steel = @{ label = 'Steel Structures'; filter = 'steel'; services = @('steel', 'struct', 'peb')
    overview = 'Structural steel at erection stage, where design, detailing and fabrication accuracy become visible on site.'
    scope = @('Structural steel design', 'Connection detailing and fabrication drawings', 'Steel framing and erection coordination', 'Roofing and cladding options')
    struct = 'Steel frames with braced bays, bolted site connections and base plates on RCC pedestals. Erection sequencing and temporary stability are planned before steel arrives on site.' }
  tensile = @{ label = 'Tensile Structures'; filter = 'tensile'; services = @('tensile', 'steel')
    overview = 'A special-structure element, such as a canopy, car park or shade structure, designed to be light, durable and architectural.'
    scope = @('Concept development', 'Structural design of the support system', 'Membrane or glazing selection', 'Technical detailing', 'Fabrication and installation coordination')
    struct = 'A steel support frame carrying either a tensioned membrane or glazed panels, with connections, drainage and wind loads resolved in the structural design.' }
}
$filterLabels = [ordered]@{ residential = 'Residential'; commercial = 'Commercial'; industrial = 'Industrial'; peb = 'PEB Structures'; steel = 'Steel Structures'; facades = 'Facades'; tensile = 'Tensile Structures' }

function Status($p) { if ($p[4] -eq 'steel') { 'Construction stage' } else { 'Design visualisation' } }
function Disclaimer($p) {
  if ($p[4] -eq 'steel') { 'Construction-stage photograph of structural steel erection. Client, location and project values are not published on this website.' }
  else { 'This image is a design visualisation prepared to illustrate a design direction. It is not presented as a completed project. Project-specific details are shared with clients on request.' }
}

# ---------------- Portfolio grid ----------------
$counts = @{}; foreach ($k in $filterLabels.Keys) { $counts[$k] = 0 }
$grid = New-Object System.Text.StringBuilder
$n = 0
foreach ($p in $Projects) {
  $n++
  foreach ($c in $p[3].Split(' ')) { $counts[$c]++ }
  $d = Dim $p[0]; $lbl = $cat[$p[4]].label
  [void]$grid.AppendLine(('<a class="card-gal zoom reveal" href="/projects/{0}/" data-filter-item="pf" data-cats="{1}"><div class="img"><span class="tag"><b>&#9679;</b> {2}</span><img data-project="{0}" src="{3}" alt="{4} — {2} by SUBHA INFRA" width="{5}" height="{6}" loading="lazy"><span class="view" aria-hidden="true">{7}</span></div><div class="card-gal-body"><b>{4}</b><span class="no">{8}</span><small>{9}</small></div></a>' -f $p[1], $p[3], $lbl, (ImgPath $p[0]), (Enc $p[2]), $d[0], $d[1], $AR, ('{0:D2}' -f $n), (Status $p)))
}
$chips = '<button class="chip" type="button" data-filter="all" aria-pressed="true">All projects <sup>' + $Projects.Count + '</sup></button>'
foreach ($k in $filterLabels.Keys) { $chips += '<button class="chip" type="button" data-filter="' + $k + '" aria-pressed="false">' + $filterLabels[$k] + ' <sup>' + $counts[$k] + '</sup></button>' }

$smProjects = (($Projects | ForEach-Object { '<li><a href="/projects/' + $_[1] + '/">' + (Enc $_[2]) + '</a></li>' }) -join '')

# ---------------- Page assembly ----------------
$built = New-Object System.Collections.ArrayList
$legacy = New-Object System.Collections.ArrayList
function Route($file) {
  switch -regex ($file) {
    '^index\.html$'        { return '/' }
    '^service-(.+)\.html$' { return '/services/' + $Matches[1] + '/' }
    '^project-(.+)\.html$' { return '/projects/' + $Matches[1] + '/' }
    '^(.+)\.html$'         { return '/' + $Matches[1] + '/' }
  }
}
function Expand($html) {
  $html = $html.Replace('{{JOURNEY}}', (Read-Text "$B\partials\journey.html"))
  $html = $html.Replace('{{LOCKUP}}', $LOCKUP).Replace('{{SOCIALS}}', $SOCIALS).Replace('{{WA_PATH}}', $WA_PATH)
  $html = $html.Replace('{{AR}}', $AR).Replace('{{LOGO}}', $LOGO).Replace('{{CHECK}}', $CHECK).Replace('{{PLUS}}', $PLUS).Replace('{{MINUS}}', $MINUS)
  $html = $html.Replace('{{Y}}', '<span class="y" role="img" aria-label="Included">&#9679;</span>').Replace('{{O}}', '<span class="o" role="img" aria-label="Optional or coordinated">&#9675;</span>').Replace('{{N}}', '<span class="n" role="img" aria-label="Not part of this package">&#8211;</span>')
  $html = $html.Replace('{{PROJECT_GRID}}', $grid.ToString()).Replace('{{PROJECT_CHIPS}}', $chips).Replace('{{PROJECT_TOTAL}}', [string]$Projects.Count).Replace('{{SITEMAP_PROJECTS}}', $smProjects)
  $html = [regex]::Replace($html, '\{\{([RCFPIST]\d\d)\}\}', { param($m) ImgPath $m.Groups[1].Value })
  $html
}
function Build-Page($file, $meta, $content) {
  $h = $head.Replace('{{TITLE}}', $meta.title).Replace('{{DESC}}', $meta.description).Replace('{{FILE}}', (Route $file).TrimStart('/'))
  $h = $h.Replace('{{OG}}', $(if ($meta.image) { $meta.image } else { '/assets/project-images/subha-infra-peb-structures-01.jpg' }).TrimStart('/'))
  $h = $h.Replace('{{BODYCLASS}}', [string]$meta.bodyclass).Replace('{{ROBOTS}}', $(if ($meta.robots) { $meta.robots } else { 'index, follow' }))
  $h = $h.Replace('{{SCHEMA}}', [string]$meta.schema)
  $hd = $header
  foreach ($k in 'home', 'about', 'services', 'projects', 'packages', 'team', 'insights', 'contact') {
    $hd = $hd.Replace("{{CUR_$k}}", $(if ($meta.nav -eq $k) { 'aria-current="page"' } else { '' }))
  }
  $out = Expand ($h + $hd + $content + $footer)
  $out = [regex]::Replace($out, ' >', '>').Replace('{{BASE}}', $Base)
  if ($Base) { $out = [regex]::Replace($out, '((?:href|src|action)=")/(?!/)', ('$1' + $Base + '/')) }
  if ($out -match '\{\{[A-Z_0-9]+\}\}') { throw "Unresolved token in ${file}: $($Matches[0])" }
  $route = Route $file
  $dir = Join-Path $root $route.Trim('/')
  New-Item -ItemType Directory -Force $dir | Out-Null
  Write-Text (Join-Path $dir 'index.html') $out
  if ($file -eq '404.html') { Write-Text (Join-Path $root '404.html') $out }
  [void]$legacy.Add(@($file, $route))
  if (-not $meta.robots) { [void]$built.Add($route) }
}

$orgSchema = '<script type="application/ld+json">{"@context":"https://schema.org","@type":"Organization","name":"SUBHA INFRA","slogan":"Designed to Inspire","url":"https://www.subhainfra.com/","logo":"https://www.subhainfra.com/assets/images/brand/subha-infra-logo.png","email":"info@subhainfra.com","telephone":"+91-7342494727","address":{"@type":"PostalAddress","addressLocality":"Sahakar Nagar, Bengaluru","addressRegion":"Karnataka","addressCountry":"IN"},"founder":{"@type":"Person","name":"Surya Prathap","jobTitle":"CEO & Founder"}}</script>'

Get-ChildItem "$B\pages\*.html" | ForEach-Object {
  $src = Read-Text $_.FullName
  $m = [regex]::Match($src, '^\s*<!--(.*?)-->', 'Singleline')
  $meta = @{}
  foreach ($line in $m.Groups[1].Value -split "`n") { if ($line -match '^\s*(\w+)\s*:\s*(.+?)\s*$') { $meta[$Matches[1]] = $Matches[2] } }
  if ($_.Name -eq 'index.html') { $meta.schema = $orgSchema }
  Build-Page $_.Name $meta $src.Substring($m.Length)
}

# ---------------- Project detail pages ----------------
$tpl = Read-Text "$B\templates\project.html"
for ($i = 0; $i -lt $Projects.Count; $i++) {
  $p = $Projects[$i]; $c = $cat[$p[4]]
  $prev = $Projects[($i - 1 + $Projects.Count) % $Projects.Count]; $next = $Projects[($i + 1) % $Projects.Count]
  $same = @($Projects | Where-Object { $_[4] -eq $p[4] -and $_[0] -ne $p[0] })
  if ($same.Count -lt 3) { $same += @($Projects | Where-Object { $_[3].Split(' ') -contains $c.filter -and $_[0] -ne $p[0] -and $same -notcontains $_ }) }
  if ($same.Count -lt 3) { $same += @($Projects | Where-Object { $_[0] -ne $p[0] -and $same -notcontains $_ } | Select-Object -First (3 - $same.Count)) }
  $gal = '<a class="img zoom" href="' + (ImgPath $p[0]) + '" data-lb="g" data-title="' + (Enc $p[2]) + '" data-cat="' + $c.label + '"><img data-project="' + $p[1] + '" src="' + (ImgPath $p[0]) + '" alt="' + (Enc $p[2]) + '" loading="lazy"></a>'
  foreach ($g in ($same | Select-Object -First 3)) {
    $gal += '<a class="img zoom" href="' + (ImgPath $g[0]) + '" data-lb="g" data-title="' + (Enc $g[2]) + '" data-cat="' + $cat[$g[4]].label + '"><img data-project="' + $g[1] + '" src="' + (ImgPath $g[0]) + '" alt="' + (Enc $g[2]) + '" loading="lazy"></a>'
  }
  $d = Dim $p[0]
  $body = $tpl.Replace('{{P_SLUG}}', $p[1]).Replace('{{P_PREV_SLUG}}', $prev[1]).Replace('{{P_NEXT_SLUG}}', $next[1]).Replace('{{P_TITLE}}', (Enc $p[2])).Replace('{{P_IMG}}', (ImgPath $p[0])).Replace('{{P_W}}', $d[0]).Replace('{{P_H}}', $d[1])
  $body = $body.Replace('{{P_CATLABEL}}', $c.label).Replace('{{P_FILTER}}', $c.filter).Replace('{{P_CODE}}', ('{0:D2}' -f ($i + 1))).Replace('{{P_STATUS}}', (Status $p))
  $body = $body.Replace('{{P_DISCLAIMER}}', (Disclaimer $p)).Replace('{{P_CONCEPT}}', (Enc $p[5])).Replace('{{P_OVERVIEW}}', $c.overview).Replace('{{P_STRUCT}}', $c.struct)
  $body = $body.Replace('{{P_SCOPE}}', (($c.scope | ForEach-Object { "<li>$_</li>" }) -join ''))
  $body = $body.Replace('{{P_MATERIALS}}', (($p[6].Split(';') | ForEach-Object { '<li>' + (Enc $_) + '</li>' }) -join ''))
  $body = $body.Replace('{{P_SERVICES}}', (($c.services | ForEach-Object { '<a class="btn btn-line btn-sm" href="' + $svc[$_][1] + '">' + $svc[$_][0] + '</a>' }) -join ''))
  $body = $body.Replace('{{P_GALLERY}}', $gal)
  $body = $body.Replace('{{P_PREV_HREF}}', "/projects/$($prev[1])/").Replace('{{P_PREV_IMG}}', (ImgPath $prev[0])).Replace('{{P_PREV_TITLE}}', (Enc $prev[2]))
  $body = $body.Replace('{{P_NEXT_HREF}}', "/projects/$($next[1])/").Replace('{{P_NEXT_IMG}}', (ImgPath $next[0])).Replace('{{P_NEXT_TITLE}}', (Enc $next[2]))
  $meta = @{ title = (Enc "$($p[2]) | $($c.label) | SUBHA INFRA"); description = (Enc ("$($p[2]): " + $p[5])); nav = 'projects'; image = (ImgPath $p[0]) }
  Build-Page "project-$($p[1]).html" $meta $body
}

# ---------------- sitemap.xml + robots.txt ----------------
$today = Get-Date -Format 'yyyy-MM-dd'
$xml = '<?xml version="1.0" encoding="UTF-8"?>' + "`n" + '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' + "`n"
foreach ($f in ($built | Sort-Object { if ($_ -eq '/') { ' ' } else { $_ } })) {
  $loc = $site + $f.TrimStart('/')
  $pri = if ($f -eq '/') { '1.0' } elseif ($f -like '/projects/?*') { '0.6' } else { '0.8' }
  $xml += "  <url><loc>$loc</loc><lastmod>$today</lastmod><priority>$pri</priority></url>`n"
}
$xml += '</urlset>' + "`n"
Write-Text (Join-Path $root 'sitemap.xml') $xml
Write-Text (Join-Path $root 'robots.txt') ("User-agent: *`nAllow: /`nDisallow: /_build/`n`nSitemap: ${site}sitemap.xml`n")
# ---------------- Routing / legacy redirects for each hosting platform ----------------
# Old flat .html URLs (and removed pages) permanently redirect to the clean folder URLs.
$moves = New-Object System.Collections.ArrayList
foreach ($l in $legacy) { if ($l[0] -ne '404.html') { [void]$moves.Add(@(('/' + $l[0]), $l[1])) } }
$gone = @('insights.html', 'insight-what-is-a-peb-structure.html', 'insight-peb-vs-conventional-steel.html', 'insight-structural-engineering-early.html',
  'insight-architectural-design-stages.html', 'insight-facade-materials-guide.html', 'insight-planning-industrial-building.html', 'insight-tensile-structures-guide.html')
foreach ($g in $gone) { [void]$moves.Add(@(('/' + $g), '/')) }
[void]$moves.Add(@('/service-bhutan-projects.html', '/services/'))
$assetMoves = @(@('/images/work/', '/assets/project-images/'), @('/images/interiors/', '/assets/service-images/interiors/'), @('/images/journey/', '/assets/service-images/journey/'),
  @('/images/brand/', '/assets/images/brand/'), @('/images/team/', '/assets/images/team/'), @('/style.css', '/css/style.css'), @('/main.js', '/js/main.js'), @('/site-config.js', '/js/site-config.js'))

# Apache / cPanel / LiteSpeed (.htaccess)
$ht = @"
# SUBHA INFRA - clean URLs (generated by _build/build.ps1; edit the build script, not this file)
Options -MultiViews -Indexes
DirectoryIndex index.html
DirectorySlash On
ErrorDocument 404 /404/index.html

<IfModule mod_rewrite.c>
RewriteEngine On

# Never serve the build sources
RewriteRule ^_build(/|$) - [F,L]

# /any/folder/index.html  ->  /any/folder/
RewriteCond %{THE_REQUEST} \s/+((?:[^\s?]*/)?)index\.html[\s?]
RewriteRule ^ /%1 [R=301,L]

# Legacy .html pages -> clean URLs

"@
foreach ($mv in $moves) { $ht += 'RewriteRule ^' + [regex]::Escape($mv[0].TrimStart('/')) + '$ ' + $mv[1] + " [R=301,L]`n" }
$ht += "`n# Legacy asset paths`n"
foreach ($a in $assetMoves) { $src = [regex]::Escape($a[0].TrimStart('/')); if ($a[0].EndsWith('/')) { $ht += "RewriteRule ^${src}(.*)$ $($a[1])`$1 [R=301,L]`n" } else { $ht += "RewriteRule ^${src}$ $($a[1]) [R=301,L]`n" } }
$ht += @"

# Any other *.html request -> extensionless folder URL (if that folder exists)
RewriteCond %{THE_REQUEST} \s/+([^\s?]+)\.html[\s?]
RewriteCond %{DOCUMENT_ROOT}/%1/index.html -f
RewriteRule ^ /%1/ [R=301,L]
</IfModule>

<IfModule mod_headers.c>
<FilesMatch "\.(jpg|jpeg|png|svg|webp|css|js)$">
Header set Cache-Control "public, max-age=2592000"
</FilesMatch>
</IfModule>
"@
Write-Text (Join-Path $root '.htaccess') $ht

# Netlify / Cloudflare Pages (_redirects)
$nr = "# SUBHA INFRA - generated by _build/build.ps1`n/_build/*  /404/  404`n"
foreach ($mv in $moves) { $nr += "$($mv[0])  $($mv[1])  301`n" }
foreach ($a in $assetMoves) { if ($a[0].EndsWith('/')) { $nr += "$($a[0])*  $($a[1]):splat  301`n" } else { $nr += "$($a[0])  $($a[1])  301`n" } }
Write-Text (Join-Path $root '_redirects') $nr

# Vercel (vercel.json)
$vr = @()
foreach ($mv in $moves) { $vr += ('    { "source": "' + $mv[0] + '", "destination": "' + $mv[1] + '", "permanent": true }') }
foreach ($a in $assetMoves) { if ($a[0].EndsWith('/')) { $vr += ('    { "source": "' + $a[0] + ':path*", "destination": "' + $a[1] + ':path*", "permanent": true }') } else { $vr += ('    { "source": "' + $a[0] + '", "destination": "' + $a[1] + '", "permanent": true }') } }
$vj = "{`n  `"cleanUrls`": true,`n  `"trailingSlash`": true,`n  `"redirects`": [`n" + ($vr -join ",`n") + "`n  ]`n}`n"
Write-Text (Join-Path $root 'vercel.json') $vj

"Built $($built.Count) indexable pages (+ 404) into $root; $($moves.Count) legacy redirects written"
