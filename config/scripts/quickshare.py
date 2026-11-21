#!/usr/bin/env python3
"""SHADOWX // Quickshare — share a file over LAN with a QR code (rofi pick)."""
import os
import subprocess
import threading
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

HOME = Path.home()
SHARE = HOME / "Quickshare"
SHARE.mkdir(exist_ok=True)


def pick_file():
    result = subprocess.run(
        ["rofi", "-dmenu", "-theme", str(HOME / ".config/rofi/sidonia.rasi"),
         "-p", "[SHADOWX] QUICKSHARE FILE"],
        input=str(SHARE).encode(), capture_output=True,
    )
    return result.stdout.decode().strip() if result.returncode == 0 else ""


def main():
    target = pick_file()
    if not target or not Path(target).exists():
        return
    path = Path(target)
    port = 8765
    os.chdir(path.parent)

    class Handler(SimpleHTTPRequestHandler):
        def log_message(self, *args):
            pass

    server = ThreadingHTTPServer(("0.0.0.0", port), Handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()

    import socket
    ip = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        ip.connect(("8.8.8.8", 80)); host = ip.getsockname()[0]
    except Exception:
        host = "127.0.0.1"
    url = f"http://{host}:{port}/{path.name}"

    try:
        import qrcode
        img = qrcode.make(url)
        out = Path("/tmp/shadowx-qr.png"); img.save(out)
        subprocess.Popen(["xdg-open", str(out)])
    except Exception:
        pass
    subprocess.run(["dunstify", "SHADOWX // QUICKSHARE", url])
    subprocess.run(["rofi", "-e", f"Share link (Ctrl+C):\n{url}\n\nPress Esc when done",
                    "-theme", str(HOME / ".config/rofi/sidonia.rasi")])
    server.shutdown()


if __name__ == "__main__":
    main()
