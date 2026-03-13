# Configuring YaRN Rope Scaling for 131k Context Length

## Overview

Qwen3-32B supports:
- **32,768 tokens** natively (current configuration)
- **131,072 tokens** with YaRN rope scaling

## Method 1: Using `--rope-scaling` Parameter (vLLM 0.13+)

For vLLM 0.13 and later, you can use the `--rope-scaling` command-line argument:

```bash
vllm serve nvidia/Qwen3-32B-NVFP4 \
  --trust-remote-code \
  --max-model-len 131072 \
  --rope-scaling '{"type": "yarn", "factor": 4.0}' \
  --dtype auto \
  --gpu-memory-utilization 0.90
```

### Parameters Explained:
- `--max-model-len 131072`: Target context length (131k tokens)
- `--rope-scaling`: JSON string with rope scaling configuration
  - `"type": "yarn"`: Use YaRN (Yet another RoPE N) scaling method
  - `"factor": 4.0`: Scaling factor (131072 / 32768 = 4.0)

## Method 2: Using `hf_overrides` (Python API)

If using vLLM's Python API instead of command line:

```python
from vllm import LLM

llm = LLM(
    model="nvidia/Qwen3-32B-NVFP4",
    trust_remote_code=True,
    max_model_len=131072,
    hf_overrides={
        "rope_parameters": {
            "rope_type": "yarn",
            "factor": 4.0,
            "original_max_position_embeddings": 32768,
        }
    },
    dtype="auto",
    gpu_memory_utilization=0.90
)
```

## Docker Compose Configuration

To update your `docker-compose-models.yml` for 131k context:

```yaml
iquest-vllm:
  image: nvcr.io/nvidia/vllm:26.01-py3
  container_name: iquest-vllm
  shm_size: "4g"
  ports:
    - "8001:8000"
  environment:
    - HF_TOKEN=${HF_TOKEN}
    - HUGGING_FACE_HUB_TOKEN=${HF_TOKEN}
  volumes:
    - /home/martin/.cache/huggingface:/root/.cache/huggingface
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            count: all
            capabilities: [gpu]
  command: 
    - "vllm"
    - "serve"
    - "nvidia/Qwen3-32B-NVFP4"
    - "--trust-remote-code"
    - "--max-model-len"
    - "131072"
    - "--rope-scaling"
    - '{"type": "yarn", "factor": 4.0}'
    - "--dtype"
    - "auto"
    - "--gpu-memory-utilization"
    - "0.90"
```

## Important Considerations

### Memory Requirements
- **32k context**: ~20GB GPU memory
- **131k context**: Significantly more GPU memory required
  - KV cache scales with context length
  - May need to reduce `--gpu-memory-utilization` to 0.80 or lower
  - Consider using `--kv-cache-dtype` with quantization (e.g., `fp8`)

### Performance Trade-offs
- Longer context = slower inference
- More memory usage
- Better for long documents, codebases, conversations

### Alternative: Dynamic Scaling
If YaRN doesn't work, try dynamic scaling:

```bash
--rope-scaling '{"type": "dynamic", "factor": 4.0}'
```

## Verification

After starting with 131k configuration, verify:

```bash
# Check model info
curl http://localhost:8001/v1/models | python3 -m json.tool | grep max_model_len

# Should show: "max_model_len": 131072
```

## Current vs Extended Configuration

| Configuration | Context Length | Use Case |
|--------------|----------------|----------|
| **Native (Current)** | 32,768 tokens | Most coding tasks, standard conversations |
| **YaRN Extended** | 131,072 tokens | Very long codebases, extensive documentation, long conversations |

## Recommendation

- **Start with 32k** (current): Better performance, sufficient for most tasks
- **Upgrade to 131k** if you need:
  - Processing entire large codebases
  - Long document analysis
  - Extended conversation history
  - Multi-file code understanding
