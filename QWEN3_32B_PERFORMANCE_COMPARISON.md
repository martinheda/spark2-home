# Qwen3-32B Performance Comparison - All Environments

## Test Results Summary

### 1. ✅ Ollama
- **Throughput**: **~9.96 tokens/s** ⭐ (Fastest - varm start)
- **GPU Memory**: ~20GB
- **API**: Custom REST API (`/api/chat`)
- **Port**: 11434
- **Status**: ✅ Fully tested and working
- **Pros**: Very easy setup, lightweight, uses llama.cpp (GGUF format), good performance
- **Cons**: Different API format (not OpenAI-compatible), optimized for single-user scenarios
- **Note**: Testet kördes med modellen redan laddad (varm start)

### 2. ✅ vLLM
- **Throughput**: **~9.7 tokens/s** ⭐ (Fastest kall start)
- **GPU Memory**: ~20GB
- **API**: OpenAI-compatible (`/v1/chat/completions`)
- **Port**: 8001
- **Status**: ✅ Fully tested and working (ren GPU)
- **Pros**: Fastest kall start, efficient memory, stable, OpenAI-compatible
- **Cons**: None significant

### 3. ✅ NIM
- **Throughput**: **~9.7 tokens/s**
- **GPU Memory**: ~21GB
- **API**: OpenAI-compatible (`/v1/chat/completions`)
- **Port**: 8002
- **Status**: ✅ Fully tested and working (ren GPU)
- **Pros**: Pre-optimized container, easy setup (once authenticated), good performance, uses vLLM internally
- **Cons**: Requires NGC authentication, uses vLLM internally (kan förvirra GPU-monitoring)

### 4. ✅ SGLang
- **Throughput**: **~8.5 tokens/s**
- **GPU Memory**: ~20GB
- **API**: OpenAI-compatible (`/v1/chat/completions`)
- **Port**: 30000
- **Status**: ✅ Fully tested and working (ren GPU)
- **Pros**: Optimized for structured outputs, OpenAI-compatible API
- **Cons**: Slightly slower than vLLM/NIM

### 5. ✅ TensorRT-LLM  
- **Throughput**: **~8.24 tokens/s**
- **GPU Memory**: ~70GB
- **API**: OpenAI-compatible (`/v1/chat/completions`)
- **Port**: 8355
- **Status**: ✅ Fully tested and working (ren GPU)
- **Pros**: Optimized kernels, production-ready
- **Cons**: Higher memory usage, slower than vLLM/NIM in this test

## Detailed Performance Metrics

| Environment | Short (50 tok) | Medium (200 tok) | Avg Tokens/s | Memory | API Format | Test Type |
|------------|----------------|------------------|--------------|--------|------------|-----------|
| **Ollama** | ~9.96 tok/s | 9.97 tok/s | **9.96** | ~20GB | ❌ Custom | Varm start* |
| **vLLM** | ~10.15 tok/s | 9.29 tok/s | **9.70** | ~20GB | ✅ OpenAI | Kall start |
| **NIM** | ~9.7 tok/s | 9.70 tok/s | **9.70** | ~21GB | ✅ OpenAI | Kall start |
| **SGLang** | ~8.5 tok/s | 8.57 tok/s | **8.50** | ~20GB | ❌ Custom | Kall start |
| **TensorRT-LLM** | ~8.24 tok/s | 8.23 tok/s | **8.24** | ~70GB | ✅ OpenAI | Kall start |

*Ollama-testet kördes med modellen redan laddad (varm start), medan alla andra kördes med ren GPU (kall start)

## Winner: vLLM 🏆 (för kall start) / Ollama (för varm start)

**vLLM är det bästa valet** för denna setup:
- ✅ Snabbast kall start (~9.7 tokens/s)
- ✅ Lägsta minnesanvändning (20GB vs 21GB vs 70GB)
- ✅ OpenAI-kompatibel API
- ✅ Stabil och pålitlig
- ✅ Ingen NGC-autentisering krävs

**Ollama** är bäst för:
- ✅ Enklaste setupen
- ✅ Varm start prestanda (~9.96 tokens/s)
- ✅ Perfekt för single-user scenarier

**NIM** är ett bra alternativ om:
- ✅ Du har NGC-autentisering
- ✅ Du vill ha pre-optimerad container
- ✅ Prestanda liknande vLLM (~9.7 tokens/s)

## Recommendations

1. **Production Use**: **vLLM** - Best balance of speed and efficiency, OpenAI-compatible
2. **Quick Setup / Single User**: **Ollama** - Easiest setup, excellent varm start performance
3. **Pre-optimized Container**: **NIM** - Good performance, easy setup (requires NGC auth)
4. **Structured Outputs**: **SGLang** - If you need JSON/structured generation
5. **Maximum Optimization**: **TensorRT-LLM** - With compiled engine (future), högre minnesanvändning

## Viktiga Noteringar

- **Testmetodik**: Alla tester kördes med ren GPU-minne (kall start) utom Ollama som kördes med varm start
- **NIM använder vLLM**: NIM-containern använder vLLM internt, så "VLLM::EngineCore" i GPU-minnet är normalt när NIM kör
- **Minnessanvändning**: TensorRT-LLM använder betydligt mer GPU-minne (~70GB) än de andra (~20GB)

## Configuration Files

All services configured in: `/home/martin/iquest-chatbot/assets/docker-compose-models.yml`

## Current Running Services

- ✅ Alla modeller testade och stoppade
- ✅ GPU-minnet är rent
- ✅ Alla resultat dokumenterade

## Testmetodik

Alla benchmark-tester kördes med **ren GPU-minne** för rättvisa jämförelser:
- Varje modell startades med ren GPU
- Modellen laddades från början (kall start)
- Benchmark kördes när modellen var redo
- Modellen stoppades och GPU-minnet rensades
- Nästa modell startades med ren GPU

**Undantag**: Ollama-testet kördes med modellen redan laddad (varm start) eftersom modellen redan fanns i GPU-minnet när testningen började.

## Viktiga Lärdomar

1. **NIM använder vLLM internt**: NIM-containern använder vLLM som sin inference engine, så "VLLM::EngineCore" i GPU-minnet är normalt när NIM kör.

2. **GPU-minneshantering**: Det är viktigt att stoppa processer korrekt - många containers lämnar "zombie-processer" kvar i GPU-minnet även efter att containern stoppats.

3. **Rättvisa jämförelser kräver ren GPU**: För att få rättvisa jämförelser måste varje modell testas med ren GPU-minne.

## Slutsats

Efter omfattande testning med ren GPU-minne för varje modell:

**Rekommendation för produktion**: **vLLM** eller **NIM**
- Båda presterar liknande (~9.7 tokens/sec)
- vLLM: Ingen NGC-autentisering krävs
- NIM: Pre-optimerad container, enklare setup (om du har NGC-auth)

**Rekommendation för snabb setup**: **Ollama**
- Enklaste setupen
- Utmärkt prestanda vid varm start (~9.96 tokens/sec)
- Perfekt för single-user scenarier

**Rekommendation för strukturerade outputs**: **SGLang**
- Optimerad för JSON/strukturerad generering
- Bra prestanda (~8.5 tokens/sec)

**TensorRT-LLM**: Använder betydligt mer GPU-minne (~70GB vs ~20GB) och är långsammare i denna testmiljö, men kan vara bättre med kompilerad engine.

