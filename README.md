<div align="center">

# ⚡ zDPI for Superonline

**Discord ve engelli siteler için tek tıkla DPI bypass — VPN değil, ping'e etkisi yok.**

[![Platform](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?style=flat-square&logo=windows&logoColor=white)](#-gereksinimler)
[![ISP](https://img.shields.io/badge/ISP-Turkcell%20Superonline-FFC900?style=flat-square)](#-nasıl-çalışır)
[![Engine](https://img.shields.io/badge/engine-zapret%20winws-2EA043?style=flat-square)](https://github.com/bol-van/zapret)
[![Release](https://img.shields.io/github/v/release/heFRKN/zDPI-for-superonline?style=flat-square&label=release)](https://github.com/heFRKN/zDPI-for-superonline/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/heFRKN/zDPI-for-superonline/total?style=flat-square)](https://github.com/heFRKN/zDPI-for-superonline/releases)
[![License](https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square)](LICENSE)

**[⬇️ İndir](https://github.com/heFRKN/zDPI-for-superonline/releases/latest)** •
[Hızlı Başlangıç](#-hızlı-başlangıç) •
[Dosyalar](#-dosyalar) •
[Nasıl Çalışır](#-nasıl-çalışır) •
[Sorun Giderme](#-sorun-giderme) •
[English](#-english)

</div>

---

## ✨ Özellikler

| | |
| :-- | :-- |
| 🔍 **Otomatik yöntem bulma** | Kurulum 13 farklı bypass yöntemini hattınızda gerçek bağlantıyla test eder, çalışanı kurar. Elle ayar denemek yok. |
| 🎙️ **Discord ses dahil** | Metin, medya ve ses kanalları (RTC / STUN) açılır. |
| 🎮 **Oyunlara dokunmaz** | VPN değildir, trafiğinizi başka yere yönlendirmez. Sadece HTTPS el sıkışması ve Discord ses paketleri işlenir; oyun trafiği olduğu gibi geçer. |
| 🔐 **Akıllı DNS** | DNS engelliyse Windows'un yerleşik şifreli DNS'ini (DoH, Cloudflare) açar. Zaten çalışan bir DNS'e (ör. dnscrypt) dokunmaz. |
| 🔁 **Kur ve unut** | Windows hizmeti olarak açılışta sessizce başlar; çökerse kendini yeniden başlatır. |
| 🧹 **Temiz kaldırma** | Tek tıkla hizmeti ve yapılan DNS değişikliklerini geri alır. |

## 🚀 Hızlı Başlangıç

1. **[Son sürümü indirin](https://github.com/heFRKN/zDPI-for-superonline/releases/latest)** (`zDPI-vX.X.X.zip`) ve bir klasöre çıkartın.
2. **`1_HIZMETI_KUR_OTOMATIK.cmd`** dosyasına çift tıklayın, yönetici iznine **Evet** deyin.
3. 1-2 dakika bekleyin. Program çalışan yöntemi bulup kuracak. Hepsi bu. ✅

> [!TIP]
> Kurulumdan sonra klasörü silmeyin veya taşımayın; hizmet dosyaları oradan çalıştırır.
> Taşımak isterseniz önce `4_HIZMETI_KALDIR_TEMIZLE.cmd`, sonra yeni yerde tekrar `1_...` çalıştırın.

## 📁 Dosyalar

| Dosya | Ne yapar |
| :-- | :-- |
| **`1_HIZMETI_KUR_OTOMATIK.cmd`** | ⭐ *Önerilen.* Çalışan yöntemi bulur ve Windows hizmeti olarak kurar. |
| `2_TEK_SEFERLIK_BASLAT_DISCORD_VE_YASAKLI_SITELER.cmd` | Hizmet kurmadan çalıştırır. Pencere açık kaldığı sürece aktif. |
| `3_ALTERNATIF_MOD_SECICI.cmd` | 13 yöntemden birini elle seçip kurmak veya denemek için menü. |
| `4_HIZMETI_KALDIR_TEMIZLE.cmd` | Hizmeti kaldırır, DNS değişikliklerini geri alır. |
| `5_BAGLANTI_TESTI.cmd` | Hizmet, DNS ve Discord erişim durumunu gösterir. |

Tüm `.cmd` dosyaları çift tıklamayla otomatik olarak yönetici izni ister; sağ tıklamaya gerek yoktur.

## ⚙️ Nasıl Çalışır

Superonline, Discord gibi siteleri HTTPS bağlantısının ilk paketindeki alan adına (SNI) bakarak engeller:
bağlantı kurulurken araya girip `RST` paketi gönderir ve bağlantı düşer. zDPI, [zapret](https://github.com/bol-van/zapret)
projesinin `winws` motorunu kullanarak bu ilk paketi DPI cihazının okuyamayacağı hale getirir: paketi böler,
sırasını değiştirir veya önüne sunucunun yok sayacağı sahte paketler ekler. Sunucu isteği normal şekilde alır,
ama araya giren cihaz neye bağlanıldığını anlayamaz.

Kurulum sırasında şu adımlar izlenir:

```
Cakisan servisleri durdur  →  DNS'i kontrol et (gerekirse DoH ac)  →  13 yontemi sirayla dene
        →  discord.com / gateway.discord.gg / cdn.discordapp.com'a baglan
        →  ilk calisan yontemi "zDPI" hizmeti olarak kur  →  son test
```

Seçilen yöntem `core/strateji.txt` dosyasına kaydedilir ve bir sonraki kurulumda ilk olarak o denenir.

<details>
<summary><b>Denenen yöntemler (sırasıyla)</b></summary>

| # | Yöntem | winws parametreleri |
| --: | :-- | :-- |
| 1 | Standart | `fake,multisplit` · `split-pos=1` · `autottl=2` · `md5sig` |
| 2 | Superonline Klasik | `fake` · `md5sig` |
| 3 | Superonline TTL 3 | `fake` · `md5sig` · `ttl=3` |
| 4 | Fake+Split | `fake,multisplit` · `badseq` |
| 5 | Agresif Fake+Disorder | `fake,multidisorder` · `split-pos=1,midsld` · `badseq` |
| 6 | Seqovl Split | `multisplit` · `split-seqovl=681` |
| 7 | Fake TTL 3 | `fake` · `ttl=3` |
| 8 | Fake TTL 4 | `fake` · `ttl=4` |
| 9 | Fake+Split TTL 5 | `fake,multisplit` · `split-pos=2` · `ttl=5` |
| 10 | Disorder | `multidisorder` · `split-pos=1,midsld` |
| 11 | SNI Split | `multisplit` · `split-pos=1,sniext+1` |
| 12 | FakedSplit | `fakedsplit` · `badseq` |
| 13 | Fake TLS Mod | `fake` · `badseq` · `fake-tls-mod=rnd,dupsid,sni=www.google.com` |

Tüm yöntemlerde ek olarak Discord ses (UDP `19294-19344`, `50000-50100`, yalnızca STUN/Discord paketleri) ve
QUIC (UDP `443`) için sahte paket gönderimi aktiftir. Yöntem listesi [`core/zdpi.ps1`](core/zdpi.ps1) içindedir.

</details>

## 🛠️ Sorun Giderme

<details>
<summary><b>"WinDivert sürücüsü takılı" uyarısı çıkıyor</b></summary>

Başka bir DPI aracı (SplitWire, GoodbyeDPI veya zDPI'ın eski sürümleri) WinDivert sürücüsünü kullanımdayken
silmeye çalıştığında sürücü `STOP_PENDING` durumunda kilitlenir. Bu durumda hiçbir DPI aracı çalışamaz ve
tek çözüm bilgisayarı yeniden başlatmaktır. zDPI bunu otomatik algılar, yeniden başlatmayı önerir ve
açılışta kuruluma kendiliğinden devam eder.
</details>

<details>
<summary><b>Hiçbir yöntem çalışmadı</b></summary>

- SplitWire, Cloudflare WARP, Proton VPN veya başka bir VPN/DPI programı açıksa kapatın.
- Superonline modem arayüzünden veya hesabınızdan **Güvenli İnternet** hizmetinin kapalı olduğundan emin olun.
- Birkaç dakika sonra `1_HIZMETI_KUR_OTOMATIK.cmd`'yi tekrar çalıştırın.
</details>

<details>
<summary><b>Discord açılıyor ama ses kanalında "RTC Bağlanıyor"da kalıyor</b></summary>

Discord'u tamamen kapatıp (görev çubuğundan da) tekrar açın. Sorun sürerse `3_ALTERNATIF_MOD_SECICI.cmd`
ile farklı bir yöntem deneyin.
</details>

<details>
<summary><b>Bazı siteler hâlâ açılmıyor</b></summary>

zDPI alan adı (SNI) tabanlı engelleri aşar. Doğrudan IP adresi üzerinden engellenen siteler için bir VPN gerekir.
</details>

<details>
<summary><b>Antivirüs uyarı veriyor</b></summary>

`winws.exe` ve `WinDivert64.sys` ağ paketlerini işleyen araçlar olduğu için bazı antivirüsler bunları
"riskli yazılım" olarak işaretleyebilir. Dosyalar açık kaynaklı [zapret](https://github.com/bol-van/zapret)
projesinin resmi derlemeleridir. Klasörü antivirüs istisnalarına ekleyebilirsiniz.
</details>

## 📋 Gereksinimler

- Windows 10 veya 11 (64-bit)
- Yönetici yetkisi (kurulum sırasında bir kez istenir)
- Turkcell Superonline bağlantısı (diğer sağlayıcılarda da çalışabilir, otomatik test hangisinin çalıştığını bulur)

## 🌍 English

**zDPI** is a one-click DPI bypass for Windows, tuned for Turkcell Superonline in Turkey, where Discord and
other sites are blocked via SNI inspection. It wraps the [zapret](https://github.com/bol-van/zapret) `winws`
engine: the installer probes 13 desync strategies against live Discord endpoints, installs the first one that
works as a Windows service, and enables encrypted DNS (DoH) only if the system resolver is poisoned.
Not a VPN; game traffic is left untouched. Run `1_HIZMETI_KUR_OTOMATIK.cmd` and accept the UAC prompt.

## 📜 Lisans ve Teşekkürler

zDPI betikleri [MIT lisansı](LICENSE) ile dağıtılır. Paketle birlikte gelen üçüncü taraf bileşenler kendi
lisanslarına tabidir. Ayrıntılar için [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) dosyasına bakın.

- [**zapret**](https://github.com/bol-van/zapret), bol-van: DPI bypass motoru (`winws`)
- [**WinDivert**](https://github.com/basil00/WinDivert), basil00: Windows paket yakalama sürücüsü

> [!NOTE]
> Bu araç, erişim kısıtlamalarını aşmak ve internet özgürlüğü amacıyla geliştirilmiştir. Kullanımından doğan
> sorumluluk kullanıcıya aittir.

<div align="center">
<br>
<b>Developed by <a href="https://github.com/heFRKN">FRKN</a></b>
</div>
