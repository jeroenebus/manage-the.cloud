<#
 Exports posts, pages and media from the WordPress REST API into Hugo content.
 Usage: pwsh scripts\Export-WordPress.ps1 [-Site https://manage-the.cloud]
 Re-runnable: overwrites generated files.
#>
param([string]$Site = 'https://manage-the.cloud')

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$siteHost = ([uri]$Site).Host

function Get-All($endpoint) {
    $page = 1; $all = @()
    do {
        $r = Invoke-WebRequest "$Site/wp-json/wp/v2/$endpoint$(if ($endpoint -match '\?') {'&'} else {'?'})per_page=100&page=$page" -UseBasicParsing
        $all += ($r.Content | ConvertFrom-Json)
        $total = [int](@($r.Headers['X-WP-TotalPages'])[0])
        $page++
    } while ($page -le $total)
    $all
}

function Save-Media($url) {
    $u = [uri]$url
    if ($u.Host -ne $siteHost -or $u.AbsolutePath -notlike '/wp-content/uploads/*') { return $url }
    $local = Join-Path $root ('static' + $u.AbsolutePath.Replace('/', '\'))
    if (-not (Test-Path $local)) {
        New-Item -ItemType Directory -Force (Split-Path $local) | Out-Null
        try { Invoke-WebRequest $url -OutFile $local -UseBasicParsing } catch { Write-Warning "Download failed: $url"; return $url }
    }
    $u.AbsolutePath
}

function Convert-ToMarkdown($html) {
    $h = $html -replace "`r", ''
    # drop WordPress plugin clutter (Easy TOC is replaced by Blowfish's own TOC)
    $h = $h -replace '(?is)<div[^>]*ez-toc-container.*?</nav>\s*</div>', ''
    $h = $h -replace '(?is)<svg.*?</svg>', ''
    $h = $h -replace '(?i)</?mark[^>]*>', ''
    $h = $h -replace '(?is)<button.*?</button>', ''
    # code blocks first, protect their content
    $script:blocks = @()
    $h = [regex]::Replace($h, '(?s)<pre[^>]*>\s*(?:<code[^>]*>)?(.*?)(?:</code>)?\s*</pre>', {
        param($m)
        $code = $m.Groups[1].Value -replace '<br\s*/?>', "`n" -replace '<[^>]+>', ''
        $code = [System.Net.WebUtility]::HtmlDecode($code).Trim("`n")
        $script:blocks += ,$code
        "`n`n@@CODE$($script:blocks.Count - 1)@@`n`n"
    })
    # code blocks restored at the end    # images (wrapped in figure/a or bare)
    $h = [regex]::Replace($h, '(?s)<a[^>]*>\s*(<img[^>]*>)\s*</a>', '$1')
    $h = [regex]::Replace($h, '(?i)<img[^>]*?>', {
        param($m)
        $t = $m.Value
        $src = [regex]::Match($t, '(?i)\ssrc="([^"]+)"').Groups[1].Value
        $alt = [regex]::Match($t, '(?i)\salt="([^"]*)"').Groups[1].Value
        "`n`n![$alt]($(Save-Media $src))`n`n"
    })
    $h = $h -replace '(?is)<figcaption[^>]*>(.*?)</figcaption>', "`n*`$1*`n"
    $h = $h -replace '(?i)</?figure[^>]*>', "`n"
    for ($i = 6; $i -ge 1; $i--) {
        $h = [regex]::Replace($h, "(?is)<h$i[^>]*>(.*?)</h$i>", { param($m) "`n`n$('#' * $i) $($m.Groups[1].Value.Trim())`n`n" })
    }
    $h = [regex]::Replace($h, '(?is)<(strong|b)>(.*?)</\1>', {
        param($m)
        $t = $m.Groups[2].Value
        if ($t.Trim() -eq '') { return $t }
        $lead = $t.Substring(0, $t.Length - $t.TrimStart().Length)
        $trail = $t.Substring($t.TrimEnd().Length)
        "$lead**$($t.Trim())**$trail"
    })
    $h = $h -replace '(?is)<(em|i)>(.*?)</\1>', '*$2*'
    $h = $h -replace '(?is)<code[^>]*>(.*?)</code>', '`$1`'
    $h = [regex]::Replace($h, '(?is)<a[^>]*?href="([^"]*)"[^>]*>(.*?)</a>', {
        param($m)
        $href = $m.Groups[1].Value
        if ($href -match "^https?://$([regex]::Escape($siteHost))/wp-content/uploads/") { $href = Save-Media $href }
        elseif ($href -match "^https?://$([regex]::Escape($siteHost))(/.*)$") { $href = $Matches[1] }
        "[$($m.Groups[2].Value)]($href)"
    })
    do { $prev = $h; $h = [regex]::Replace($h, '(?is)<li[^>]*>((?:(?!<li[ >]).)*?)</li>', { param($m) "`n- $($m.Groups[1].Value.Trim() -replace '\s*\n\s*',' ')" }) } while ($h -ne $prev)
    $h = $h -replace '(?i)</?(ul|ol)[^>]*>', "`n"
    $h = $h -replace '(?is)<blockquote[^>]*>(.*?)</blockquote>', { "`n`n> " + ($args[0].Groups[1].Value.Trim() -replace "`n", "`n> ") + "`n`n" }
    $h = $h -replace '(?i)<br\s*/?>', "  `n"
    $h = $h -replace '(?i)</p>', "`n`n"
    $h = $h -replace '(?i)<p[^>]*>', ''
    $h = $h -replace '(?s)<!--.*?-->', ''
    # leave tables / iframes / other structural HTML as-is (goldmark unsafe=true); strip wrappers only
    $h = $h -replace '(?i)</?(div|span|section)[^>]*>', ''
    $h = $h -replace '(?m)^[ \t]+$', ''
    $h = [regex]::Replace($h, "\n{3,}", "`n`n")
    $h = [System.Net.WebUtility]::HtmlDecode($h).Trim()
    $h = [regex]::Replace($h, '@@CODE(\d+)@@', { param($m) "```````n$($script:blocks[[int]$m.Groups[1].Value])`n``````" })
    $h
}

function Q($s) { '"' + ($s -replace '\\', '\\' -replace '"', '\"') + '"' }

# WordPress exports empty alt text; derive it from the sentence that introduces each image.
function Add-AltText([string]$md, [string]$fallback) {
    $known = @{ 'rxis3ZyU' = 'Portrait of Jeroen Ebus' }
    $ctx = $fallback; $n = 0; $inCode = $false
    $out = foreach ($line in ($md -split "`n")) {
        if ($line -match '^\s*```') { $inCode = -not $inCode; $line; continue }
        if ($inCode) { $line; continue }
        if ($line -match '^#{1,6}\s+(.+)$') { $ctx = ($Matches[1] -replace '[\*`_\[\]]', '').Trim(); $n = 0; $line; continue }
        if ($line -match '!\[\]\(([^)]*)\)') {
            $src = $Matches[1]
            $alt = $null
            foreach ($k in $known.Keys) { if ($src -like "*$k*") { $alt = $known[$k] } }
            if (-not $alt) { $n++; $alt = "Screenshot: $ctx"; if ($n -gt 1) { $alt += " (image $n)" } }
            $alt = $alt -replace '[\[\]\r\n]', ''
            [regex]::Replace($line, '!\[\]\(', "![$alt](")
            continue
        }
        if ($line.Trim()) {
            $t = [regex]::Replace($line, '\[([^\]]*)\]\([^)]*\)', '$1')
            $t = ($t -replace '^\s*([-*]|\d+\.)\s+', '' -replace '[\*`_]', '').Trim()
            $sentences = @($t -split '(?<=[.!?:])\s+' | ? { $_.Trim() })
            if ($sentences) {
                $s = $sentences[-1].Trim().TrimEnd(':', '.', ' ')
                if ($s.Length -gt 100) { $cut = $s.Substring(0, 100); $i = $cut.LastIndexOf(' '); if ($i -gt 20) { $cut = $cut.Substring(0, $i) }; $s = $cut + '…' }
                if ($s -and $s -notmatch '^https?://\S+$') { $ctx = $s; $n = 0 }
            }
        }
        $line
    }
    $out -join "`n"
}

$descriptions = @{}
$descFile = Join-Path $PSScriptRoot 'post-descriptions.json'
if (Test-Path $descFile) { (Get-Content $descFile -Raw -Encoding utf8 | ConvertFrom-Json).PSObject.Properties | % { $descriptions[$_.Name] = $_.Value } }

$cats = @{}; Get-All 'categories' | % { $cats[[int]$_.id] = $_.name }
$tags = @{}; Get-All 'tags' | % { $tags[[int]$_.id] = $_.name }

# Posts -> content/posts/<slug>/index.md
Get-All 'posts?_embed=wp:featuredmedia' | % {
    $p = $_
    $title = [System.Net.WebUtility]::HtmlDecode($p.title.rendered)
    $dir = Join-Path $root "content\posts\$($p.slug)"
    New-Item -ItemType Directory -Force $dir | Out-Null
    $fm = @('---', "title: $(Q $title)", "date: $(([datetime]$p.date).ToString('s'))", "lastmod: $(([datetime]$p.modified).ToString('s'))", "slug: $(Q $p.slug)")
    $c = @($p.categories | % { $cats[[int]$_] } | ? { $_ -and $_ -ne 'Uncategorized' })
    $t = @($p.tags | % { $tags[[int]$_] } | ? { $_ })
    if ($c) { $fm += 'categories: [' + (($c | % { Q $_ }) -join ', ') + ']' }
    if ($t) { $fm += 'tags: [' + (($t | % { Q $_ }) -join ', ') + ']' }
    $media = $p._embedded.'wp:featuredmedia'
    if ($media -and $media[0].source_url) {
        $img = Save-Media $media[0].source_url
        if ($img.StartsWith('/')) {
            $file = Join-Path $dir ('feature' + [IO.Path]::GetExtension($img))
            Copy-Item (Join-Path $root ('static' + $img.Replace('/', '\'))) $file -Force
        }
    }
    if ($descriptions.ContainsKey($p.slug)) { $fm += "description: $(Q $descriptions[$p.slug])" }
    $fm += '---'
    $body = Add-AltText (Convert-ToMarkdown $p.content.rendered) $title
    $body = $body -replace '(?<![\w*])(\*\*[^*\r\n]*?[^\s\u00A0])[\s\u00A0]+\*\*(?=\w)', '$1** '
    $body = $body -replace 'destination\*\*[\s\u00A0]*\*\*store\*\*', 'destination **store**' -replace 'destination \*\*store\*\*[\s\u00A0]+Computer certificate store – Root\*\*', 'destination store **Computer certificate store – Root**' -replace 'the\*\*[\s\u00A0]+Review \+ create[\s\u00A0]*\*\*[\s\u00A0]*section', 'the **Review + create** section'
    $body = $body.Replace('**app-scepman-**xxxxxxxxxxxxx', '**app-scepman-xxxxxxxxxxxxx**').Replace('Click on** OK**', 'Click on **OK**').Replace('used.** Update 21-09-2023:', 'used. **Update 21-09-2023:')
    Set-Content (Join-Path $dir 'index.md') (($fm -join "`n") + "`n`n$body`n") -Encoding utf8
    Write-Host "post: $($p.slug)"
}

# Pages -> content/<slug>.md
Get-All 'pages' | % {
    $p = $_
    if ($p.slug -eq 'privacy-policy') { return }
    $fm = @('---', "title: $(Q ([System.Net.WebUtility]::HtmlDecode($p.title.rendered)))", "date: $(([datetime]$p.date).ToString('s'))", "slug: $(Q $p.slug)", 'showDate: false', 'showReadingTime: false', '---')
    $body = Add-AltText (Convert-ToMarkdown $p.content.rendered) ([System.Net.WebUtility]::HtmlDecode($p.title.rendered))
    Set-Content (Join-Path $root "content\$($p.slug).md") (($fm -join "`n") + "`n`n$body`n") -Encoding utf8
    Write-Host "page: $($p.slug)"
}






