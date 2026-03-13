#!/usr/bin/env python3
"""
Ollama proxy for Cursor IDE.
Cursor sometimes omits the "model" field in requests; Ollama requires it.
This proxy forwards requests to Ollama and injects model="qwen3:32b" when missing.
Run on spark2: python3 ollama-cursor-proxy.py
Then point Cursor to: http://100.67.176.85:11435/v1
"""

import json
import urllib.request
import urllib.error
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse

OLLAMA_TARGET = "http://127.0.0.1:11434"
DEFAULT_MODEL = "qwen3:32b"
PROXY_PORT = 11435


class OllamaProxyHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self._proxy()

    def do_POST(self):
        self._proxy()

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        self.end_headers()

    def _proxy(self):
        path = self.path or "/"
        if path.startswith("/v1/"):
            target_url = OLLAMA_TARGET + path
        else:
            target_url = OLLAMA_TARGET + "/v1" + path

        content_length = self.headers.get("Content-Length", 0)
        body = self.rfile.read(int(content_length)) if content_length else None

        if body and self.command == "POST" and "/chat/completions" in path:
            try:
                data = json.loads(body.decode("utf-8"))
                if not data.get("model"):
                    data["model"] = DEFAULT_MODEL
                body = json.dumps(data).encode("utf-8")
            except (json.JSONDecodeError, UnicodeDecodeError):
                pass

        req = urllib.request.Request(
            target_url,
            data=body,
            method=self.command,
            headers={k: v for k, v in self.headers.items() if k.lower() not in ("host", "content-length")},
        )
        if body:
            req.add_header("Content-Length", str(len(body)))

        try:
            with urllib.request.urlopen(req, timeout=120) as resp:
                self.send_response(resp.status)
                for k, v in resp.headers.items():
                    if k.lower() not in ("transfer-encoding", "connection"):
                        self.send_header(k, v)
                self.send_header("Access-Control-Allow-Origin", "*")
                self.end_headers()
                self.wfile.write(resp.read())
        except urllib.error.HTTPError as e:
            self.send_response(e.code)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(e.read())
        except Exception as e:
            self.send_response(502)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode("utf-8"))

    def log_message(self, format, *args):
        print(f"[{self.log_date_time_string()}] {format % args}")


def main():
    server = HTTPServer(("0.0.0.0", PROXY_PORT), OllamaProxyHandler)
    print(f"Ollama proxy listening on 0.0.0.0:{PROXY_PORT} -> {OLLAMA_TARGET}")
    print(f"Use in Cursor: http://100.67.176.85:{PROXY_PORT}/v1  (model={DEFAULT_MODEL})")
    server.serve_forever()


if __name__ == "__main__":
    main()
