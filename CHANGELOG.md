# Changelog

Bu projedeki tüm önemli değişiklikler bu dosyada listelenir.
Biçim [Keep a Changelog](https://keepachangelog.com/tr-TR/1.1.0/), sürümleme [SemVer](https://semver.org/lang/tr/) esaslıdır.

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

[2.0.0]: https://github.com/heFRKN/zDPI-for-superonline/compare/42c60b9...main
