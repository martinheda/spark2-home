# Qwen3-32B Environments Comparison on DGX Spark

## Summary

Testing Qwen3-32B-NVFP4 across different inference environments from NVIDIA DGX Spark Playbooks.

## Tested Environments

### 1. ✅ vLLM (Working)
- **Status**: ✅ Fully operational
- **Model**: `nvidia/Qwen3-32B-NVFP4`
- **Performance**: ~10.3 tokens/s
- **GPU Memory**: ~20GB
- **Context Length**: 32,768 tokens (32k) native, 131k with YaRN
- **API Endpoint**: `http://localhost:8001/v1/chat/completions`
- **Port**: 8001
- **Pros**: Fast, efficient memory usage, stable
- **Cons**: None significant
- **Best For**: General inference, production use

### 2. ✅ TensorRT-LLM (Working)
- **Status**: ✅ Fully operational
- **Model**: `nvidia/Qwen3-32B-NVFP4`
- **Performance**: ~8.3 tokens/s
- **GPU Memory**: ~70GB
- **Context Length**: Default (check logs)
- **API Endpoint**: `http://localhost:8355/v1/chat/completions`
- **Port**: 8355
- **Backend**: PyTorch (not compiled TensorRT engine)
- **Pros**: Optimized kernels, good for production
- **Cons**: Higher memory usage, slightly slower than vLLM in this test
- **Best For**: Maximum optimization potential (with compiled engine)

### 3. 🔄 SGLang (Loading)
- **Status**: 🔄 Currently loading (CUDA graph capture in progress)
- **Model**: `nvidia/Qwen3-32B-NVFP4`
- **Performance**: TBD
- **GPU Memory**: TBD
- **API Endpoint**: `http://localhost:30000/generate` (different API format)
- **Port**: 30000
- **Pros**: Optimized for structured generation, good for JSON outputs
- **Cons**: Different API format (not OpenAI-compatible)
- **Best For**: Structured outputs, JSON generation

### 4. ⏳ NVIDIA NIM (Not Started)
- **Status**: ⏳ Configuration ready, requires NGC authentication
- **Container**: `nvcr.io/nim/qwen/qwen3-32b-dgx-spark:latest`
- **API Endpoint**: `http://localhost:8002/v1/chat/completions` (when running)
- **Port**: 8002
- **Requirements**: NGC API key
- **Pros**: Pre-optimized, production-ready, easiest setup
- **Cons**: Requires NGC account and authentication
- **Best For**: Production deployment, easiest setup

## Performance Comparison

| Environment | Tokens/s | Memory | Setup Ease | API Compatibility |
|------------|----------|--------|------------|-------------------|
| **vLLM** | **10.3** | **20GB** | Easy | ✅ OpenAI-compatible |
| **TensorRT-LLM** | 8.3 | 70GB | Medium | ✅ OpenAI-compatible |
| **SGLang** | TBD | TBD | Easy | ❌ Custom API |
| **NIM** | TBD | TBD | Very Easy | ✅ OpenAI-compatible |

## Configuration Files

All configurations are in: `/home/martin/iquest-chatbot/assets/docker-compose-models.yml`

### vLLM Service
```yaml
iquest-vllm:
  image: nvcr.io/nvidia/vllm:26.01-py3
  ports:
    - "8001:8000"
  command:
    - "vllm"
    - "serve"
    - "nvidia/Qwen3-32B-NVFP4"
    - "--max-model-len"
    - "32768"
```

### TensorRT-LLM Service
```yaml
qwen3-32b-trtllm:
  image: nvcr.io/nvidia/tensorrt-llm/release:spark-single-gpu-dev
  network_mode: host
  command: [trtllm-serve with config]
```

### SGLang Service
```yaml
qwen3-32b-sglang:
  image: lmsysorg/sglang:spark
  ports:
    - "30000:30000"
  command: [sglang.launch_server with Qwen3-32B-NVFP4]
```

### NIM Service
```yaml
qwen3-32b-nim:
  image: nvcr.io/nim/qwen/qwen3-32b-dgx-spark:latest
  ports:
    - "8002:8000"
  environment:
    - NGC_API_KEY=${NGC_API_KEY}
```

## Recommendations

1. **For Best Performance**: Use **vLLM** (~10.3 tokens/s, low memory)
2. **For Production**: Consider **NIM** (pre-optimized, easiest)
3. **For Structured Outputs**: Try **SGLang** (when ready)
4. **For Maximum Optimization**: **TensorRT-LLM** with compiled engine

## Current Status

- ✅ vLLM: Running and tested
- ✅ TensorRT-LLM: Running and tested  
- 🔄 SGLang: Loading (CUDA graph capture)
- ⏳ NIM: Ready to start (needs NGC auth)

## Next Steps

1. Wait for SGLang to finish loading and test performance
2. Set up NIM if NGC credentials are available
3. Compare all environments side-by-side
4. Choose best option for production use
