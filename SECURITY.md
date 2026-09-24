# Güvenlik Politikası

## Desteklenen sürümler

Yalnızca [en son sürüm](https://github.com/heFRKN/zDPI-for-superonline/releases/latest) güvenlik düzeltmesi alır.

| Sürüm | Destek |
| :-- | :-- |
| 2.1.x | ✅ |
| < 2.1 | ❌ Lütfen güncelleyin |

## Açık bildirme

Güvenlik açıklarını **herkese açık issue olarak açmayın.** Bunun yerine GitHub'ın gizli bildirim özelliğini kullanın:

**[Security → Report a vulnerability](https://github.com/heFRKN/zDPI-for-superonline/security/advisories/new)**

Bildiriminizde şunlar olursa hızlı ilerleriz:

- Etkilenen dosya ve sürüm
- Açığın nasıl tetiklendiği (adım adım)
- Olası etkisi (ör. yetki yükseltme, uzaktan kod çalıştırma)

Bildirimler en geç 7 gün içinde yanıtlanır. Düzeltme yayınlandıktan sonra, isterseniz adınız sürüm notlarında anılır.

## Kapsam

- `*.cmd` betikleri ve `core/zdpi.ps1`
- Kurulumun oluşturduğu `zDPI` hizmeti ve `C:\Program Files\zDPI` klasörü

`winws.exe`, `WinDivert` ve `cygwin1.dll` üçüncü taraf bileşenlerdir. Bunlardaki açıkları ilgili projelere bildirin:
[zapret](https://github.com/bol-van/zapret/security), [WinDivert](https://github.com/basil00/WinDivert/issues).

## Güvenlik tasarımı

- Paketteki ikili dosyaların SHA256 özetleri `core/zdpi.ps1` içinde sabitlidir; eşleşmezse kurulum yapılmaz.
- SYSTEM yetkili hizmet yalnızca yöneticilerin yazabildiği `C:\Program Files\zDPI` klasöründen çalışır.
- Yönetici yetkisiyle okunan durum dosyaları korumalı klasörde tutulur ve içerikleri doğrulanır.
- Her sürümle birlikte `SHA256SUMS.txt` yayınlanır.
