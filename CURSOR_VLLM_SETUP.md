# Configuring Cursor to Use Local vLLM (Qwen3-32B-NVFP4)

## Quick Setup Guide

Your vLLM instance is running at:
- **From this machine (spark2)**: `http://localhost:8001/v1`
- **From laptop/other machine via Tailscale**: `http://100.67.176.85:8001/v1` (spark2 = spark-2e06)

Model name: `nvidia/Qwen3-32B-NVFP4`

## Configuration Steps

### Method 1: Via Cursor Settings UI

1. **Open Cursor Settings**
   - Press `Ctrl+,` (or `Cmd+,` on Mac)
   - Or go to: **File > Preferences > Settings**

2. **Navigate to Models Settings**
   - Search for "Models" in the settings search bar
   - Or go to: **Settings > Models**

3. **Configure OpenAI API**
   - Find "OpenAI API" section
   - Click on "OpenAI API Key" or "Configure"
   - Set the following:
     - **Base URL**: `http://localhost:8001/v1` (on spark2) or `http://100.67.176.85:8001/v1` (from laptop via Tailscale)
     - **API Key**: `dummy-key` (vLLM doesn't require auth, but Cursor needs a value)
     - **Model**: `nvidia/Qwen3-32B-NVFP4`

4. **Save and Test**
   - Save the settings
   - Try using Cursor's chat or code completion to test

### Method 2: Via Settings JSON (if available)

If Cursor exposes settings.json, you can add:

```json
{
  "cursor.ai.openaiBaseUrl": "http://100.67.176.85:8001/v1",
  "cursor.ai.openaiApiKey": "dummy-key",
  "cursor.ai.model": "nvidia/Qwen3-32B-NVFP4"
}
```

## Verification

Test that your vLLM endpoint is accessible:

```bash
# Check if model is available
curl http://localhost:8001/v1/models

# Test a simple completion
curl http://localhost:8001/v1/chat/completions   # or use 100.67.176.85 from laptop \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer dummy-key" \
  -d '{
    "model": "nvidia/Qwen3-32B-NVFP4",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 50
  }'
```

## Notes

- **Base URL**: Must include `/v1` at the end (e.g., `http://localhost:8001/v1`)
- **API Key**: vLLM doesn't require authentication, but Cursor may need a dummy value
- **Model Name**: Must match exactly: `nvidia/Qwen3-32B-NVFP4`
- **Context Length**: Your model supports up to **32,768 tokens** (32k) natively
  - Can be extended to 131,072 tokens (131k) with YaRN rope scaling if needed
- **Network**: If accessing from a different machine (e.g. laptop), use Tailscale IP: `http://100.67.176.85:8001/v1` (spark2). See `~/TAILSCALE_SPARK_IPS.md`.

## Troubleshooting

1. **"Connection refused"**: Make sure vLLM container is running:
   ```bash
   docker ps | grep iquest-vllm
   ```

2. **"Model not found"**: Verify model name matches exactly:
   ```bash
   curl http://localhost:8001/v1/models | grep "nvidia/Qwen3-32B-NVFP4"
   ```

3. **"Authentication failed"**: vLLM doesn't require auth, but try setting API key to `dummy-key` or empty string

4. **Remote access**: If Cursor is on a different machine (e.g. laptop):
   - Use Tailscale IP: `http://100.67.176.85:8001/v1` (spark2) or `http://100.88.90.82:8001/v1` (spark1)
   - Ensure firewall allows port 8001. See `~/TAILSCALE_SPARK_IPS.md`.

## Current Status

✅ vLLM running on ARM64
✅ Model loaded: nvidia/Qwen3-32B-NVFP4
✅ API endpoint: http://localhost:8001/v1 (spark2); from laptop use http://100.67.176.85:8001/v1
✅ OpenAI-compatible API working
