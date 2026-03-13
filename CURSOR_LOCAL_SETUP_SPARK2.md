# Use local model on spark2 from your laptop Cursor

This guide configures **Cursor on your laptop** (connected to spark2 via Remote SSH / Tailscale) so that Chat and AI features use the **Ollama model (qwen3:32b) on spark2** instead of Cursor’s cloud models.

## Prerequisites

- Cursor installed on your **laptop**
- Tailscale on the laptop (so it can reach spark2)
- Spark2 (spark-2e06) reachable at **100.67.176.85**
- Ollama running on spark2 with model `qwen3:32b`

Quick check from your **laptop** (Terminal / PowerShell):

```bash
# Can you reach spark2?
ping -c 1 100.67.176.85

# Is Ollama on spark2 responding?
curl http://100.67.176.85:11434/v1/models
```

You should see `qwen3:32b` in the JSON. If not, start Ollama on spark2 and ensure it listens on `0.0.0.0:11434` (see below).

---

## Step 1: Configure Cursor on your laptop

You must set the **Custom / OpenAI-compatible API** in Cursor **on the machine where Cursor is running** (your laptop). Remote SSH does not change that: the AI requests are sent from the laptop to the URL you configure.

### Option A: Using Cursor Settings UI (recommended)

1. Open Cursor on your **laptop** (with or without a Remote SSH session to spark2).
2. Open Settings: **File → Preferences → Settings** (or `Ctrl+,` / `Cmd+,`).
3. In the search box, type: **Models** or **OpenAI** or **Custom API**.
4. Find the section for **OpenAI API** or **Custom API** / **Override OpenAI base URL**.
5. Set:
   - **Base URL**: `http://100.67.176.85:11434/v1`
   - **API Key**: `ollama` (Ollama doesn’t check it; Cursor may require a value).
   - **Model**: `qwen3:32b`
6. Save (Cursor usually saves automatically).

### Option B: Using settings.json on your laptop

1. On your **laptop**, open Cursor’s user settings file:
   - **Windows**: `%APPDATA%\Cursor\User\settings.json`
   - **macOS**: `~/Library/Application Support/Cursor/User/settings.json`
   - **Linux**: `~/.config/Cursor/User/settings.json`
2. Add or merge the following (keep any existing keys):

```json
{
  "cursor.ai.openaiBaseUrl": "http://100.67.176.85:11434/v1",
  "cursor.ai.openaiApiKey": "ollama",
  "cursor.ai.model": "qwen3:32b",
  "cursor.chat.openaiBaseUrl": "http://100.67.176.85:11434/v1",
  "cursor.chat.openaiApiKey": "ollama",
  "cursor.chat.model": "qwen3:32b"
}
```

3. Save the file and restart Cursor if the model doesn’t switch immediately.

---

## Step 2: Select the local model in Cursor

1. In Cursor, open the **Chat** panel: `Ctrl+L` (or `Cmd+L`).
2. At the top of the Chat panel, open the **model selector** (dropdown or “Select model”).
3. Choose **qwen3:32b** (or the label that corresponds to your custom endpoint).
4. If you don’t see it, run **Ctrl+Shift+P** / **Cmd+Shift+P** → “Cursor: Select Model” → pick **qwen3:32b**.

---

## Step 3: Verify

1. In Chat, send: **“Write a short Python hello world.”**
2. The answer should come from your spark2 Ollama model (may be a bit slower than cloud, and may include “reasoning” text with Qwen3).
3. Optionally on spark2, check Ollama logs to see the request:

```bash
# On spark2
journalctl -u ollama -f
```

You should see a request from your laptop’s Tailscale IP when you send a message in Cursor.

---

## If it doesn’t work

### “Connection refused” or no response

- **On laptop**: Confirm Tailscale is connected and you can reach spark2:
  - `curl http://100.67.176.85:11434/v1/models`
- **On spark2**: Ensure Ollama is running and bound to all interfaces:
  - `systemctl status ollama`
  - Check for `OLLAMA_HOST=0.0.0.0:11434` (e.g. in `/etc/systemd/system/ollama.service.d/override.conf`). If not, add it and run:
    - `sudo systemctl daemon-reload && sudo systemctl restart ollama`

### “Model is required” or 400 error

- In Cursor settings, set **Model** exactly to: `qwen3:32b`
- Restart Cursor and choose **qwen3:32b** again in the model selector.

### Model list doesn’t show qwen3:32b

- Confirm Base URL has no typo: `http://100.67.176.85:11434/v1` (with `/v1`).
- Restart Cursor and open the model selector again.

---

## Summary

| Item        | Value |
|------------|--------|
| Spark2     | spark-2e06 |
| Spark2 IP  | 100.67.176.85 |
| Base URL   | http://100.67.176.85:11434/v1 |
| Model      | qwen3:32b |
| API Key    | ollama |

Configure these **in Cursor on your laptop**. After that, when you use Chat or other AI features, Cursor will call Ollama on spark2 instead of the cloud.
