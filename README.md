# Landings

Монорепо зі статичними лендінгами, що публікуються через GitHub Pages.

## URL

- Вітрина: `https://USERNAME.github.io/landings/`
- Конкретний лендінг: `https://USERNAME.github.io/landings/SLUG/`

## Як додати новий лендінг

1. Створи папку зі slug-ім'ям (англ. літери, цифри, `-`), наприклад `summer-promo`.
2. Поклади всередину `index.html` (саме так, не `landing.html` тощо).
3. Усі картинки/CSS/JS — або зовнішні `https://`, або відносні шляхи (`href="styles.css"`, **не** `href="/styles.css"`).
4. Онови корневий `index.html`, додавши посилання у блок між маркерами `LANDINGS:START` / `LANDINGS:END`.
5. Закоміть і запуш:

   ```bash
   git add summer-promo/ index.html
   git commit -m "add: summer-promo"
   git push
   ```

6. Через ~1 хв лендінг буде доступний на `https://USERNAME.github.io/landings/summer-promo/`.

## Структура

```
.
├── .nojekyll          # вимикає Jekyll, інакше папки з _ ігноруються
├── index.html         # вітрина зі списком лендінгів
├── README.md
└── SLUG/
    └── index.html     # обов'язково index.html у корені папки
```

## Чек-ліст для нового лендінга

- [ ] `index.html` у корені папки лендінга
- [ ] Усі шляхи відносні
- [ ] `<title>` та `<meta name="description">` заповнені
- [ ] Перевірено на мобільному (DevTools → Toggle device toolbar)
- [ ] Перевірено в incognito після пушу

## Граблі

| Симптом | Причина | Фікс |
|---|---|---|
| 404 на `/SLUG/` | Немає `index.html` | Перейменуй файл рівно на `index.html` |
| Стилі не вантажаться | Шляхи з `/` на початку | Зроби відносні |
| Папки з `_` не публікуються | Jekyll | Перевір що `.nojekyll` є в корені |
| Сторінка не оновлюється | Кеш CDN | Hard reload (Cmd+Shift+R), почекай 2 хв |
