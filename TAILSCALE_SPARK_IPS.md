# Tailscale IP-adresser för Spark-maskiner

Använd dessa IP-adresser istället för `localhost` när du ansluter från en annan maskin (t.ex. din laptop) via Tailscale.

| Maskin   | Tailscale hostname | Tailscale IP   |
|----------|--------------------|----------------|
| **spark1** | spark-2e9f         | **100.88.90.82**  |
| **spark2** | spark-2e06         | **100.67.176.85** |

## När du ska använda Tailscale IP

- **Cursor på laptop** → ansluter till Ollama/vLLM på Spark: använd Spark:s Tailscale IP.
- **Skript eller tjänster som körs på laptop** och ska nå Spark: använd Tailscale IP.
- **På själva Spark-maskinen** (SSH inloggad eller Cursor Remote SSH): `localhost` fungerar.

## Exempel (spark2 = denna maskin)

### Ollama (port 11434)
- Från laptop: `http://100.67.176.85:11434/v1`
- Från spark2: `http://localhost:11434/v1`

### vLLM (port 8001)
- Från laptop: `http://100.67.176.85:8001/v1`
- Från spark2: `http://localhost:8001/v1`

### Spark1 (spark-2e9f)
- Ollama på spark1: `http://100.88.90.82:11434/v1`
- vLLM på spark1: `http://100.88.90.82:8001/v1`

## Kontrollera aktuella IP-adresser

```bash
tailscale status | grep spark
```
