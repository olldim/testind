# 🚀 Швидкий старт (5 хвилин)

## Для нетерпимих 😄

### Перший запуск

#### 1️⃣ Налаштуйте MySQL

```bash
# Імпортуйте схему
mysql -u root -p < backend/database/schema.sql
```

**Або вручну в MySQL:**
```sql
CREATE DATABASE college_app;
USE college_app;
-- скопіюйте вміст backend/database/schema.sql
```

#### 2️⃣ Запустіть Backend

```bash
cd backend
npm install
# Відредагуйте .env з вашим MySQL паролем
npm start
```

Очікуйте: `Server is running on port 3000`

#### 3️⃣ Запустіть Flutter App

```bash
# В іншому терміналі
flutter pub get
# Відредагуйте IP адресу в lib/services/api_service.dart
# Заміняючи localhost на ваш IP (наприклад 192.168.1.100)
flutter run
```

#### 4️⃣ Логіньтесь

```
Логін: student1
Пароль: password
```

---

## Основні команди

```bash
# Frontend
flutter run           # запуск
flutter run -v        # вербозний режим
flutter clean         # очистка

# Backend
npm start             # запуск
npm run dev           # запуск з autoreload
npm test              # тести (якщо є)

# Database
mysql -u root -p                          # вхід в MySQL
mysql -u root -p < backend/database/schema.sql  # імпорт
mysql -u root -p college_app              # вхід в БД
SHOW TABLES;                              # список таблиць
SELECT * FROM users;                      # користувачі
```

---

## Найпоширеніші проблеми

| Проблема | Рішення |
|----------|---------|
| "Connection refused" | Backend не запущений: `npm start` в папці `backend` |
| "Database doesn't exist" | Імпортуйте схему: `mysql -u root -p < backend/database/schema.sql` |
| "Invalid token" | Залогіньтесь знову, токен може вийти |
| "App can't reach server" | Перевірте IP адресу в `api_service.dart` |
| "MySQL password wrong" | Оновіть `.env` файл в backend папці |

---

## Тестові облікові дані

| Login | Password |
|-------|----------|
| student1 | password |
| student2 | password |
| student3 | password |

---

## Структура за 30 секунд

```
📁 industry/
├── 📁 lib/              👈 Frontend (Flutter)
│   ├── main.dart        - Точка входу
│   ├── screens/         - UI екрани
│   ├── services/        - API + Storage
│   └── providers/       - State management
│
├── 📁 backend/          👈 Backend (Node.js)
│   ├── server.js        - Точка входу
│   ├── routes/          - API маршрути
│   ├── controllers/     - Логіка
│   ├── middleware/      - JWT
│   ├── config/          - БД конфіг
│   ├── database/        - SQL схема
│   ├── .env             - Змінні окружаючого середовища
│   └── package.json     - Залежності
│
└── 📄 README.md         - Повна документація
```

---

## Послідовність дій

1. ✅ MySQL запущена
2. ✅ База даних створена (`college_app`)
3. ✅ Backend запущений на `http://localhost:3000`
4. ✅ IP адреса в Flutter оновлена
5. ✅ Flutter app запущена
6. ✅ Логіньтесь з `student1/password`
7. ✅ Profit! 🎉

---

## Де взяти більше інформації?

- 📖 [README.md](README.md) - Повна документація
- 🏗️ [ARCHITECTURE.md](ARCHITECTURE.md) - Архітектура
- 📝 [INSTALLATION.md](INSTALLATION.md) - Детальна установка

---

## Доступні функції

- ✅ Авторизація з логіном/паролем
- ✅ Профіль користувача
- ✅ Список новин з деталями
- ✅ Гортання картинок в новинах
- ✅ Посилання в новинах
- ✅ Голосування (активні + завершені)
- ✅ Один голос на користувача
- ✅ Відсоток голосів

---

**Готово! Вам потрібна допомога? Перевірте INSTALLATION.md для деталей.** 📚
