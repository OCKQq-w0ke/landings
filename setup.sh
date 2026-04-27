#!/usr/bin/env bash
# Один скрипт, який налаштує все:
# 1. Перевірить git і gh (GitHub CLI)
# 2. Залогінить тебе в GitHub (якщо ще не залогінений)
# 3. Створить локальний git-репо
# 4. Створить публічний репо `landings` на твоєму акаунті
# 5. Запушить
# 6. Увімкне GitHub Pages
#
# Запуск:
#   cd ~/Desktop/landings
#   bash setup.sh
#
# Якщо щось пішло не так — кожен крок виводить, що зробив. Просто перезапусти.

set -e

echo "🔧 Перевіряю інструменти…"

# --- git ---
if ! command -v git >/dev/null 2>&1; then
  echo "❌ git не встановлений."
  echo "   Встанови: xcode-select --install   (або https://git-scm.com)"
  exit 1
fi
echo "  ✅ git: $(git --version)"

# --- gh (GitHub CLI) ---
if ! command -v gh >/dev/null 2>&1; then
  echo "⚠️  gh (GitHub CLI) не встановлений."
  echo "   Встановити через Homebrew:"
  echo "     brew install gh"
  echo ""
  read -p "Встановити зараз через brew? [y/N] " yn
  if [[ "$yn" =~ ^[Yy]$ ]]; then
    if ! command -v brew >/dev/null 2>&1; then
      echo "   Спочатку встанови Homebrew: https://brew.sh"
      exit 1
    fi
    brew install gh
  else
    echo "   Окей. Альтернатива — створити репо вручну на github.com,"
    echo "   потім запустити цей скрипт повторно — він підхопить існуючий remote."
    exit 1
  fi
fi
echo "  ✅ gh: $(gh --version | head -1)"

# --- логін ---
if ! gh auth status >/dev/null 2>&1; then
  echo ""
  echo "🔑 Авторизація в GitHub. Зараз відкриється браузер."
  echo "   (Обери: GitHub.com → HTTPS → Login with a web browser)"
  gh auth login -h github.com -p https -w
fi

GH_USER=$(gh api user -q .login)
echo "  ✅ Залогінений як: $GH_USER"

# --- git config (локальний для цього репо, не глобальний) ---
cd "$(dirname "$0")"
echo ""
echo "📁 Робоча папка: $(pwd)"

if [[ ! -f index.html ]]; then
  echo "❌ Немає index.html у поточній папці. Запускай скрипт з кореня репо."
  exit 1
fi

# --- git init ---
if [[ ! -d .git ]]; then
  echo ""
  echo "🆕 Ініціалізую git…"
  git init -q -b main
fi

# Локальна git-конфігурація на випадок якщо глобальна не задана
GIT_EMAIL=$(git config --get user.email || echo "")
if [[ -z "$GIT_EMAIL" ]]; then
  USER_EMAIL=$(gh api user -q .email 2>/dev/null || echo "")
  if [[ -z "$USER_EMAIL" || "$USER_EMAIL" == "null" ]]; then
    USER_EMAIL="${GH_USER}@users.noreply.github.com"
  fi
  git config user.email "$USER_EMAIL"
  git config user.name "$GH_USER"
fi

# --- commit ---
if [[ -z "$(git log --oneline 2>/dev/null)" ]]; then
  echo "💾 Створюю перший коміт…"
  git add -A
  git commit -q -m "initial: landings monorepo"
else
  # Якщо є зміни не в коміті — комітимо
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "💾 Комітжу зміни…"
    git add -A
    git commit -q -m "update"
  fi
fi

# --- remote / repo на GitHub ---
REPO_NAME="landings"

if ! git remote get-url origin >/dev/null 2>&1; then
  if gh repo view "$GH_USER/$REPO_NAME" >/dev/null 2>&1; then
    echo "📡 Репо $GH_USER/$REPO_NAME уже існує. Прив'язую remote…"
    git remote add origin "https://github.com/$GH_USER/$REPO_NAME.git"
  else
    echo "🚀 Створюю публічний репо $GH_USER/$REPO_NAME на GitHub…"
    gh repo create "$REPO_NAME" --public --source=. --remote=origin --description="Static landing pages monorepo"
  fi
fi

# --- push ---
echo ""
echo "⬆️  Пушу на GitHub…"
git push -u origin main

# --- увімкнути Pages ---
echo ""
echo "🌍 Вмикаю GitHub Pages…"
# Спробуємо створити Pages через API. Якщо вже увімкнено — пропустимо.
if gh api "repos/$GH_USER/$REPO_NAME/pages" >/dev/null 2>&1; then
  echo "  ✅ Pages вже увімкнено"
else
  gh api -X POST "repos/$GH_USER/$REPO_NAME/pages" \
    -f "source[branch]=main" \
    -f "source[path]=/" \
    >/dev/null && echo "  ✅ Pages увімкнено" || echo "  ⚠️  Не вдалось увімкнути автоматично — увімкни вручну: Settings → Pages → Source: main / root"
fi

echo ""
echo "🎉 Готово!"
echo ""
echo "   Репо:      https://github.com/$GH_USER/$REPO_NAME"
echo "   Сайт:      https://$GH_USER.github.io/$REPO_NAME/"
echo "   site6:     https://$GH_USER.github.io/$REPO_NAME/site6/"
echo ""
echo "   ⏳ Перший білд Pages триває 30–90 секунд. Перевір через хвилину."
echo ""
echo "Як додати наступний лендінг:"
echo "   ./add-landing.sh ~/Downloads/promo.html my-promo \"Опис\""
echo "   git push"
