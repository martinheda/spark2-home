# NVIDIA NIM Setup Guide for Qwen3-32B

## Prerequisites

NIM containers require NGC (NVIDIA GPU Cloud) authentication.

## Step 1: Get NGC API Key

1. Go to: https://ngc.nvidia.com/setup/api-key
2. Sign in with your NVIDIA account
3. Generate a new API key (or use existing one)
4. Copy the API key (format: `nvapi-...`)

## Step 2: Authenticate Docker

Run these commands:

```bash
export NGC_API_KEY="your-nvapi-key-here"
echo "$NGC_API_KEY" | docker login nvcr.io --username '$oauthtoken' --password-stdin
```

Expected output: `Login Succeeded`

## Step 3: Start NIM Container

```bash
cd /home/martin/iquest-chatbot/assets
docker compose -f docker-compose-models.yml up -d qwen3-32b-nim
```

## Step 4: Monitor Loading

```bash
docker logs qwen3-32b-nim -f
```

## Step 5: Test Performance

Once ready, test with:

```bash
curl http://localhost:8002/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen/qwen3-32b",
    "messages": [{"role": "user", "content": "Hello!"}],
    "max_tokens": 50
  }'
```

## Container Details

- **Image**: `nvcr.io/nim/qwen/qwen3-32b-dgx-spark:latest`
- **Port**: 8002
- **API**: OpenAI-compatible (`/v1/chat/completions`)
- **Cache**: `/home/martin/.cache/nim`

## Troubleshooting

- **401 Unauthorized**: Need to authenticate with NGC first
- **Container won't start**: Check NGC_API_KEY is set and Docker is authenticated
- **Slow download**: First run downloads model (~20GB), subsequent runs use cache
