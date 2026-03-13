#!/bin/bash
# OpenClaw WhatsApp Setup Script
# Kör detta på spark2

set -e

echo "=== OpenClaw WhatsApp Setup ==="
echo ""

# Steg 1: Kontrollera OpenClaw-status
echo "1. Kontrollerar OpenClaw-status..."
cd ~/src/openclaw || { echo "ERROR: ~/src/openclaw finns inte!"; exit 1; }

if ! docker compose ps | grep -q "openclaw-gateway.*Up"; then
    echo "   Startar OpenClaw gateway..."
    docker compose up -d openclaw-gateway
    sleep 5
else
    echo "   ✓ OpenClaw gateway körs redan"
fi

# Steg 2: Fråga efter telefonnummer
echo ""
echo "2. WhatsApp-konfiguration"
read -p "   Ange ditt WhatsApp-nummer (E.164 format, t.ex. +46701234567): " PHONE_NUMBER

if [[ ! "$PHONE_NUMBER" =~ ^\+[0-9]{10,15}$ ]]; then
    echo "   ⚠ Varning: Numret ser inte ut som E.164-format (+46701234567)"
    read -p "   Fortsätt ändå? (y/n): " CONTINUE
    if [[ ! "$CONTINUE" =~ ^[yY]$ ]]; then
        echo "   Avbruten."
        exit 1
    fi
fi

# Steg 3: Backup och uppdatera config
echo ""
echo "3. Uppdaterar OpenClaw-konfiguration..."
CONFIG_FILE="$HOME/.openclaw/openclaw.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "   ERROR: $CONFIG_FILE finns inte!"
    exit 1
fi

# Backup
cp "$CONFIG_FILE" "${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "   ✓ Backup skapad"

# Uppdatera med jq
jq --arg phone "$PHONE_NUMBER" '.channels.whatsapp = {
  "enabled": true,
  "dmPolicy": "allowlist",
  "allowFrom": [$phone],
  "groupPolicy": "allowlist",
  "groupAllowFrom": [$phone]
}' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

echo "   ✓ WhatsApp-konfiguration tillagd"
echo "   Tillåtna nummer: $PHONE_NUMBER"

# Steg 4: Logga in på WhatsApp
echo ""
echo "4. WhatsApp-inloggning (QR-kod)"
echo "   Öppna WhatsApp på din mobil → Inställningar → Länkade enheter → Länka en enhet"
echo "   Skanna QR-koden som visas nedan:"
echo ""
echo "   [Tryck Enter när du är redo att visa QR-koden...]"
read

docker compose run --rm openclaw-cli channels login --channel whatsapp

# Steg 5: Starta om gatewayen
echo ""
echo "5. Startar om gatewayen..."
docker compose restart openclaw-gateway
sleep 3

# Steg 6: Verifiera
echo ""
echo "6. Verifierar installationen..."
echo ""
echo "   Kanalstatus:"
docker compose run --rm openclaw-cli channels status --probe 2>&1 | grep -i whatsapp || echo "   (kör 'docker compose run --rm openclaw-cli channels status --probe' för detaljer)"

echo ""
echo "=== Klart! ==="
echo ""
echo "Nästa steg:"
echo "1. Skicka ett testmeddelande till WhatsApp-numret från din mobil"
echo "2. OpenClaw bör svara automatiskt"
echo ""
echo "För att kolla loggar:"
echo "  docker compose logs openclaw-gateway --tail 50 -f"
echo ""
