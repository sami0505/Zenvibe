#!/usr/bin/env bash
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CIPHER_DIR="${YTCIPHER_DIR:-${ROOT_DIR}/yt-cipher}"

if [[ -f "${ROOT_DIR}/.env" ]]; then
    set -a
    source "${ROOT_DIR}/.env"
    set +a
fi

export HOST="${YTCIPHER_HOST:-127.0.0.1}"
export PORT="${YTCIPHER_PORT:-8001}"
export OVERRIDE_SCRIPT_VARIANT="${OVERRIDE_SCRIPT_VARIANT:-IAS}"
export YTCIPHERSERVERURL="http://${HOST}:${PORT}"
export API_TOKEN="${YTCIPHERSERVERPASSWORD:-}"

cd -- "${CIPHER_DIR}"
deno run --allow-net --allow-read --allow-write --allow-env --env server.ts &
cipher_pid=$!

cleanup() {
    kill "${cipher_pid}" 2>/dev/null || true
}

trap 'cleanup; exit 130' INT TERM
trap cleanup EXIT
sleep 2

cd -- "${ROOT_DIR}"
while true; do
    java --enable-native-access=ALL-UNNAMED -jar bot.jar
    sleep 2
done
