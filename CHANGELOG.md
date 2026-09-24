# Changelog

Bu projedeki tüm önemli değişiklikler bu dosyada listelenir.
Biçim [Keep a Changelog](https://keepachangelog.com/tr-TR/1.1.0/), sürümleme [SemVer](https://semver.org/lang/tr/) esaslıdır.

## [2.1.0] - 2026-09-24

### Güvenlik
- **Yetki yükseltme açığı kapatıldı:** SYSTEM yetkili hizmet, kullanıcının yazabildiği indirme klasöründen
  çalışıyordu. Yönetici olmayan bir program `winws.exe` veya `cygwin1.dll` dosyasını değiştirerek SYSTEM
  yetkisi elde edebilirdi. Dosyalar artık yalnızca yöneticilerin yazabildiği `C:\Program Files\zDPI` klasörüne
  kopyalanıp oradan çalıştırılıyor.
- **Dosya bütünlüğü doğrulaması:** Paketteki dört ikili dosyanın SHA256 özetleri motorun içine sabitlendi.
  Değiştirilmiş veya bozuk dosyayla kurulum yapılmıyor; kopyalamadan sonra hedefte de tekrar doğrulanıyor.
- **Doğrulanmış winws.exe:** Önceki `winws.exe` hiçbir resmi zapret sürümüyle eşleşmiyordu. Resmi zapret
  v72.13 derlemesiyle değiştirildi; artık `core/` içindeki dört dosya da resmi sürümle birebir aynı.
- **Registry silme doğrulaması:** Kaldırma sırasında yönetici yetkisiyle silinen DNS registry anahtarlarının
  yolu, kullanıcının yazabildiği bir dosyadan okunuyordu. Kayıt korumalı klasöre taşındı ve yalnızca geçerli
  adaptör GUID'leri kabul ediliyor.
- **Geçici dosya:** Yönetici yetkisiyle kullanıcının `%TEMP%` klasörüne sabit isimli dosya yazılması
  (sembolik link saldırısına açık) kaldırıldı.
- **Yetki yükseltme satırı:** Klasör yolunda `'` karakteri olduğunda bozulan ve komut enjeksiyonuna açık
  `Start-Process` çağrısı, yolu ortam değişkeniyle aktaracak şekilde düzeltildi.
- `SECURITY.md` eklendi; sürümlerle birlikte `SHA256SUMS.txt` yayınlanıyor.

### Değişti
- zapret motoru v72.13'e güncellendi; 13 yöntemin tamamı yeni sürümde doğrulandı.

## [2.0.0] - 2026-09-24

### Eklendi
- `core/zdpi.ps1` motoru: tüm kurulum, çalıştırma, test ve kaldırma mantığı tek bir yerde.
- **Otomatik yöntem bulma:** kurulum 13 yöntemi gerçek Discord bağlantısıyla test eder ve ilk çalışanı kurar.
- Seçilen yöntem `core/strateji.txt` dosyasında saklanır ve sonraki kurulumlarda önce o denenir.
- WinDivert sürücüsü takılı (`STOP_PENDING`) ise algılanır, yeniden başlatma önerilir ve kurulum açılışta otomatik devam eder.
- Akıllı DNS: yalnızca DNS engelliyse Windows şifreli DNS (DoH, Cloudflare) açılır; kaldırmada geri alınır.
- Hizmet çökerse kendini otomatik yeniden başlatır.
- `3_ALTERNATIF_MOD_SECICI.cmd` artık 13 yöntemin tamamını ve otomatik modu sunar.
- Lisans, üçüncü taraf bildirimleri ve GitHub issue şablonu.

### Düzeltildi
- **WinDivert sürücüsünün kilitlenmesi:** betikler, kullanımdaki sürücüyü `sc delete` ve registry silme ile
  kaldırmaya çalışıyordu. Bu, sürücüyü yeniden başlatmaya kadar kilitliyor; zDPI, SplitWire ve GoodbyeDPI'ın
  hiçbiri çalışamıyordu. WinDivert hizmetine artık hiç dokunulmuyor.
- Hem hizmet hem zamanlanmış görev aynı anda `winws` başlatıyor, açılışta iki kopya çakışıyordu. Artık tek hizmet var.
- DNS ve IPv6 ayarları yalnızca `Ethernet` adlı adaptöre uygulanıyordu (Wi-Fi'da çalışmıyordu).
- Düz (şifresiz) DNS'e zorlama, Superonline DNS müdahalesine açıktı ve çalışan dnscrypt kurulumlarını eziyordu.
- 50000-65535 aralığındaki tüm UDP trafiğine sahte paket gönderiliyordu (oyun trafiği etkileniyordu).
  Artık yalnızca Discord ses (STUN/Discord) ve QUIC paketleri işleniyor.
- Mod 5 hizmet kurulumundaki hatalı tırnaklama.

### Kaldırıldı
- `alternatifler/` klasörü (tüm yöntemler `3_ALTERNATIF_MOD_SECICI.cmd` içinde).
- Kullanılmayan `core/elevator.exe`, `core/killall.exe`, `core/files/`, `core/windivert.filter/`.

## [1.0.0]

- İlk sürüm: 6 Superonline profili, hizmet ve tek seferlik mod.

[2.1.0]: https://github.com/heFRKN/zDPI-for-superonline/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/heFRKN/zDPI-for-superonline/compare/42c60b9...v2.0.0
