let currentLang = 'tr';
let isOneTimeRunning = false;

const i18n = {
  tr: {
    subtitle: "DPI Bypass & Ağ Optimizasyonu",
    status_title: "Durum",
    status_active: "Aktif (Hizmet Çalışıyor)",
    status_onetime: "Aktif (Tek Seferlik Mod)",
    status_inactive: "Devre Dışı (Kapalı)",
    status_checking: "Kontrol Ediliyor...",
    btn_install_title: "Hizmeti Kur (Otomatik Başlat)",
    btn_install_desc: "Windows açılışında arkada sessizce ve 0ms ping ile çalışır",
    btn_onetime_title: "Tek Seferlik Modu Başlat",
    btn_onetime_desc: "Geçici olarak başlatır, kapatınca temizlenir",
    btn_onetime_stop_title: "Tek Seferlik Modu Durdur",
    btn_onetime_stop_desc: "Geçici oturumu sonlandır",
    btn_test_title: "Bağlantıyı Test Et",
    btn_test_desc: "Discord ve sunucu erişimlerini hızlıca sına",
    btn_clean_title: "Tüm Sistemleri Temizle",
    btn_clean_desc: "Servisleri kaldır ve varsayılana sıfırla",
    log_title: "Günlük",
    log_clear: "Temizle"
  },
  en: {
    subtitle: "DPI Bypass & Network Optimization",
    status_title: "Status",
    status_active: "Active (Service Running)",
    status_onetime: "Active (One-Time Mode)",
    status_inactive: "Inactive (Disabled)",
    status_checking: "Checking...",
    btn_install_title: "Install Service (Auto-Start)",
    btn_install_desc: "Runs silently on Windows boot with 0ms ping",
    btn_onetime_title: "Start One-Time Mode",
    btn_onetime_desc: "Runs temporarily; restores cleanly upon exit",
    btn_onetime_stop_title: "Stop One-Time Mode",
    btn_onetime_stop_desc: "Terminate temporary session",
    btn_test_title: "Test Connection",
    btn_test_desc: "Verify live connectivity to Discord & server endpoints",
    btn_clean_title: "Uninstall & Reset All",
    btn_clean_desc: "Remove services and restore network defaults",
    log_title: "Logs",
    log_clear: "Clear"
  }
};

function setLanguage(lang) {
  currentLang = lang;
  document.getElementById('btn-tr').classList.toggle('active', lang === 'tr');
  document.getElementById('btn-en').classList.toggle('active', lang === 'en');
  
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (i18n[lang][key]) {
      el.innerText = i18n[lang][key];
    }
  });

  updateStatusUI();
}

function log(text, type = 'info') {
  const body = document.getElementById('log-body');
  const line = document.createElement('div');
  line.className = `log-line ${type}`;
  const time = new Date().toLocaleTimeString();
  line.innerText = `[${time}] ${text}`;
  body.appendChild(line);
  body.scrollTop = body.scrollHeight;
}

function clearLogs() {
  document.getElementById('log-body').innerHTML = '';
}

let lastState = null;

async function checkStatus() {
  try {
    const res = await fetch('/api/status');
    const data = await res.json();
    lastState = data;
    updateStatusUI();
  } catch (err) {
    console.error("Status check failed:", err);
  }
}

function updateStatusUI() {
  if (!lastState) return;

  const dot = document.getElementById('status-dot');
  const val = document.getElementById('status-val');
  const onetimeBtnTitle = document.getElementById('onetime-title');
  const onetimeBtnDesc = document.getElementById('onetime-desc');
  const onetimeIcon = document.getElementById('onetime-icon');

  if (lastState.service_active) {
    dot.className = 'status-dot active';
    val.innerText = i18n[currentLang].status_active;
  } else if (lastState.onetime_active || lastState.process_active) {
    dot.className = 'status-dot onetime';
    val.innerText = i18n[currentLang].status_onetime;
  } else {
    dot.className = 'status-dot';
    val.innerText = i18n[currentLang].status_inactive;
  }

  isOneTimeRunning = lastState.onetime_active || (lastState.process_active && !lastState.service_active);
  if (isOneTimeRunning) {
    onetimeBtnTitle.innerText = i18n[currentLang].btn_onetime_stop_title;
    onetimeBtnDesc.innerText = i18n[currentLang].btn_onetime_stop_desc;
    onetimeIcon.innerText = "🛑";
  } else {
    onetimeBtnTitle.innerText = i18n[currentLang].btn_onetime_title;
    onetimeBtnDesc.innerText = i18n[currentLang].btn_onetime_desc;
    onetimeIcon.innerText = "🌐";
  }
}

async function installService() {
  log(currentLang === 'tr' ? "Hizmet kurulumu başlatılıyor..." : "Installing service...", "info");
  try {
    const res = await fetch('/api/action/install', { method: 'POST' });
    const data = await res.json();
    if (data.success) {
      log(currentLang === 'tr' ? "zDPI Hizmeti kuruldu ve aktif! (0ms ping)" : "zDPI Service active! (0ms ping)", "success");
    } else {
      log(currentLang === 'tr' ? "Kurulum tamamlanamadı." : "Installation failed.", "error");
    }
    checkStatus();
  } catch (e) {
    log("İşlem hatası: " + e.message, "error");
  }
}

async function toggleOneTime() {
  if (isOneTimeRunning) {
    log(currentLang === 'tr' ? "Tek Seferlik Mod durduruluyor..." : "Stopping One-Time Mode...", "info");
    try {
      await fetch('/api/action/stop_onetime', { method: 'POST' });
      log(currentLang === 'tr' ? "Tek Seferlik Mod durduruldu." : "One-Time Mode stopped.", "success");
      checkStatus();
    } catch (e) {
      log("Hata: " + e.message, "error");
    }
  } else {
    log(currentLang === 'tr' ? "Tek Seferlik Mod başlatılıyor..." : "Starting One-Time Mode...", "info");
    try {
      const res = await fetch('/api/action/start_onetime', { method: 'POST' });
      const data = await res.json();
      if (data.success) {
        log(currentLang === 'tr' ? "Tek Seferlik Mod aktif! Discord ve siteler açık." : "One-Time Mode active!", "success");
      } else {
        log(currentLang === 'tr' ? "Başlatılamadı." : "Failed to start.", "error");
      }
      checkStatus();
    } catch (e) {
      log("Hata: " + e.message, "error");
    }
  }
}

async function uninstallAll() {
  log(currentLang === 'tr' ? "Tüm sistemler temizleniyor..." : "Uninstalling all...", "info");
  try {
    await fetch('/api/action/uninstall', { method: 'POST' });
    log(currentLang === 'tr' ? "Tüm servisler kaldırıldı ve sıfırlandı." : "All systems reset.", "success");
    checkStatus();
  } catch (e) {
    log("Hata: " + e.message, "error");
  }
}

async function runConnectionTest() {
  log(currentLang === 'tr' ? "Bağlantı test ediliyor..." : "Testing connection...", "info");
  try {
    const res = await fetch('/api/action/test', { method: 'POST' });
    const data = await res.json();
    if (data.results) {
      for (const [key, val] of Object.entries(data.results)) {
        if (val.ok) {
          log(`[OK] ${key} -> ${val.ms}ms`, "success");
        } else {
          log(`[HATA] ${key} -> Başarısız`, "error");
        }
      }
    }
  } catch (e) {
    log("Test hatası: " + e.message, "error");
  }
}

setInterval(checkStatus, 1500);
checkStatus();
log("zDPI hazır.", "info");
