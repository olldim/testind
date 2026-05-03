# ❓ Часто Задавані Запитання (FAQ)

## Встановлення та запуск

### P: Як встановити додаток?
**О:** Дивіться [QUICK_START.md](QUICK_START.md) для швидкого старту або [INSTALLATION.md](INSTALLATION.md) для детальної інструкції.

### P: Які є системні вимоги?
**О:** 
- Node.js v16+
- MySQL v5.7+
- Flutter v3.11+
- Мінімум 4 GB RAM, 500 MB вільного місця

### P: Чи потрібен Mac для розробки iOS?
**О:** Так, для розробки iOS потрібен Mac. Для Android достатньо Windows, macOS або Linux.

### P: Як змінити порт сервера?
**О:** Відредагуйте `backend/.env`:
```
PORT=3000  # Змініть на потрібний порт
```

### P: Як підключитися до MySQL на іншій машині?
**О:** Відредагуйте `backend/.env`:
```
DATABASE_HOST=192.168.1.100  # IP адреса MySQL сервера
DATABASE_USER=root
DATABASE_PASSWORD=your_password
```

---

## Авторизація

### P: Як додати нового користувача?
**О:** Дивіться [ADMIN.md#Додавання нового користувача](ADMIN.md)

```sql
INSERT INTO users (login, password, full_name, `group`) 
VALUES ('new_login', '$2a$10$...', 'ПІБ', 'Група');
```

### P: Як змінити пароль?
**О:** 
```bash
# Генеруємо новий хешований пароль
node backend/generate-password.js

# Оновлюємо в БД
mysql -u root -p
UPDATE users SET password = 'NEW_HASH' WHERE login = 'student1';
```

### P: Як розблокувати користувача?
**О:** Видаліть голоси та заново залогіньтесь або видаліть користувача та створіть нового.

### P: Як встановити експрава для адміністратора?
**О:** Це потребує розширення функціональності. Планується в v2.0

### P: Чому я не можу залогінитися?
**О:** Перевірте:
- [ ] Логін та пароль правильні
- [ ] MySQL запущена
- [ ] Backend запущений
- [ ] IP адреса правильна

---

## Новини

### P: Як додати нову новину?
**О:** Дивіться [ADMIN.md#Додавання нової новини](ADMIN.md)

```sql
INSERT INTO news (title, description, content) 
VALUES ('Заголовок', 'Опис', 'Повна стаття');
```

### P: Як додати картинки до новини?
**О:**
```sql
INSERT INTO news_images (news_id, image_url) 
VALUES (1, 'https://example.com/image.jpg');
```

### P: Де зберігати картинки?
**О:** На сервері за допомогою URL. Для більшого масштабування используйте AWS S3 або інший cloud storage.

### P: Яка максимальна кількість картинок?
**О:** Не обмежена, але рекомендується не більше 10 для оптимізації.

### P: Чи можна редагувати новину після публікації?
**О:** Так:
```sql
UPDATE news SET title = 'Новий заголовок' WHERE id = 1;
```

### P: Як видалити новину?
**О:**
```sql
DELETE FROM news WHERE id = 1;
```

---

## Голосування

### P: Як створити голосування?
**О:** Дивіться [ADMIN.md#Додавання нового голосування](ADMIN.md)

```sql
INSERT INTO polls (question, is_active) VALUES ('Питання?', true);
INSERT INTO poll_options (poll_id, text) VALUES (1, 'Варіант 1');
```

### P: Як завершити голосування?
**О:**
```sql
UPDATE polls SET is_active = false WHERE id = 1;
```

### P: Як видалити голос користувача?
**О:**
```sql
DELETE FROM poll_votes WHERE poll_id = 1 AND user_id = 1;
```

### P: Як рекомендується не давати користувачу голосувати?
**О:** Можна видалити користувача або блокувати його (планується в v1.1).

### P: Як отримати результати голосування?
**О:**
```sql
SELECT po.text, COUNT(pv.id) as votes,
  ROUND(COUNT(pv.id) * 100.0 / 
    (SELECT COUNT(*) FROM poll_votes WHERE poll_id = po.poll_id), 1) as percentage
FROM poll_options po
LEFT JOIN poll_votes pv ON po.id = pv.option_id
WHERE po.poll_id = 1
GROUP BY po.id
ORDER BY votes DESC;
```

---

## Розробка

### P: Як запустити додаток у режимі розробки?
**О:**
```bash
# Backend
cd backend
npm run dev

# Flutter
flutter run
```

### P: Як включити debug режим?
**О:**
```bash
# Backend
NODE_DEBUG=* npm start

# Flutter
flutter run -v
```

### P: Як очистити кеш?
**О:**
```bash
flutter clean
flutter pub get
```

### P: Як додати нову залежність?
**О:**
```bash
# Flutter
flutter pub add package_name

# Node.js
npm install package_name
```

### P: Як запустити тести?
**О:**
```bash
# Flutter
flutter test

# Node.js (якщо є)
npm test
```

---

## Безпека

### P: Чи безпечно зберігати пароль в SharedPreferences?
**О:** Так, SharedPreferences шифрується на рівні ОС. Токен, а не пароль, зберігається.

### P: Як змінити JWT Secret?
**О:**
```
# backend/.env
JWT_SECRET=new_secret_key_here
```

### P: Чи потрібен HTTPS?
**О:** Так, в продакшені обов'язково. На розробку можна HTTP.

### P: Як захистити API від brute-force атак?
**О:** Планується додавання rate limiting в v1.1

### P: Як забезпечити GDPR compliance?
**О:** Потребує розширення функціональності. Планується в v2.0

---

## Помилки

### P: "Connection refused"
**О:** Backend не запущений. Запустіть:
```bash
cd backend
npm start
```

### P: "Database doesn't exist"
**О:** Імпортуйте схему:
```bash
mysql -u root -p < backend/database/schema.sql
```

### P: "Invalid token"
**О:** Токен вийшов з дії. Залогіньтесь заново.

### P: "CORS error"
**О:** IP адреса неправильна. Перевірте `api_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:3000/api';
```

### P: "No internet connection"
**О:** Перевірте підключення та синтаксис IP адреси.

### P: "MySQL authentication failed"
**О:** Перевірте пароль в `.env` файлі.

---

## Тестування

### P: Як протестувати API?
**О:** Используйте Postman або curl:
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"login":"student1","password":"password"}'
```

### P: Як отримати JWT токен для тестування?
**О:** Залогіньтесь:
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"login":"student1","password":"password"}' | jq .token
```

### P: Як тестувати на емуляторі Android?
**О:**
```bash
flutter emulators --launch Pixel_5_API_30
flutter run
```

### P: Як тестувати на реальному пристрої?
**О:**
```bash
# Підключіть пристрій USB та дозвольте USB debugging
flutter devices
flutter run -d DEVICE_ID
```

---

## Перформанс

### P: Додаток повільно завантажується
**О:**
1. Перевірте інтернет
2. Перевірте MySQL індекси
3. Включіть caching

### P: Як оптимізувати завантаження?
**О:**
- Додавати пагінацію для новин
- Компресувати картинки
- Кешувати дані на клієнті

### P: Сервер часто крешується
**О:**
- Перевірте логи: `tail -f backend/server.log`
- Збільшите RAM
- Оптимізуйте БД запити

---

## Розширення функціональності

### P: Як додати нову функцію?
**О:**
1. Додайте API endpoint в backend
2. Додайте Model для нових даних
3. Додайте Service у Flutter
4. Додайте UI в screens
5. Протестуйте

### P: Як змінити колірну схему?
**О:** Змініть в `lib/main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.red,  // Змініть колір
),
```

### P: Як додати нову мову?
**О:** Потребує `intl` пакету. Планується в v1.1

### P: Як додати dark mode?
**О:**
```dart
themeMode: ThemeMode.dark,
darkTheme: ThemeData.dark(),
```

---

## Масштабування

### P: Як масштабувати додаток на більше користувачів?
**О:**
- Додайте caching (Redis)
- Оптимізуйте БД запити
- Використайте CDN для картинок
- Розділіть backend на мікросервіси

### P: Як публікувати на App Store і Google Play?
**О:** Дивіться офіційну документацію:
- [Flutter App Store Publishing](https://flutter.dev/docs/deployment/ios)
- [Flutter Google Play Publishing](https://flutter.dev/docs/deployment/android)

### P: Як моніторити рабочий додаток?
**О:** Используйте:
- Sentry для error tracking
- New Relic для performance
- Firebase Analytics для user analytics

---

## Технічна підтримка

### P: Де я можу отримати допомогу?
**О:**
- 📖 Дивіться документацію: [INDEX.md](INDEX.md)
- 🐛 Повідомте про помилку: GitHub Issues
- 💬 Напишіть в Slack: #support

### P: Як я можу внести свій вклад?
**О:**
1. Fork репозиторій
2. Створіть feature branch
3. Робіть коміти
4. Push до branch
5. Відкрийте Pull Request

### P: Чи можна використовувати це в комерційних цілях?
**О:** Залежить від ліцензії. Зазвичай MIT ліцензія дозволяє комерційне використання.

---

## Інші запитання

### P: Чи сумісне це з iOS?
**О:** Так, це Flutter додаток, сумісний з iOS і Android.

### P: Чи можна запустити це локально без інтернету?
**О:** Так, але потрібна локальна MySQL база даних.

### P: Чи простирається на веб-версію?
**О:** Flutter Web планується в v2.0

### P: Коли буде v2.0?
**О:** Планується на Q4 2024 року

### P: Де я можу побачити код?
**О:** Код знаходиться в папках `lib/` та `backend/`

---

## Контакт

**Не знайшли відповідь?** Напишіть нам:
- 📧 support@college.app
- 💬 Slack: #support
- 🐛 GitHub Issues

---

**Останнє оновлення: 2024-01-01**

Дякуємо за використання нашого додатку! 🙏
