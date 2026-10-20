#!/usr/bin/env bash
# Installation de moulie : cherche l'adresse actuelle du serveur, puis
# lance son script d'installation.
#   curl -sL https://raw.githubusercontent.com/karl-francisco-eu/moulie-relay/main/install.sh | bash
server=$(curl -fsSL "https://raw.githubusercontent.com/karl-francisco-eu/moulie-relay/main/url.txt?$(date +%s)" | head -1)
case "$server" in
    https://*) curl -fsSL "$server/install.sh" | bash ;;
    *) echo "Serveur introuvable pour l'instant. Réessaie dans une minute." >&2; exit 1 ;;
esac
