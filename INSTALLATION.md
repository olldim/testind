# Гайд з встановлення та запуску

## Вимоги перед стартом

- **Node.js** (v16 або вище): https://nodejs.org/
- **MySQL** (v5.7 або вище): https://www.mysql.com/downloads/
- **Flutter** (v3.11 або вище): https://flutter.dev/docs/get-started/install
- **Emulator** або фізичний пристрій Android/iOS (для Flutter)

---

## Крок 1: Установка та конфігурація MySQL

### На Windows

1. **Завантажте MySQL**: https://dev.mysql.com/downloads/mysql/
2. **Встановіть MySQL Server**
3. **Запам'ятайте**:
   - Username: `root` (за замовчуванням)
   - Password: (встановіть сам)

### На macOS (з Homebrew)

```bash
brew install mysql
brew services start mysql
```

### На Linux (Ubuntu/Debian)

```bash
sudo apt-get install mysql-server
sudo mysql_secure_installation
```

---

## Крок 2: Створення бази даних

1. **Відкрийте MySQL в терміналі**:
   ```bash
   mysql -u root -p
   # Введіть ваш пароль
   ```

2. **Імпортуйте схему**:
   ```bash
   # Залишаючись у MySQL
   source /path/to/industry/backend/database/schema.sql;
   # або
   mysql -u root -p college_app < /path/to/industry/backend/database/schema.sql
   ```

3. **Перевірте результат**:
   ```sql
   USE college_app;
   SHOW TABLES;
   SELECT * FROM users;
   ```

---

## Крок 3: Запуск Backend (Node.js)

1. **Відкрийте папку backend**:
   ```bash
   cd /path/to/industry/backend
   ```

2. **Встановіть залежності**:
   ```bash
   npm install
   ```

3. **Налаштуйте `.env` файл**:
   ```
   DATABASE_HOST=localhost
   DATABASE_USER=root
   DATABASE_PASSWORD=YOUR_MYSQL_PASSWORD
   DATABASE_NAME=college_app
   JWT_SECRET=your_secret_key_here
   PORT=3000
   ```

4. **Запустіть сервер**:
   ```bash
   npm start
   ```

   Повинен побачити:
   ```
   Server is running on port 3000
   ```

---

## Крок 4: Запуск Flutter App

### Налаштування IP адреси

1. **Знайдіть вашу IP адресу**:
   - На Windows: `ipconfig` в CMD
   - На macOS/Linux: `ifconfig` або `ip addr`
   - Зазвичай це щось типу `192.168.x.x` або `10.x.x.x`

2. **Оновіть `lib/services/api_service.dart`**:
   ```dart
   static const String baseUrl = 'http://YOUR_IP_ADDRESS:3000/api';
   ```

   Приклад:
   ```dart
   static const String baseUrl = 'http://192.168.1.100:3000/api';
   ```

   **Для Android Emulator** (якщо не працює):
   ```dart
   static const String baseUrl = 'http://10.0.2.2:3000/api';
   ```

3. **Встановіть залежності Flutter**:
   ```bash
   cd /path/to/industry
   flutter pub get
   ```

4. **Запустіть додаток**:
   ```bash
   flutter run
   ```

---

## Крок 5: Тестування

### Облікові дані для тестування

```
Логін: student1
Пароль: password

Логін: student2
Пароль: password

Логін: student3
Пароль: password
```

### Тестові дії

1. ✅ Вхід з правильними даними
2. ✅ Перегляд профілю на головній сторінці
3. ✅ Перегляд списку новин
4. ✅ Клік на новину для перегляду деталей
5. ✅ Гортання картинок у новині
6. ✅ Клік на посилання у новині
7. ✅ Голосування в активному голосуванні
8. ✅ Перегляд завершених голосувань
9. ✅ Вихід з аккаунту

---

## Виправлення проблем

### "Не можу підключитися до сервера"

**Причина**: IP адреса неправильна або сервер не запущений

**Рішення**:
```bash
# Переконайтесь, що backend запущений
cd backend
npm start

# Перевірте правильність IP адреси
ipconfig  # Windows
ifconfig  # macOS/Linux
```

### "MySQL Connection Error"

**Причина**: MySQL не запущена або .env налаштований неправильно

**Рішення**:
```bash
# Запустіть MySQL
mysql -u root -p

# Перевірте .env файл
cat backend/.env

# Переконайтесь, що база даних створена
mysql -u root -p
SHOW DATABASES;
```

### "Flutter compilation errors"

**Причина**: Залежності не встановлені

**Рішення**:
```bash
flutter clean
flutter pub get
flutter run
```

### "Emulator is not available"

**Рішення**: Використовуйте физичний пристрій або запустіть Android Studio emulator

```bash
# Список доступних пристроїв
flutter devices

# Запуск на конкретному пристрої
flutter run -d DEVICE_ID
```

---

## Розробка та налаштування

### Для розробки Backend

```bash
cd backend
npm run dev
# Сервер буде перезавантажуватися при змінах
```

### Для розробки Frontend

```bash
flutter run
# Використовуйте Hot Reload (R) та Hot Restart (Shift+R)
```

---

## Структура файлів

```
backend/
├── server.js                 # Основна точка входу
├── .env                      # Змінні окружаючого середовища
├── package.json              # Залежності Node.js
├── config/
│   └── database.js           # Конфіг бази даних
├── middleware/
│   └── auth.js               # JWT middleware
├── controllers/
│   ├── authController.js
│   ├── newsController.js
│   └── pollsController.js
├── routes/
│   ├── auth.js
│   ├── news.js
│   └── polls.js
└── database/
    └── schema.sql            # SQL схема БД
```

---

## Порти та IP адреси

- **Backend**: `http://localhost:3000`
- **Database**: `localhost:3306`
- **Flutter App**: Звичайно запускається в emulator або на пристрої

---

## Контакт та підтримка

При виникненні проблем:
1. Переконайтесь, що всі сервіси запущені (MySQL, Node.js)
2. Перевірте логи помилок в терміналі
3. Переконайтесь у правильності налаштування `.env` файлу
4. Очистіть Flutter кеш: `flutter clean`

---

**Готово! Тепер ви можете користуватися додатком.** 🎉
