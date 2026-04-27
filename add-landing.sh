#!/usr/bin/env bash
# Helper: додає новий лендінг до монорепо.
# Usage:
#   ./add-landing.sh path/to/file.html SLUG "Опис лендінга"
#   ./add-landing.sh ~/Downloads/promo.html summer-promo "Літня акція 2026"
#
# Що робить:
#   1. Створює папку SLUG/
#   2. Копіює HTML як SLUG/index.html
#   3. Додає посилання у вітрину index.html (між маркерами LANDINGS:START/END)
#   4. git add + commit (push робиш сам, на випадок якщо хочеш ще щось доглянути)

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <html-file> <slug> [\"опис\"]"
  exit 1
fi

SRC="$1"
SLUG="$2"
DESC="${3:-}"

if [[ ! -f "$SRC" ]]; then
  echo "❌ Файл не знайдено: $SRC"
  exit 1
fi

if [[ ! "$SLUG" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "❌ Slug має бути lowercase, цифри та дефіси: '$SLUG'"
  exit 1
fi

if [[ -d "$SLUG" ]]; then
  echo "❌ Папка $SLUG/ вже існує"
  exit 1
fi

mkdir -p "$SLUG"
cp "$SRC" "$SLUG/index.html"
echo "✅ Створено $SLUG/index.html"

# Додати в вітрину
NEW_CARD="    <a class=\"card\" href=\"$SLUG/\">
      <div>
        <div class=\"name\">$SLUG</div>
        <div class=\"meta\">${DESC}</div>
      </div>
      <span class=\"arrow\">&rarr;</span>
    </a>
    <!-- LANDINGS:START - не видаляй цей маркер, сюди додаються нові лендінги -->"

# Заміна — на macOS sed -i потребує '' аргумента
if sed --version >/dev/null 2>&1; then
  # GNU sed
  sed -i "s|<!-- LANDINGS:START - не видаляй цей маркер, сюди додаються нові лендінги -->|$NEW_CARD|" index.html
else
  # BSD sed (macOS)
  TMPFILE=$(mktemp)
  awk -v repl="$NEW_CARD" '
    /<!-- LANDINGS:START - не видаляй цей маркер/ { print repl; next }
    { print }
  ' index.html > "$TMPFILE" && mv "$TMPFILE" index.html
fi

echo "✅ Оновлено index.html"

git add "$SLUG/" index.html
git commit -m "add: $SLUG лендінг"
echo ""
echo "🚀 Готово. Тепер запусти:  git push"
