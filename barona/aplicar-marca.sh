#!/usr/bin/env bash
# Barona Remoto: aplica nombre, servidor, llave e iconos sobre el codigo fuente de RustDesk.
# Uso (desde la raiz del repo, con submodulos ya descargados): bash barona/aplicar-marca.sh
set -euo pipefail
NOMBRE="BaronaRemoto"
SERVIDOR="remoto.baronaenterprise.com"
LLAVE="nSfzxgrdKb5xAcEvnlL+yPyWwPgjQviQRwPHA9ZaZFU="
EMPRESA="Barona Enterprise"
COPY="Copyright (c) 2026 Barona Enterprise. Basado en RustDesk (AGPL-3.0), Purslane Tech Pte. Ltd."
B="$(cd "$(dirname "$0")" && pwd)"

cambiar() { # archivo, patron sed; falla si el archivo no cambio
  local f="$1"; shift
  local antes; antes=$(sha1sum "$f")
  sed -i "$@" "$f"
  [ "$antes" != "$(sha1sum "$f")" ] || { echo "ERROR: no se aplico el cambio en $f"; exit 1; }
}

C=libs/hbb_common/src/config.rs
cambiar "$C" -e "s|APP_NAME: RwLock<String> = RwLock::new(\"RustDesk\".to_owned())|APP_NAME: RwLock<String> = RwLock::new(\"$NOMBRE\".to_owned())|"
cambiar "$C" -e "s|PROD_RENDEZVOUS_SERVER: RwLock<String> = RwLock::new(\"\".to_owned())|PROD_RENDEZVOUS_SERVER: RwLock<String> = RwLock::new(\"$SERVIDOR\".to_owned())|"
cambiar "$C" -e "s|RENDEZVOUS_SERVERS: &\[&str\] = &\[\"rs-ny.rustdesk.com\"\]|RENDEZVOUS_SERVERS: \&[\&str] = \&[\"$SERVIDOR\"]|"
cambiar "$C" -e "s|RS_PUB_KEY: &str = \"[^\"]*\"|RS_PUB_KEY: \&str = \"$LLAVE\"|"

cambiar Cargo.toml -e "s|^LegalCopyright = .*|LegalCopyright = \"$COPY\"|" \
  -e "s|^ProductName = \"RustDesk\"|ProductName = \"Barona Remoto\"|" \
  -e "s|^FileDescription = .*|FileDescription = \"Barona Remoto - Escritorio remoto\"|"

cambiar Cargo.toml -e "s|^ProductName = \"Barona Remoto\"|&\nCompanyName = \"$EMPRESA\"|"
cambiar libs/portable/Cargo.toml -e "s|^LegalCopyright = .*|LegalCopyright = \"$COPY\"|" \
  -e "s|^ProductName = \"RustDesk\"|ProductName = \"Barona Remoto\"\nCompanyName = \"$EMPRESA\"|" \
  -e "s|^FileDescription = .*|FileDescription = \"Barona Remoto - Escritorio remoto\"|" \
  -e "s|^OriginalFilename = .*|OriginalFilename = \"barona-remoto.exe\"|" \
  -e "s|^description = \"RustDesk Remote Desktop\"|description = \"Barona Remoto\"|"

R=flutter/windows/runner/Runner.rc
cambiar "$R" -e "s|VALUE \"CompanyName\", \"[^\"]*\"|VALUE \"CompanyName\", \"$EMPRESA\"|" \
  -e "s|VALUE \"FileDescription\", \"[^\"]*\"|VALUE \"FileDescription\", \"Barona Remoto - Escritorio remoto\"|" \
  -e "s|VALUE \"LegalCopyright\", \"[^\"]*\"|VALUE \"LegalCopyright\", \"$COPY\"|" \
  -e "s|VALUE \"ProductName\", \"[^\"]*\"|VALUE \"ProductName\", \"Barona Remoto\"|"

cambiar flutter/lib/common.dart -e "s|launchUrl(Uri.parse('https://rustdesk.com'));|launchUrl(Uri.parse('https://baronaenterprise.com'));|" \
  -e "s|translate(\"powered_by_me\"),|'Powered by Barona Enterprise',|"

for f in res/icon.ico res/tray-icon.ico flutter/windows/runner/resources/app_icon.ico; do cp "$B/icon.ico" "$f"; done
cp "$B/icon-1024.png" res/icon.png
cp "$B/icon-32.png" res/32x32.png
cp "$B/icon-64.png" res/64x64.png
cp "$B/icon-128.png" res/128x128.png
cp "$B/icon-256.png" "res/128x128@2x.png"
cp "$B/icon.svg" flutter/assets/icon.svg

grep -n "APP_NAME: RwLock\|PROD_RENDEZVOUS_SERVER: RwLock\|RENDEZVOUS_SERVERS:\|RS_PUB_KEY:" "$C"
echo "Marca Barona Remoto aplicada."
