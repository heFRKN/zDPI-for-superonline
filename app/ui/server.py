import os
import sys
import json
import time
import subprocess
import urllib.request
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler

PORT = 49223
APP_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
CORE_DIR = os.path.join(APP_DIR, "core")
ASSETS_DIR = os.path.join(APP_DIR, "assets")
UI_DIR = os.path.join(APP_DIR, "ui")
SCRIPTS_DIR = os.path.join(APP_DIR, "scripts")

onetime_proc = None

def is_service_running():
    for srv in ["zDPI_Service", "FailureStudioDPI", "ZapretSuperonline", "zapret"]:
        try:
            res = subprocess.run(["sc", "query", srv], capture_output=True, timeout=2)
            out = res.stdout.decode('cp1254', errors='ignore') + res.stdout.decode('utf-8', errors='ignore')
            if "RUNNING" in out or "4  RUNNING" in out:
                return True
        except Exception:
            pass
    return False

def is_process_running(proc_name="winws.exe"):
    try:
        res = subprocess.run(["tasklist", "/fi", f"imagename eq {proc_name}"], capture_output=True, timeout=2)
        out = res.stdout.decode('cp1254', errors='ignore') + res.stdout.decode('utf-8', errors='ignore')
        return proc_name.lower() in out.lower()
    except Exception:
        return False

def test_connection():
    results = {}
    endpoints = [
        ("discord.com (Web)", "https://discord.com"),
        ("gateway.discord.gg (Ses)", "https://gateway.discord.gg"),
        ("cdn.discordapp.com (Medya)", "https://cdn.discordapp.com")
    ]
    for name, url in endpoints:
        start = time.time()
        try:
            res = subprocess.run(["curl.exe", "-I", "-k", "--connect-timeout", "3", url], capture_output=True, timeout=4)
            elapsed = int((time.time() - start) * 1000)
            if res.returncode == 0:
                results[name] = {"ok": True, "ms": elapsed}
            else:
                results[name] = {"ok": False, "error": "Baglanti zaman asimi / Timeout", "ms": -1}
        except Exception as e:
            results[name] = {"ok": False, "error": str(e), "ms": -1}
    return results

def run_elevated_script(script_path):
    try:
        ps_cmd = f"Start-Process -FilePath '{script_path}' -Verb RunAs -WindowStyle Hidden -Wait"
        subprocess.run(["powershell", "-Command", ps_cmd], capture_output=True, timeout=20)
        return True
    except Exception:
        return False

def cleanup_all():
    global onetime_proc
    if onetime_proc:
        try:
            onetime_proc.kill()
        except Exception:
            pass
        onetime_proc = None
    
    clean_script = os.path.join(SCRIPTS_DIR, "3_Sistemleri_Temizle.cmd")
    if os.path.exists(clean_script):
        run_elevated_script(clean_script)
    else:
        for srv in ["zDPI_Service", "FailureStudioDPI", "ZapretSuperonline", "zapret", "GoodbyeDPI"]:
            subprocess.run(["sc", "stop", srv], capture_output=True)
            subprocess.run(["sc", "delete", srv], capture_output=True)
        subprocess.run(["taskkill", "/f", "/im", "winws.exe"], capture_output=True)
        subprocess.run(["ipconfig", "/flushdns"], capture_output=True)

class zDPIHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=APP_DIR, **kwargs)

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def do_GET(self):
        if self.path == "/" or self.path == "/index.html":
            self.send_response(200)
            self.send_header("Content-type", "text/html; charset=utf-8")
            self.end_headers()
            with open(os.path.join(UI_DIR, "index.html"), "rb") as f:
                self.wfile.write(f.read())
            return
        elif self.path == "/style.css":
            self.send_response(200)
            self.send_header("Content-type", "text/css; charset=utf-8")
            self.end_headers()
            with open(os.path.join(UI_DIR, "style.css"), "rb") as f:
                self.wfile.write(f.read())
            return
        elif self.path == "/app.js":
            self.send_response(200)
            self.send_header("Content-type", "application/javascript; charset=utf-8")
            self.end_headers()
            with open(os.path.join(UI_DIR, "app.js"), "rb") as f:
                self.wfile.write(f.read())
            return
        elif self.path.startswith("/assets/"):
            file_name = os.path.basename(self.path)
            file_path = os.path.join(ASSETS_DIR, file_name)
            if os.path.exists(file_path):
                self.send_response(200)
                self.send_header("Content-type", "image/png")
                self.end_headers()
                with open(file_path, "rb") as f:
                    self.wfile.write(f.read())
                return

        if self.path == "/api/status":
            srv = is_service_running()
            proc = is_process_running("winws.exe")
            onetime_alive = (onetime_proc is not None and onetime_proc.poll() is None)
            is_onetime = onetime_alive or (proc and not srv)

            data = {
                "service_active": srv,
                "process_active": proc,
                "onetime_active": is_onetime,
                "timestamp": time.time()
            }
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(data).encode("utf-8"))
            return

        super().do_GET()

    def do_POST(self):
        global onetime_proc
        content_len = int(self.headers.get('Content-Length', 0))
        if content_len > 0:
            self.rfile.read(content_len)
        
        response_data = {"status": "ok", "success": True}

        try:
            if self.path == "/api/action/install":
                install_script = os.path.join(SCRIPTS_DIR, "1_Hizmeti_Kur.cmd")
                run_elevated_script(install_script)
                time.sleep(1.5)
                srv_ok = is_service_running()
                response_data = {
                    "success": srv_ok,
                    "message": "zDPI Hizmeti kuruldu ve calisiyor!" if srv_ok else "Hizmet baslatilamadi. Lutfen Yonetici Olarak Calistirin."
                }

            elif self.path == "/api/action/start_onetime":
                # Clean up existing first
                cleanup_all()
                time.sleep(0.5)

                onetime_script = os.path.join(SCRIPTS_DIR, "2_Tek_Seferlik.cmd")
                # Start one-time script elevated with hidden or background window
                ps_cmd = f"Start-Process -FilePath '{onetime_script}' -Verb RunAs -WindowStyle Hidden"
                subprocess.run(["powershell", "-Command", ps_cmd], capture_output=True)
                time.sleep(1.5)
                
                proc_ok = is_process_running("winws.exe")
                response_data = {
                    "success": proc_ok,
                    "message": "Tek Seferlik Mod aktif edildi! (Discord & Web erisimi acik)" if proc_ok else "Baslatilamadi. Lutfen Yonetici iznini onaylayin."
                }

            elif self.path == "/api/action/stop_onetime":
                cleanup_all()
                response_data = {"success": True, "message": "Tek Seferlik Mod durduruldu."}

            elif self.path == "/api/action/uninstall":
                cleanup_all()
                response_data = {"success": True, "message": "Tum servisler ve surecler temizlendi."}

            elif self.path == "/api/action/test":
                results = test_connection()
                response_data = {"success": True, "results": results}

        except Exception as e:
            response_data = {"success": False, "message": f"Hata olustu: {str(e)}"}

        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(response_data).encode("utf-8"))

def start_server():
    server = ThreadingHTTPServer(("127.0.0.1", PORT), zDPIHandler)
    server.serve_forever()

if __name__ == "__main__":
    start_server()
