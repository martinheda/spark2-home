# Ollama proxy för Cursor – "model is required" löst

## Problemet

Cursor skickar ibland **inte** fältet `model` i anropen till din anpassade API. Ollama kräver `model` och svarar med:

```text
400: {"error":{"message":"model is required",...}}
```

## Lösningen

En liten proxy på spark2 tar emot anrop från Cursor, lägger till `"model": "qwen3:32b"` om det saknas, och vidarebefordrar till Ollama.

- **Proxy lyssnar på:** `http://0.0.0.0:11435`
- **Cursor använder:** `http://100.67.176.85:11435/v1` (Tailscale-IP från laptop)
- **Ollama kör som vanligt på:** `127.0.0.1:11434`

Cursor-inställningarna på spark2 är redan uppdaterade till att använda port **11435** (proxyn) i stället för 11434.

---

## Starta proxyn på spark2

### Alternativ 1: Systemd (användartjänst, rekommenderat)

```bash
# Ladda om och starta
systemctl --user daemon-reload
systemctl --user start ollama-cursor-proxy

# Starta automatiskt vid inloggning (valfritt)
systemctl --user enable ollama-cursor-proxy

# Kontrollera status
systemctl --user status ollama-cursor-proxy
```

### Alternativ 2: Kör scriptet manuellt

```bash
cd ~
python3 ollama-cursor-proxy.py
```

Låt terminalen vara öppen medan du använder Cursor med den lokala modellen.

---

## Verifiera

På spark2 (eller från laptop om Tailscale är igång):

```bash
# Utan model-fält – proxyn ska lägga till det
curl -s -X POST http://100.67.176.85:11435/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Hej"}],"max_tokens":10}'
```

Du ska få ett normalt svar från Ollama (med `"model":"qwen3:32b"` i svaret).

---

## Cursor på laptopen

Om Cursor körs på **laptopen** (inte Remote SSH) ska den använda:

- **Base URL:** `http://100.67.176.85:11435/v1`
- **Model:** `qwen3:32b`
- **API Key:** `ollama`

Konfigurera under **Settings → Models** (eller motsvarande) på laptopen.

---

## Sammanfattning

| Vad              | Värde                          |
|------------------|---------------------------------|
| Orsak till 400   | Cursor skickar inte `model`     |
| Lösning          | Proxy på spark2, port 11435     |
| Script           | `~/ollama-cursor-proxy.py`     |
| Starta (systemd) | `systemctl --user start ollama-cursor-proxy` |
| Cursor Base URL  | `http://100.67.176.85:11435/v1` |

När proxyn körs och Cursor pekar på 11435 ska du kunna välja **Qwen3 32B (lokalt spark2)** i modellmenyn utan "model is required"-felet.
