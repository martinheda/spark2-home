# Hur du använder din lokala Qwen3-32B-modell i Cursor

## Snabbstart

Din modell körs på:
- **Från spark2 (denna maskin)**: `http://localhost:11434/v1`
- **Från laptop via Tailscale**: `http://100.67.176.85:11434/v1` (spark2)

Modellnamn: `qwen3:32b`. Se `~/TAILSCALE_SPARK_IPS.md` för IP-referens.

## Steg 1: Öppna Cursor Chat

Det finns flera sätt att öppna Chat i Cursor:

- **Ctrl+L** (eller Cmd+L på Mac) - Öppnar Chat-panelen
- **Ctrl+Shift+L** - Öppnar Composer (för större koduppgifter)
- Klicka på **Chat-ikonen** i sidopanelen (vänster sida)

## Steg 2: Verifiera att modellen används

### Kontrollera aktuell modell:

1. Öppna Chat (Ctrl+L)
2. Titta på modellindikatorn längst upp i Chat-fönstret
3. Den bör visa `qwen3:32b` eller din konfigurerade modell

### Om fel modell visas:

1. Tryck **Ctrl+Shift+P** (Command Palette)
2. Sök efter: **"Cursor: Select Model"**
3. Välj din konfigurerade modell (`qwen3:32b`)

## Steg 3: Konfigurera modellen (om inte redan gjort)

### Via Settings UI:

1. Tryck **Ctrl+,** (öppnar Settings)
2. Sök efter **"Models"** eller **"AI"**
3. Hitta **"OpenAI API"** eller **"Custom API"**
4. Konfigurera:
   - **Base URL**: `http://100.67.176.85:11434/v1` (från laptop) eller `http://localhost:11434/v1` (på spark2)
   - **Model**: `qwen3:32b`
   - **API Key**: `ollama` (eller valfritt värde)

### Via settings.json:

Filen finns på: `~/.config/Cursor/User/settings.json`

```json
{
  "cursor.ai.openaiBaseUrl": "http://100.67.176.85:11434/v1",
  "cursor.ai.openaiApiKey": "ollama",
  "cursor.ai.model": "qwen3:32b"
}
```
(OBS: Använd Tailscale IP när Cursor körs på laptop. Se ~/TAILSCALE_SPARK_IPS.md)

## Steg 4: Testa modellen

### Enkelt test:

Skriv i Chat:
```
Skriv en Python-funktion som beräknar summan av en lista
```

### Avancerat test:

```
Skriv en komplett Python-klass för en enkel bankomat med:
- Insättning
- Uttag
- Saldo-kontroll
```

## Användningsområden

### 1. Chat (Ctrl+L)
- Frågor och svar
- Kodexempel
- Förklaringar
- Debugging-hjälp

### 2. Composer (Ctrl+Shift+L)
- Skapa större kodprojekt
- Refaktorera kod
- Lägg till funktioner i flera filer

### 3. Inline Edit
- Markera kod
- Tryck Ctrl+K
- Beskriv ändringen du vill göra

### 4. Tab Completion
- Börja skriva kod
- Modellen föreslår kompletteringar automatiskt

## Felsökning

### Problem: "Connection refused"
**Lösning:**
```bash
# Kontrollera att Ollama körs
systemctl status ollama

# Starta Ollama om den inte körs
sudo systemctl start ollama
```

### Problem: "Model not found"
**Lösning:**
```bash
# Kontrollera tillgängliga modeller
curl http://localhost:11434/v1/models

# Om qwen3:32b saknas, ladda den
ollama pull qwen3:32b
```

### Problem: Cursor använder inte rätt modell
**Lösning:**
1. Öppna Settings (Ctrl+,)
2. Sök efter "Models"
3. Kontrollera att Base URL och Model är korrekt inställt
4. Starta om Cursor

### Problem: Modellen svarar långsamt
**Lösning:**
- Detta är normalt för en 32B-modell
- Överväg att använda en mindre modell för snabbare svar
- Eller vänta medan modellen genererar (den är kraftfull men långsam)

## Tips

1. **Använd specifika prompts**: Ju mer specifik du är, desto bättre svar får du
2. **Använd Composer för större uppgifter**: Den är designad för större kodprojekt
3. **Kombinera med Tab Completion**: Låt modellen hjälpa dig medan du skriver
4. **Testa olika prompts**: Modellen är bra på att förstå olika sätt att beskriva samma sak

## Nuvarande Status

- ✅ Ollama körs på port 11434
- ✅ Qwen3-32B-modellen är laddad
- ✅ OpenAI-kompatibelt API fungerar
- ✅ Cursor settings.json är konfigurerad

## Ytterligare Hjälp

Om du behöver mer hjälp:
- Se `~/CURSOR_OLLAMA_SETUP.md` för detaljerad setup-guide
- Testa API:et direkt: `curl http://localhost:11434/v1/models`
- Kontrollera Ollama-loggar: `journalctl -u ollama -f`
