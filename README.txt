================================================================================
                       zDPI for Superonline  -  v2.1.0
                 Discord ve engelli siteler icin DPI bypass
                                  by FRKN
================================================================================

HIZLI BASLANGIC
---------------
  1) 1_HIZMETI_KUR_OTOMATIK.cmd dosyasina CIFT TIKLAYIN.
  2) Yonetici izni sorulunca "Evet" deyin.
  3) 1-2 dakika bekleyin. Calisan yontem otomatik bulunup kurulur. Bitti.

  Program C:\Program Files\zDPI klasorune kurulur. Bu klasoru ileride kaldirmak
  veya yontem degistirmek icin saklayin.


DOSYALAR
--------
  1_HIZMETI_KUR_OTOMATIK.cmd
      (ONERILEN) Hattinizda calisan yontemi otomatik bulur ve Windows
      hizmeti olarak kurar. Her acilista arkada sessizce calisir.

  2_TEK_SEFERLIK_BASLAT_DISCORD_VE_YASAKLI_SITELER.cmd
      Hizmet kurmadan calistirir. Pencere acik kaldigi surece aktiftir.

  3_ALTERNATIF_MOD_SECICI.cmd
      13 yontemden birini elle secip kurmak veya denemek icin menu.

  4_HIZMETI_KALDIR_TEMIZLE.cmd
      Hizmeti kaldirir, DNS degisikliklerini geri alir.

  5_BAGLANTI_TESTI.cmd
      Hizmet, DNS ve Discord erisim durumunu gosterir.


SORUN GIDERME
-------------
  * "WinDivert surucusu takili" uyarisi:
      Bilgisayari yeniden baslatin. Kurulum acilista kendiliginden devam eder.

  * Hicbir yontem calismadi:
      SplitWire, WARP veya baska bir VPN / DPI programi aciksa kapatin.
      Superonline "Guvenli Internet" hizmetinin kapali oldugundan emin olun.

  * Discord seste "RTC Baglaniyor"da kaliyor:
      Discord'u tamamen kapatip tekrar acin. Olmazsa 3_ALTERNATIF_MOD_SECICI
      ile baska bir yontem deneyin.

  * Antivirus uyari veriyor:
      Dosyalar resmi zapret v72.13 surumuyle birebir aynidir ve kurulumda
      SHA256 ile dogrulanir.
      Klasoru antivirus istisnalarina ekleyebilirsiniz.


BILGI
-----
  - VPN DEGILDIR. Trafiginizi yonlendirmez, oyunlarda ping'e etkisi yoktur.
  - Discord ses kanallari (RTC / UDP) dahil calisir.
  - Motor: zapret v72.13 / winws (bol-van) + WinDivert 2.2.2 (basil00).
    Lisanslar icin THIRD_PARTY_NOTICES.md dosyasina bakin.

  GitHub: https://github.com/heFRKN/zDPI-for-superonline
================================================================================
