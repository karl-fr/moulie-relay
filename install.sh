#!/usr/bin/env bash
# Installation de moulie : cherche l'adresse actuelle du serveur, puis
# lance son script d'installation.
#   curl -sL https://raw.githubusercontent.com/karl-francisco-eu/moulie-relay/main/install.sh | bash

# L'API GitHub donne toujours la dernière adresse ; raw.githubusercontent
# peut garder l'ancienne en cache jusqu'à 5 minutes (secours si l'API refuse).
find_server() {
    local url
    url=$(curl -fsSL --max-time 10 -H "Accept: application/vnd.github.raw" \
        "https://api.github.com/repos/karl-francisco-eu/moulie-relay/contents/url.txt" 2>/dev/null | head -1)
    case "$url" in https://*) echo "$url"; return ;; esac
    curl -fsSL --max-time 10 "https://raw.githubusercontent.com/karl-francisco-eu/moulie-relay/main/url.txt?$(date +%s)" 2>/dev/null | head -1
}

# Juste après un redémarrage, la nouvelle adresse met jusqu'à 30 s à répondre.
for essai in 1 2 3 4 5 6 7 8 9 10; do
    server=$(find_server)
    case "$server" in
        https://*)
            if curl -fsS -o /dev/null --max-time 10 "$server/robots.txt" 2>/dev/null; then
                curl -fsSL --retry 3 --retry-delay 5 --retry-all-errors "$server/install.sh" | bash
                exit $?
            fi ;;
    esac
    [ "$essai" = 1 ] && echo "Le serveur vient sans doute de redémarrer : nouvel essai toutes les 15 s..." >&2
    sleep 15
done
echo "Serveur injoignable pour l'instant. Réessaie dans quelques minutes, ou préviens l'admin." >&2
exit 1
