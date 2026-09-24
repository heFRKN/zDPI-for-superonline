# zDPI motoru (by FRKN)
# Tum .cmd dosyalari bu scripti cagirir. Dogrudan da kullanilabilir:
#   zdpi.ps1 -Action install [-Strategy N]   -> en iyi stratejiyi bulur, hizmet olarak kurar
#   zdpi.ps1 -Action run     [-Strategy N]   -> tek seferlik (pencere acik kaldikca) calistirir
#   zdpi.ps1 -Action menu                    -> strateji secici
#   zdpi.ps1 -Action uninstall               -> hizmeti ve ayarlari kaldirir
#   zdpi.ps1 -Action test                    -> baglanti testi
param(
    [ValidateSet('install','run','menu','uninstall','test')]
    [string]$Action = 'install',
    [int]$Strategy = 0
)

$ZdpiVersion = '2.1.0'
$ErrorActionPreference = 'Continue'
$CoreDir      = $PSScriptRoot
$RootDir      = Split-Path $CoreDir -Parent
$Curl         = Join-Path $env:SystemRoot 'System32\curl.exe'
$ServiceName  = 'zDPI'
$InstallCmd   = Join-Path $RootDir '1_HIZMETI_KUR_OTOMATIK.cmd'

# Guvenlik: hizmet SYSTEM yetkisiyle calistigi icin winws ve DLL'leri, yalnizca
# yoneticilerin yazabildigi Program Files altina kopyalanir ve oradan calistirilir.
# Kullanicinin yazabildigi indirme klasorunden SYSTEM olarak kod calistirilmaz.
# Durum dosyalari (secilen yontem, DNS kaydi) da ayni korumali klasorde tutulur.
$InstallDir   = Join-Path $env:ProgramFiles 'zDPI'
$Exe          = Join-Path $InstallDir 'winws.exe'
$StrategyFile = Join-Path $InstallDir 'strateji.txt'
$DnsMarker    = Join-Path $InstallDir 'dns_degisti.txt'

# Paketteki ikili dosyalarin SHA256 ozetleri. Dosyalar degistirilmisse kurulum yapilmaz.
# Dordu de resmi zapret v72.13 surumunun binaries/windows-x86_64 klasoruyle birebir aynidir:
# https://github.com/bol-van/zapret/releases/tag/v72.13 (sha256sum.txt)
# WinDivert.dll / WinDivert64.sys ayrica resmi WinDivert 2.2.2 (basil00) ile aynidir.
$Binaries = [ordered]@{
    'winws.exe'       = 'A14BFF1DF6234EA555D2E0C61B589F0707C0B12D6C9B7EECCDA76012154996E8'
    'cygwin1.dll'     = '103104A52E5293CE418944725DF19E2BF81AD9269B9A120D71D39028E821499B'
    'WinDivert.dll'   = 'C1E060EE19444A259B2162F8AF0F3FE8C4428A1C6F694DCE20DE194AC8D7D9A2'
    'WinDivert64.sys' = '8DA085332782708D8767BCACE5327A6EC7283C17CFB85E40B03CD2323A90DDC2'
}

# Ayni WinDivert surucusunu kullanan ve zDPI ile cakisan hizmetler/surecler.
# NOT: "WinDivert" surucu hizmetine ASLA dokunulmaz. Kullanimdayken silinirse
# surucu STOP_PENDING durumunda takilir ve yeniden baslatana kadar hicbir
# DPI araci (zDPI, SplitWire, GoodbyeDPI) calisamaz.
$ConflictServices = 'zDPI','zDPI_Service','FailureStudioDPI','ZapretSuperonline','zapret','winws1','winws2','GoodbyeDPI'
$ConflictProcs    = 'winws','goodbyedpi'

$TestUrls = 'https://discord.com','https://gateway.discord.gg','https://cdn.discordapp.com'

# UDP kismi her stratejide ayni: Discord ses (STUN/RTC) ve QUIC.
# Sadece Discord ses paketleri ve QUIC el sikismasi islenir, oyun trafigine dokunulmaz.
$BaseArgs = '--wf-tcp=80,443 --wf-udp=443,19294-19344,50000-50100 ' +
            '--filter-udp=443 --filter-l7=quic --dpi-desync=fake --dpi-desync-repeats=6 --new ' +
            '--filter-udp=19294-19344,50000-50100 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-repeats=6 --new ' +
            '--filter-tcp=80,443 '

# TCP (web/Discord) stratejileri. Otomatik modda bu sirayla denenir, ilk calisan secilir.
$Strategies = @(
    @{ Name = 'Standart (fake+split, autottl, md5sig)';        Args = '--dpi-desync=fake,multisplit --dpi-desync-split-pos=1 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --dpi-desync-repeats=6' }
    @{ Name = 'Superonline Klasik (fake, md5sig)';             Args = '--dpi-desync=fake --dpi-desync-fooling=md5sig' }
    @{ Name = 'Superonline TTL 3 (fake, md5sig)';              Args = '--dpi-desync=fake --dpi-desync-fooling=md5sig --dpi-desync-ttl=3' }
    @{ Name = 'Fake+Split (badseq)';                           Args = '--dpi-desync=fake,multisplit --dpi-desync-split-pos=1 --dpi-desync-fooling=badseq --dpi-desync-repeats=6' }
    @{ Name = 'Agresif Fake+Disorder (badseq)';                Args = '--dpi-desync=fake,multidisorder --dpi-desync-split-pos=1,midsld --dpi-desync-fooling=badseq --dpi-desync-repeats=6' }
    @{ Name = 'Seqovl Split';                                  Args = '--dpi-desync=multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1' }
    @{ Name = 'Fake TTL 3';                                    Args = '--dpi-desync=fake --dpi-desync-ttl=3' }
    @{ Name = 'Fake TTL 4 (Turkcell fiber/VDSL)';              Args = '--dpi-desync=fake --dpi-desync-ttl=4' }
    @{ Name = 'Fake+Split TTL 5 (GoodbyeDPI -5 benzeri)';      Args = '--dpi-desync=fake,multisplit --dpi-desync-split-pos=2 --dpi-desync-ttl=5' }
    @{ Name = 'Disorder (fake paketsiz)';                      Args = '--dpi-desync=multidisorder --dpi-desync-split-pos=1,midsld' }
    @{ Name = 'SNI Split (fake paketsiz)';                     Args = '--dpi-desync=multisplit --dpi-desync-split-pos=1,sniext+1' }
    @{ Name = 'FakedSplit (badseq)';                           Args = '--dpi-desync=fakedsplit --dpi-desync-split-pos=1 --dpi-desync-fooling=badseq' }
    @{ Name = 'Fake TLS Mod (badseq)';                         Args = '--dpi-desync=fake --dpi-desync-fooling=badseq --dpi-desync-repeats=6 --dpi-desync-fake-tls-mod=rnd,dupsid,sni=www.google.com' }
)

function Say([string]$m, [string]$c = 'Gray') { Write-Host $m -ForegroundColor $c }

function Show-Header([string]$title) {
    Write-Host ''
    Write-Host '=======================================================================' -ForegroundColor Cyan
    Write-Host ("  zDPI - " + $title) -ForegroundColor Cyan
    Write-Host ("                         v" + $ZdpiVersion + "  by FRKN") -ForegroundColor DarkCyan
    Write-Host '=======================================================================' -ForegroundColor Cyan
    Write-Host ''
}

function Get-FullArgs([int]$idx) { return $BaseArgs + $Strategies[$idx - 1].Args }

function Get-SavedStrategy {
    # v2.0.0 yontemi core\strateji.txt'ye yaziyordu; yeni konumda yoksa oradan okunur.
    foreach ($f in $StrategyFile, (Join-Path $CoreDir 'strateji.txt')) {
        try {
            $n = [int](Get-Content $f -ErrorAction Stop | Select-Object -First 1)
            if ($n -ge 1 -and $n -le $Strategies.Count) { return $n }
        } catch {}
    }
    return 0
}

function Test-FileHash([string]$path, [string]$expected) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $false }
    return ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -eq $expected)
}

# Paketteki ikili dosyalari dogrular ve korumali kurulum klasorune kopyalar.
function Install-Binaries {
    Say '[*] Dosyalar dogrulaniyor ve korumali klasore kopyalaniyor...'
    foreach ($name in $Binaries.Keys) {
        if (-not (Test-FileHash (Join-Path $CoreDir $name) $Binaries[$name])) {
            Say ("    [-] core\$name eksik, bozuk veya degistirilmis!") Red
            Say  '        Guvenlik icin kurulum durduruldu. Programi GitHub Releases sayfasindan yeniden indirin.' Yellow
            return $false
        }
    }
    try {
        New-Item -ItemType Directory -Path $InstallDir -Force -ErrorAction Stop | Out-Null
        # Program Files'in varsayilan izinlerine don: yalnizca yoneticiler ve SYSTEM yazabilir
        icacls.exe $InstallDir /reset /T /Q | Out-Null
        foreach ($name in $Binaries.Keys) {
            $dst = Join-Path $InstallDir $name
            if (Test-FileHash $dst $Binaries[$name]) { continue }
            Copy-Item -LiteralPath (Join-Path $CoreDir $name) -Destination $dst -Force -ErrorAction Stop
        }
    } catch {
        Say ("    [-] Kurulum klasorune kopyalanamadi: " + $_.Exception.Message) Red
        return $false
    }
    # Kopyalama sirasinda araya girilmediginden emin olmak icin hedefte tekrar dogrula
    foreach ($name in $Binaries.Keys) {
        if (-not (Test-FileHash (Join-Path $InstallDir $name) $Binaries[$name])) {
            Say ("    [-] $InstallDir\$name dogrulanamadi.") Red
            return $false
        }
    }
    Say ("    [+] Dosyalar dogrulandi: " + $InstallDir) Green
    return $true
}

# ---------------------------------------------------------------- temizlik

function Stop-Conflicts([switch]$DeleteServices) {
    foreach ($s in $ConflictServices) {
        if (Get-Service -Name $s -ErrorAction SilentlyContinue) {
            sc.exe stop $s 2>&1 | Out-Null
            if ($DeleteServices) { sc.exe delete $s 2>&1 | Out-Null }
        }
    }
    foreach ($t in 'zDPI','zDPI_Autostart') { schtasks.exe /Delete /TN $t /F 2>&1 | Out-Null }
    Get-Process -Name $ConflictProcs -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    # Surecler kapanip WinDivert tutamaclari birakilana kadar bekle
    for ($i = 0; $i -lt 20 -and (Get-Process -Name $ConflictProcs -ErrorAction SilentlyContinue); $i++) {
        Start-Sleep -Milliseconds 250
    }
}

# ---------------------------------------------------------------- WinDivert

function Test-WinDivertStuck {
    $q = sc.exe query WinDivert 2>&1 | Out-String
    return ($q -match 'STOP_PENDING')
}

function Request-Reboot {
    Say ''
    Say '  [!] WinDivert surucusu bozuk/takili durumda (STOP_PENDING).' Red
    Say '      Eski surumdeki hatali temizleme bunu yapiyordu. Bu durumda' Red
    Say '      zDPI, SplitWire ve GoodbyeDPI dahil HICBIR arac calisamaz.' Red
    Say '      Tek cozum bilgisayari YENIDEN BASLATMAK.' Yellow
    Say ''
    Say '      Yeniden baslattiktan sonra kurulum OTOMATIK olarak devam edecek.' Yellow
    Say ''
    try {
        New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name 'zDPI_Kurulum' `
            -Value ('"' + $InstallCmd + '"') -PropertyType String -Force | Out-Null
    } catch {}
    $ans = Read-Host '  Simdi yeniden baslatilsin mi? (E/H)'
    if ($ans -match '^[eEyY]') {
        Say '  [*] 5 saniye icinde yeniden baslatiliyor...' Yellow
        shutdown.exe /r /t 5 /c "zDPI: WinDivert surucusunu onarmak icin yeniden baslatiliyor"
    } else {
        Say '  [*] Tamam. Bir sonraki acilista kurulum otomatik baslayacak.' Yellow
    }
}

# ---------------------------------------------------------------- DNS

function Test-DnsOk {
    # Discord Cloudflare uzerinde (162.159.x.x). Zehirlenmis DNS baska/bos adres dondurur.
    try {
        $ips = Resolve-DnsName -Name discord.com -Type A -DnsOnly -QuickTimeout -ErrorAction Stop |
               Where-Object { $_.Type -eq 'A' } | ForEach-Object { $_.IPAddress }
        return [bool]($ips | Where-Object { $_ -like '162.159.*' })
    } catch { return $false }
}

function Enable-SecureDns {
    # Windows 11 yerlesik DoH: Cloudflare DNS'e sifreli baglanir, Superonline
    # 53. port mudahalesinden etkilenmez. Tum aktif adaptorlere uygulanir.
    $servers = '1.1.1.1','1.0.0.1'
    foreach ($s in $servers) {
        try {
            if (Get-DnsClientDohServerAddress -ServerAddress $s -ErrorAction SilentlyContinue) {
                Set-DnsClientDohServerAddress -ServerAddress $s -DohTemplate 'https://cloudflare-dns.com/dns-query' -AutoUpgrade $true -AllowFallbackToUdp $false -ErrorAction Stop | Out-Null
            } else {
                Add-DnsClientDohServerAddress -ServerAddress $s -DohTemplate 'https://cloudflare-dns.com/dns-query' -AutoUpgrade $true -AllowFallbackToUdp $false -ErrorAction Stop | Out-Null
            }
        } catch {}
    }
    $changed = @()
    $adapters = Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object Status -eq 'Up'
    foreach ($a in $adapters) {
        Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ServerAddresses $servers -ErrorAction SilentlyContinue
        foreach ($s in $servers) {
            $k = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\$($a.InterfaceGuid)\DohInterfaceSettings\Doh\$s"
            try {
                New-Item -Path $k -Force -ErrorAction Stop | Out-Null
                New-ItemProperty -Path $k -Name 'DohFlags' -Value 1 -PropertyType QWord -Force -ErrorAction Stop | Out-Null
            } catch {}
        }
        $changed += $a.InterfaceGuid
    }
    if ($changed) { $changed | Set-Content -Path $DnsMarker -Encoding ASCII }
    ipconfig.exe /flushdns | Out-Null
    Start-Sleep -Seconds 1
}

function Restore-Dns {
    # v2.0.0 kaydi core\ altinda tutuyordu; o da okunur.
    $markers = @($DnsMarker, (Join-Path $CoreDir 'dns_degisti.txt')) | Where-Object { Test-Path -LiteralPath $_ }
    if (-not $markers) { return }
    foreach ($m in $markers) {
        foreach ($line in Get-Content -LiteralPath $m) {
            # Yalnizca gecerli bir adaptor GUID'i kabul edilir. Dosyaya yazilmis baska bir deger
            # ile registry'de yetkili (recurse) silme yapilmasini onler.
            $guid = $line.Trim()
            if ($guid -notmatch '^\{[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}\}$') { continue }
            $a = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object InterfaceGuid -eq $guid
            if ($a) { Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ResetServerAddresses -ErrorAction SilentlyContinue }
            Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\$guid\DohInterfaceSettings" -Recurse -Force -ErrorAction SilentlyContinue
        }
        Remove-Item -LiteralPath $m -Force -ErrorAction SilentlyContinue
    }
    foreach ($s in '1.1.1.1','1.0.0.1') {
        Set-DnsClientDohServerAddress -ServerAddress $s -AutoUpgrade $false -AllowFallbackToUdp $false -ErrorAction SilentlyContinue | Out-Null
    }
    ipconfig.exe /flushdns | Out-Null
    Say '  [+] DNS ayarlari varsayilana (DHCP) donduruldu.' Green
}

function Ensure-Dns {
    Say '[*] DNS kontrol ediliyor...'
    if (Test-DnsOk) { Say '    [+] DNS saglam (discord.com dogru adrese cozuluyor).' Green; return }
    Say '    [!] DNS engelli/zehirli. Sifreli DNS (DoH - Cloudflare) aciliyor...' Yellow
    Enable-SecureDns
    if (Test-DnsOk) { Say '    [+] Sifreli DNS aktif, discord.com artik dogru cozuluyor.' Green }
    else { Say '    [-] DNS hala dogru cozmuyor. Yine de devam ediliyor.' Red }
}

# ---------------------------------------------------------------- baglanti testi

function Test-Url([string]$u) {
    & $Curl -s -o NUL --connect-timeout 4 -m 7 $u 2>$null
    return ($LASTEXITCODE -eq 0)
}

function Test-Discord {
    foreach ($u in $TestUrls) { if (-not (Test-Url $u)) { return $false } }
    return $true
}

# ---------------------------------------------------------------- strateji

# Stratejiyi gecici olarak calistirip Discord'a erisilebiliyor mu bakar.
# Donus: 'ok' | 'fail' | 'driver' (winws baslayamadi)
function Try-Strategy([int]$idx) {
    # Hata ciktisi korumali klasore yazilir (kullanicinin %TEMP%'ine yonetici olarak
    # sabit isimli dosya yazmak sembolik link saldirisina acik olurdu).
    $err = Join-Path $InstallDir 'winws_hata.txt'
    $p = Start-Process -FilePath $Exe -ArgumentList (Get-FullArgs $idx) -WorkingDirectory $InstallDir `
         -WindowStyle Hidden -PassThru -RedirectStandardError $err
    Start-Sleep -Milliseconds 1500
    if ($p.HasExited) {
        $script:LastWinwsError = (Get-Content $err -Raw -ErrorAction SilentlyContinue)
        return 'driver'
    }
    $ok = Test-Discord
    Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
    $p.WaitForExit(3000) | Out-Null
    Start-Sleep -Milliseconds 400
    if ($ok) { return 'ok' } else { return 'fail' }
}

# Calisan stratejiyi bulur. Once kayitli olani, sonra hepsini sirayla dener.
function Find-Strategy {
    $order = @()
    $saved = Get-SavedStrategy
    if ($saved) { $order += $saved }
    $order += (1..$Strategies.Count | Where-Object { $_ -ne $saved })

    Say '[*] Superonline hattinda calisan yontem araniyor (1-2 dakika surebilir)...'
    $n = 0
    foreach ($i in $order) {
        $n++
        Write-Host ("    [{0,2}/{1}] {2,-45} " -f $n, $order.Count, $Strategies[$i - 1].Name) -NoNewline
        $r = Try-Strategy $i
        switch ($r) {
            'ok'     { Write-Host 'CALISIYOR' -ForegroundColor Green; return $i }
            'fail'   { Write-Host 'olmadi' -ForegroundColor DarkGray }
            'driver' {
                Write-Host 'HATA' -ForegroundColor Red
                if (Test-WinDivertStuck) { return -1 }
                Say ("    winws hatasi: " + $script:LastWinwsError) Red
                return -2
            }
        }
    }
    return 0
}

# ---------------------------------------------------------------- Discord

function Restart-Discord {
    $procs = Get-Process -Name Discord, DiscordCanary, DiscordPTB -ErrorAction SilentlyContinue
    if (-not $procs) { return }
    Say '[*] Discord yeniden baslatiliyor...'
    $procs | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    # Discord yonetici olarak acilmasin diye explorer uzerinden (normal kullanici) baslatilir
    $lnk = Get-ChildItem "$env:APPDATA\Microsoft\Windows\Start Menu\Programs" -Recurse -Filter 'Discord.lnk' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($lnk) { Start-Process explorer.exe -ArgumentList ('"' + $lnk.FullName + '"') }
    else { Say '    Discord kapatildi, lutfen tekrar acin.' Yellow }
}

# ---------------------------------------------------------------- eylemler

function Resolve-StrategyOrExit([int]$requested) {
    if ($requested -ge 1 -and $requested -le $Strategies.Count) {
        Say ("[*] Secilen yontem: " + $Strategies[$requested - 1].Name)
        if (Test-WinDivertStuck) { Request-Reboot; return 0 }
        return $requested
    }
    if (Test-Discord) {
        Say '[*] Discord su an zaten erisilebilir durumda. Varsayilan yontem kullanilacak.' Yellow
        if (Test-WinDivertStuck) { Request-Reboot; return 0 }
        $s = Get-SavedStrategy
        if ($s) { return $s } else { return 1 }
    }
    $idx = Find-Strategy
    if ($idx -eq -1) { Request-Reboot; return 0 }
    if ($idx -le 0) {
        Say ''
        if ($idx -eq 0) {
            Say '  [-] Hicbir yontem Discord''u acamadi.' Red
            Say '      - Baska bir VPN / DPI programi (SplitWire, WARP, Proton vb.) aciksa kapatin.' Yellow
            Say '      - Modem uzerinden Superonline "Guvenli Internet" kapali olmali.' Yellow
            Say '      - Birkac dakika sonra tekrar deneyin.' Yellow
        }
        return 0
    }
    Set-Content -Path $StrategyFile -Value $idx -Encoding ASCII
    return $idx
}

function Do-Install([int]$requested) {
    Show-Header 'OTOMATIK HIZMET KURULUMU'
    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name 'zDPI_Kurulum' -ErrorAction SilentlyContinue

    Say '[*] Eski hizmetler ve cakisan DPI programlari kaldiriliyor...'
    Stop-Conflicts -DeleteServices
    if (-not (Install-Binaries)) { return }
    Ensure-Dns

    $idx = Resolve-StrategyOrExit $requested
    if ($idx -le 0) { return }
    if ($requested -ge 1) { Set-Content -Path $StrategyFile -Value $idx -Encoding ASCII }

    Say '[*] zDPI hizmeti kuruluyor...'
    $bin = '"' + $Exe + '" ' + (Get-FullArgs $idx)
    try {
        New-Service -Name $ServiceName -BinaryPathName $bin -DisplayName 'zDPI Bypass Service' `
            -Description ('zDPI Bypass Engine by FRKN - ' + $Strategies[$idx - 1].Name) `
            -StartupType Automatic -ErrorAction Stop | Out-Null
    } catch {
        Say ("    [-] Hizmet olusturulamadi: " + $_.Exception.Message) Red
        return
    }
    # Cokerse 5 sn sonra kendini yeniden baslatsin
    sc.exe failure $ServiceName reset= 86400 actions= restart/5000/restart/5000/restart/10000 | Out-Null
    Start-Service -Name $ServiceName -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    $svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if (-not $svc -or $svc.Status -ne 'Running') {
        Say '    [-] Hizmet baslatilamadi.' Red
        if (Test-WinDivertStuck) { Request-Reboot }
        return
    }
    Say '    [+] Hizmet calisiyor ve Windows acilisinda otomatik baslayacak.' Green

    Say '[*] Son kontrol yapiliyor...'
    $ok = Test-Discord
    Restart-Discord

    Write-Host ''
    Write-Host '=======================================================================' -ForegroundColor Cyan
    if ($ok) {
        Say '                  KURULUM BASARIYLA TAMAMLANDI!' Green
        Write-Host '=======================================================================' -ForegroundColor Cyan
        Say ("  Yontem : " + $Strategies[$idx - 1].Name)
        Say  '  - zDPI arka planda sessizce calisiyor.'
        Say  '  - Bilgisayar her acildiginda otomatik baslar.'
        Say  '  - Discord (ses kanallari dahil) ve engelli siteler acik.'
    } else {
        Say '  Hizmet kuruldu ama Discord testi basarisiz oldu.' Yellow
        Write-Host '=======================================================================' -ForegroundColor Cyan
        Say '  3_ALTERNATIF_MOD_SECICI ile farkli bir yontem deneyin.' Yellow
    }
    Write-Host ''
}

function Do-Run([int]$requested) {
    Show-Header 'TEK SEFERLIK MOD (DISCORD VE YASAKLI SITELER)'
    Say '[*] Calisan zDPI / cakisan programlar durduruluyor...'
    Stop-Conflicts
    if (-not (Install-Binaries)) { return }
    Ensure-Dns

    $idx = Resolve-StrategyOrExit $requested
    if ($idx -le 0) { return }

    Write-Host ''
    Write-Host '=======================================================================' -ForegroundColor Cyan
    Say ("  [+] zDPI TEK SEFERLIK MOD AKTIF - " + $Strategies[$idx - 1].Name) Green
    Say  '  [+] Bu pencere ACIK KALDIGI SURECE Discord ve engelli siteler aciktir.'
    Say  '  [!] Kapatmak icin pencereyi kapatin veya Ctrl+C yapin.' Yellow
    Say  '  [i] Not: Kurulu zDPI hizmeti durduruldu; bilgisayar yeniden' DarkGray
    Say  '      acildiginda (kuruluysa) tekrar kendiliginden baslar.' DarkGray
    Write-Host '=======================================================================' -ForegroundColor Cyan
    Write-Host ''
    Push-Location $InstallDir
    & $Exe ((Get-FullArgs $idx) -split ' ')
    Pop-Location
    Say '[*] zDPI durduruldu.'
}

function Do-Uninstall {
    Show-Header 'SISTEM TEMIZLEYICI'
    Say '[*] zDPI hizmeti ve eski gorevler kaldiriliyor...'
    Stop-Conflicts -DeleteServices
    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name 'zDPI_Kurulum' -ErrorAction SilentlyContinue
    Restore-Dns
    if (Test-Path -LiteralPath $InstallDir) {
        Remove-Item -LiteralPath $InstallDir -Recurse -Force -ErrorAction SilentlyContinue
        if (Test-Path -LiteralPath $InstallDir) { Say ("  [i] " + $InstallDir + " yeniden baslatinca silinebilir (surucu kullanimda).") DarkGray }
        else { Say ("  [+] " + $InstallDir + " kaldirildi.") Green }
    }
    ipconfig.exe /flushdns | Out-Null
    Write-Host ''
    Say '=======================================================================' Cyan
    Say '                 TUM SISTEMLER BASARIYLA TEMIZLENDI!' Green
    Say '=======================================================================' Cyan
}

function Do-Test {
    Show-Header 'BAGLANTI TESTI'
    $svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($svc) { Say ("  Hizmet   : " + $svc.Status) $(if ($svc.Status -eq 'Running') { 'Green' } else { 'Red' }) }
    else      { Say  '  Hizmet   : Kurulu degil' Yellow }
    $running = [bool](Get-Process winws -ErrorAction SilentlyContinue)
    Say ("  winws    : " + $(if ($running) { 'Calisiyor' } else { 'Calismiyor' })) $(if ($running) { 'Green' } else { 'Red' })
    $s = Get-SavedStrategy
    if ($s) { Say ("  Yontem   : " + $Strategies[$s - 1].Name) }
    if (Test-DnsOk) { Say '  DNS      : Saglam' Green } else { Say '  DNS      : Engelli / zehirli' Red }
    if (Test-WinDivertStuck) { Say '  WinDivert: TAKILI - bilgisayari yeniden baslatin!' Red }
    Write-Host ''
    foreach ($u in $TestUrls + 'https://discordapp.com') {
        Write-Host ("  {0,-32} " -f $u) -NoNewline
        if (Test-Url $u) { Write-Host 'ERISILEBILIR' -ForegroundColor Green } else { Write-Host 'ERISILEMEDI' -ForegroundColor Red }
    }
    Write-Host ''
}

function Do-Menu {
    while ($true) {
        Clear-Host
        Show-Header 'ALTERNATIF MOD SECICI'
        Say '  [A] OTOMATIK: Calisan yontemi kendin bul ve hizmet olarak kur (Onerilen)' Green
        Write-Host ''
        $saved = Get-SavedStrategy
        for ($i = 1; $i -le $Strategies.Count; $i++) {
            $mark = if ($i -eq $saved) { '  <- su an secili' } else { '' }
            Say ("  [{0,2}] {1}{2}" -f $i, $Strategies[$i - 1].Name, $mark)
        }
        Write-Host ''
        Say '  [T] Hizmeti kaldir / temizle     [B] Baglanti testi     [Q] Cikis'
        Write-Host ''
        $c = (Read-Host '  Seciminiz').Trim()
        if ($c -match '^[qQ]$') { return }
        if ($c -match '^[aA]$') { Do-Install 0; Read-Host '  Devam icin Enter' | Out-Null; continue }
        if ($c -match '^[tT]$') { Do-Uninstall; Read-Host '  Devam icin Enter' | Out-Null; continue }
        if ($c -match '^[bB]$') { Do-Test; Read-Host '  Devam icin Enter' | Out-Null; continue }
        $n = 0
        if (-not [int]::TryParse($c, [ref]$n) -or $n -lt 1 -or $n -gt $Strategies.Count) { continue }
        Write-Host ''
        Say ("  Secilen: " + $Strategies[$n - 1].Name) Cyan
        Say '  [1] Hizmet olarak kur (acilista otomatik)   [2] Tek seferlik dene   [3] Geri'
        $a = (Read-Host '  Seciminiz').Trim()
        if ($a -eq '1') { Do-Install $n; Read-Host '  Devam icin Enter' | Out-Null }
        elseif ($a -eq '2') { Do-Run $n; Read-Host '  Devam icin Enter' | Out-Null }
    }
}

switch ($Action) {
    'install'   { Do-Install $Strategy }
    'run'       { Do-Run $Strategy }
    'menu'      { Do-Menu }
    'uninstall' { Do-Uninstall }
    'test'      { Do-Test }
}
