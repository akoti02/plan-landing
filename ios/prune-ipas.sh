#!/usr/bin/env bash
# Prune old iOS Ad Hoc IPAs so this GitHub Pages repo doesn't bloat and slow
# deploys (each IPA is ~12 MB; a deploy that took ~90s crept to 4+ min once ~14
# accumulated).
#
# KEEPS: the latest $KEEP release builds (Tempora-bNN.ipa + manifest-bNN.plist),
# the build referenced by latest.json (always, even if older than the cutoff),
# the non-versioned Tempora.ipa, the dev channel (Tempora-dev.ipa +
# manifest-dev.plist + dev.html), every install*.html / v*.html, the icons, and
# latest.json + manifest.plist.
#
# NOTE: do NOT .gitignore the IPAs — GitHub Pages SERVES the latest few from the
# tree, so they must stay committed. Pruning (not ignoring) is the right tool.
#
# Usage (run after publishing a new build):
#   bash ios/prune-ipas.sh && git add -A && git commit -m "ios: prune old IPAs" && git push
set -euo pipefail
KEEP="${KEEP:-3}"
cd "$(dirname "$0")"   # → ios/

CUR=$(grep -oE '"build"[[:space:]]*:[[:space:]]*[0-9]+' latest.json 2>/dev/null | grep -oE '[0-9]+' | head -1 || echo 0)
nums=$(ls Tempora-b*.ipa 2>/dev/null | sed -E 's/Tempora-b([0-9]+)\.ipa/\1/' | sort -rn)
keep_set=" $CUR $(echo "$nums" | head -n "$KEEP" | tr '\n' ' ') "

for n in $nums; do
  case "$keep_set" in
    *" $n "*) : ;;  # within the keep window or the live build → keep
    *) rm -f "Tempora-b$n.ipa" "manifest-b$n.plist"; echo "pruned b$n" ;;
  esac
done
echo "kept builds:$keep_set (live=$CUR, KEEP=$KEEP)"
