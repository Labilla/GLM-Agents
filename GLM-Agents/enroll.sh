#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail
APP_ROOT="$HOME/.glm-agent"
AUTO_ENC="$APP_ROOT/secrets.json.enc.auto"
AUTO_MAC="$APP_ROOT/secrets.json.enc.auto.mac"
MASTER_KEY="$APP_ROOT/master.key"
DEVICE_ID_FILE="$APP_ROOT/device.id"

mkdir -p "$APP_ROOT"

echo "[INFO] API-Konfiguration erfassen (Eingaben bleiben verborgen)..."
printf "Z.ai API Key (GLM-4.5-Flash): "
stty -echo; IFS= read -r ZAI_KEY; stty echo; printf "\n"

printf "API Base URL [Enter für Default https://api.z.ai/api/paas/v4/chat/completions]: "
IFS= read -r BASE_INP
[[ -z "${BASE_INP:-}" ]] && BASE_INP="https://api.z.ai/api/paas/v4/chat/completions"

printf "GLM Modell [Enter für Default glm-4.5-flash]: "
IFS= read -r MODEL_INP
[[ -z "${MODEL_INP:-}" ]] && MODEL_INP="glm-4.5-flash"

# master key / device id
if [[ ! -f "$MASTER_KEY" ]]; then umask 077; openssl rand -hex 32 > "$MASTER_KEY"; chmod 0600 "$MASTER_KEY"; fi
MASTER=$(cat "$MASTER_KEY" | tr -d '\n')

if [[ -f "$DEVICE_ID_FILE" ]]; then
  DEV=$(cat "$DEVICE_ID_FILE" | tr -d '\n')
else
  DEV=$(cat /proc/sys/kernel/random/boot_id 2>/dev/null || true)
  [[ -z "$DEV" ]] && DEV=$(getprop ro.boot.serialno 2>/dev/null || true)
  [[ -z "$DEV" ]] && DEV=$(getprop ro.serialno 2>/dev/null || true)
  [[ -z "$DEV" ]] && DEV=$(openssl rand -hex 16)
  umask 077; printf "%s" "$DEV" > "$DEVICE_ID_FILE"; chmod 0600 "$DEVICE_ID_FILE"
fi

DERIVED=$(printf "%s" "${MASTER}${DEV}" | openssl dgst -sha256 -binary | base64)

TMP_JSON="$(mktemp)"
chmod 0600 "$TMP_JSON"
printf '%s' "{\"ZAI_API_KEY\":\"$ZAI_KEY\",\"GLM_API_BASE\":\"$BASE_INP\",\"GLM_MODEL\":\"$MODEL_INP\"}" > "$TMP_JSON"
unset ZAI_KEY BASE_INP MODEL_INP

echo "[INFO] Secrets verschlüsseln (AES-256-CBC + PBKDF2 200k)..."
openssl enc -aes-256-cbc -md sha256 -pbkdf2 -iter 200000 -salt -in "$TMP_JSON" -out "$AUTO_ENC" -pass pass:"$DERIVED"
rm -f "$TMP_JSON"; chmod 0600 "$AUTO_ENC"

echo "[INFO] Erzeuge HMAC-SHA256 über Ciphertext..."
openssl dgst -sha256 -hmac "$DERIVED" -binary "$AUTO_ENC" | base64 > "$AUTO_MAC"
chmod 0600 "$AUTO_MAC"

echo "[OK] Secrets gespeichert:"
echo "    $AUTO_ENC"
echo "    $AUTO_MAC"
echo "[OK] Künftige Starts ohne Passphrase."
