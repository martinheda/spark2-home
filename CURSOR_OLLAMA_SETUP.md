# Konfigurera Cursor IDE att använda Ollama (Qwen3-32B)

**Tailscale-referens:** spark1 = spark-2e9f (100.88.90.82), spark2 = spark-2e06 (100.67.176.85). Se `~/TAILSCALE_SPARK_IPS.md`.

## Översikt

Denna guide visar hur du konfigurerar Cursor IDE att använda din lokala Ollama-instans med Qwen3-32B-modellen som körs på Spark-maskinen.

## Förutsättningar

- ✅ Ollama installerat och körs på Spark-maskinen
- ✅ Qwen3-32B-modellen laddad: `qwen3:32b`
- ✅ Ollama API tillgänglig på port 11434
- ✅ Cursor IDE installerat

## Steg 1: Kontrollera Ollama-status

```bash
# Kontrollera att Ollama kör
systemctl status ollama

# Kontrollera tillgängliga modeller
curl http://localhost:11434/api/tags

# Testa API
curl http://localhost:11434/api/chat -d '{
  "model": "qwen3:32b",
  "messages": [{"role": "user", "content": "Hello"}],
  "stream": false
}'
```

## Steg 2: Konfigurera Ollama för fjärråtkomst (om behövs)

Om Cursor körs på en annan maskin via Tailscale/NVIDIA Sync:

```bash
# Redigera Ollama-konfiguration
sudo systemctl edit ollama

# Lägg till:
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_ORIGINS=*"

# Starta om Ollama
sudo systemctl restart ollama
```

## Steg 3: Konfigurera Cursor Settings

**Viktigt:** Ollama stöder OpenAI-kompatibelt API direkt via `/v1` endpoint! Ingen proxy behövs.

### Metod 1: Via Cursor Settings UI

1. **Öppna Cursor Settings**
   - Tryck `Ctrl+,` (eller `Cmd+,` på Mac)
   - Eller: **File > Preferences > Settings**

2. **Navigera till AI/Models Settings**
   - Sök efter "AI" eller "Models" i settings-sökfältet
   - Eller: **Settings > Features > AI**
   - Eller: **Settings > Cursor Tab > Models**

3. **Konfigurera Custom Endpoint**
   - Hitta "OpenAI API" eller "Custom AI Provider"
   - Aktivera "Use Custom API" eller liknande
   - Sätt följande:
     - **Base URL**: `http://100.67.176.85:11434/v1` (spark2, från laptop) eller `http://localhost:11434/v1` (på spark2)
     - **API Key**: `ollama` (Ollama kräver ingen auth, men Cursor kan behöva ett värde)
     - **Model**: `qwen3:32b`

### Metod 2: Via settings.json

Redigera Cursor's settings.json:

```bash
# Hitta settings.json
# Vanligtvis: ~/.config/Cursor/User/settings.json
# Eller: ~/.cursor/User/settings.json
# Eller: ~/.config/cursor/User/settings.json
```

Lägg till följande i settings.json:

```json
{
  "cursor.ai.openaiBaseUrl": "http://100.67.176.85:11434/v1",
  "cursor.ai.openaiApiKey": "ollama",
  "cursor.ai.model": "qwen3:32b",
  "cursor.ai.provider": "openai"
}
```

(Från laptop använd Tailscale IP; på spark2 kan du använda `http://localhost:11434/v1`. För spark1 använd `http://100.88.90.82:11434/v1`. Se `~/TAILSCALE_SPARK_IPS.md`.)

**Testa OpenAI-kompatibelt API:**
```bash
# Testa /v1/models endpoint
curl http://localhost:11434/v1/models

# Testa /v1/chat/completions endpoint
curl http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen3:32b",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 50
  }'
```

## Steg 4: Om Cursor körs via Tailscale/NVIDIA Sync

**Tailscale IP:** spark2 = `100.67.176.85` (spark-2e06), spark1 = `100.88.90.82` (spark-2e9f). Se `~/TAILSCALE_SPARK_IPS.md`.

### Scenario A: Cursor körs på din lokala maskin, Ollama på Spark

1. **Konfigurera Ollama för fjärråtkomst (om inte redan gjort):**
   ```bash
   # På Spark-maskinen
   sudo systemctl edit ollama
   # Lägg till:
   [Service]
   Environment="OLLAMA_HOST=0.0.0.0:11434"
   Environment="OLLAMA_ORIGINS=*"
   
   sudo systemctl restart ollama
   ```

2. **Uppdatera Cursor settings med Tailscale IP:**
   ```json
   {
     "cursor.ai.openaiBaseUrl": "http://100.67.176.85:11434/v1",
     "cursor.ai.openaiApiKey": "ollama",
     "cursor.ai.model": "qwen3:32b"
   }
   ```

3. **Testa anslutningen från din lokala maskin:**
   ```bash
   # Testa OpenAI-kompatibelt API
   curl http://100.67.176.85:11434/v1/models
   
   # Testa chat completions
   curl http://100.67.176.85:11434/v1/chat/completions \
     -H "Content-Type: application/json" \
     -d '{"model": "qwen3:32b", "messages": [{"role": "user", "content": "test"}]}'
   ```

### Scenario B: Cursor körs på Spark (via SSH eller Remote SSH)

Om Cursor körs direkt på Spark-maskinen:
- Använd `http://localhost:11434/v1` i settings (enklast!)
- Ingen extra konfiguration behövs

## Steg 5: Starta Cursor från SSH-terminal

### Alternativ 1: Starta Cursor direkt från Tailscale SSH

**JA, du kan starta Cursor från ett Tailscale SSH-terminal!**

```bash
# Via Tailscale SSH
ssh martin@spark-2e06  # eller din Tailscale IP

# Starta Cursor från SSH-terminal
cursor .

# Eller med full sökväg om cursor inte är i PATH
~/.cursor-server/bin/linux-arm64/*/bin/remote-cli/cursor .

# Om du behöver X11-forwarding (för grafiskt gränssnitt)
ssh -X martin@spark-2e06
DISPLAY=:0 cursor .
```

**Viktigt för Tailscale:**
- Cursor kan startas från SSH-terminal
- Om Cursor körs på Spark-maskinen: Använd `http://localhost:11434/v1` i settings
- Om Cursor körs på din lokala maskin: Använd Spark's Tailscale IP: `http://100.67.176.85:11434/v1`

### Alternativ 2: Starta Cursor via NVIDIA Sync

1. **Via NVIDIA Sync UI:**
   - Öppna NVIDIA Sync på din lokala maskin
   - Välj din Spark-maskin (spark-2e06)
   - Klicka på "Open in Browser" eller "Launch Application"
   - Välj Cursor om det finns som alternativ
   - **I Cursor settings:** Använd `http://100.67.176.85:11434/v1` (Spark's Tailscale IP)

2. **Via SSH-tunnel (om Cursor körs lokalt):**
   ```bash
   # Skapa SSH-tunnel för Ollama API
   ssh -L 11434:localhost:11434 martin@spark-2e06
   
   # I en annan terminal, starta Cursor lokalt
   cursor .
   # I Cursor settings: Använd http://localhost:11434/v1
   ```

### Alternativ 3: Cursor Remote SSH (Rekommenderat)

Detta är det bästa alternativet för fjärrarbete:

```bash
# På din lokala maskin, öppna Cursor
cursor .

# I Cursor:
# 1. Tryck Ctrl+Shift+P (Cmd+Shift+P på Mac)
# 2. Sök efter "Remote-SSH: Connect to Host"
# 3. Välj eller lägg till: martin@spark-2e06 (eller Tailscale IP)
# 4. Cursor kommer öppna ett nytt fönster anslutet till Spark-maskinen
# 5. I settings: Använd http://localhost:11434/v1 (eftersom du är på Spark-maskinen)
```

**Fördelar med Remote SSH:**
- ✅ Cursor körs direkt på Spark-maskinen
- ✅ Använder `localhost` för Ollama (enklare konfiguration)
- ✅ Fullt integrerat med filsystem och terminal
- ✅ Bättre prestanda för stora filer

## Verifiering

Testa att Cursor kan använda Ollama:

1. **Öppna Cursor**
2. **Öppna Chat/Copilot** (Ctrl+L eller Cmd+L)
3. **Skriv en testfråga**
4. **Kontrollera att svaret kommer från Qwen3-32B**

Du kan också testa API:et direkt:

```bash
curl http://localhost:11434/api/chat -d '{
  "model": "qwen3:32b",
  "messages": [{"role": "user", "content": "Write a Python hello world"}],
  "stream": false
}'
```

## Felsökning

### Problem: "Connection refused"
- **Lösning**: Kontrollera att Ollama kör:
  ```bash
  systemctl status ollama
  curl http://localhost:11434/api/tags
  ```

### Problem: "Model not found"
- **Lösning**: Kontrollera att modellen är laddad:
  ```bash
  ollama list
  ollama pull qwen3:32b  # Om den saknas
  ```

### Problem: Cursor kan inte ansluta via Tailscale
- **Lösning**: 
  1. Kontrollera Tailscale-anslutning: `tailscale status`
  2. Kontrollera att Ollama lyssnar på 0.0.0.0: `systemctl show ollama | grep Environment`
  3. Testa anslutning: `curl http://[TAILSCALE_IP]:11434/api/tags`

### Problem: Cursor startar inte från SSH
- **Lösning**: 
  - Använd `DISPLAY=:0 cursor .` om X11-forwarding behövs
  - Eller använd NVIDIA Sync för att starta Cursor grafiskt
  - Eller använd Cursor Remote SSH-funktion

## Nuvarande Status

- ✅ Ollama körs på Spark-maskinen
- ✅ Qwen3-32B-modellen laddad (`qwen3:32b`)
- ✅ Ollama API tillgänglig på port 11434
- ✅ Cursor installerat

## Ytterligare Tips

1. **För bättre prestanda**: Se till att modellen är laddad i GPU-minnet:
   ```bash
   ollama ps  # Visar laddade modeller
   ```

2. **För fjärråtkomst**: Överväg att använda en reverse proxy eller VPN-tunnel för säker anslutning

3. **För flera modeller**: Du kan växla mellan modeller i Cursor settings när som helst
