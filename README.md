# Додаток для коледжу

Мобільний додаток на Flutter для студентів коледжу з функціями авторизації, перегляду новин та голосування.

## Структура проекту

```
industry/
├── lib/                          # Flutter додаток
│   ├── main.dart
│   ├── models/                   # Моделі даних
│   │   ├── user.dart
│   │   ├── news.dart
│   │   └── poll.dart
│   ├── services/                 # Сервіси для API та зберігання
│   │   ├── api_service.dart
│   │   └── storage_service.dart
│   ├── providers/                # State management
│   │   └── auth_provider.dart
│   └── screens/                  # UI екрани
│       ├── login_screen.dart
│       ├── home_screen.dart
│       ├── home_tab.dart
│       ├── news_tab.dart
│       ├── news_detail_screen.dart
│       └── polls_tab.dart
├── backend/                      # Node.js backend
│   ├── server.js
│   ├── package.json
│   ├── .env
│   ├── config/                   # Конфігурація
│   │   └── database.js
│   ├── middleware/               # Middleware
│   │   └── auth.js
│   ├── controllers/              # Контролери
│   │   ├── authController.js
│   │   ├── newsController.js
│   │   └── pollsController.js
│   ├── routes/                   # API маршрути
│   │   ├── auth.js
│   │   ├── news.js
│   │   └── polls.js
│   └── database/                 # SQL схема
│       └── schema.sql
└── README.md
```

## Налаштування

### Backend (Node.js)

1. **Встановіть залежності**:
   ```bash
   cd backend
   npm install
   ```

2. **Налаштуйте базу даних**:
   - Встановіть MySQL
   - Створіть базу даних та імпортуйте схему:
   ```bash
   mysql -u root -p < database/schema.sql
   ```

3. **Налаштуйте .env файл**:
   ```
   DATABASE_HOST=localhost
   DATABASE_USER=root
   DATABASE_PASSWORD=your_password
   DATABASE_NAME=college_app
   JWT_SECRET=your_jwt_secret_key
   PORT=3000
   ```

4. **Запустіть сервер**:
   ```bash
   npm start
   # або для розробки з автоперезавантаженням:
   npm run dev
   ```

### Flutter (Mobile App)

1. **Встановіть Flutter**: https://flutter.dev/docs/get-started/install

2. **Встановіть залежності**:
   ```bash
   flutter pub get
   ```

3. **Налаштуйте IP адресу сервера**:
   - Відредагуйте `lib/services/api_service.dart`
   - Змініть `baseUrl` на ваш IP адресу або домен:
   ```dart
   static const String baseUrl = 'http://your_server_ip:3000/api';
   ```

4. **Запустіть додаток**:
   ```bash
   flutter run
   ```

## API Endpoints

### Авторизація
- `POST /api/auth/login` - Вхід в аккаунт
  - Body: `{ "login": "student1", "password": "password" }`
  - Response: `{ "token": "...", "user": {...} }`

### Новини
- `GET /api/news` - Отримати список новин
  - Header: `Authorization: Bearer token`
- `GET /api/news/:id` - Отримати деталі новини

### Голосування
- `GET /api/polls` - Отримати список голосувань
- `POST /api/polls/:id/vote` - Проголосувати
  - Body: `{ "option_id": 1 }`

## Приклади даних для логіну

```
Login: student1
Password: password

Login: student2
Password: password

Login: student3
Password: password
```

## Функціональність

### Екран авторизації
- Вхід з логіном та паролем
- Градієнтна схема синього кольору
- Обробка помилок

### Головна сторінка
- Профіль користувача (ПІБ, Група)
- Інформаційне повідомлення

### Вкладка "Новини"
- Список новин з короткою частиною
- Натискання на новину відкриває повні деталі
- Гортання картинок через carousel
- Посилання на ресурси
- Оновлення списку (pull-to-refresh)

### Вкладка "Голосування"
- Активні голосування в топі
- Завершені голосування внизу
- Один голос на одне голосування
- Відсоток голосів для кожного варіанта
- Візуальне відображення прогресу

## Вимоги

- **Flutter**: ^3.11.5
- **Node.js**: ^16.0.0
- **MySQL**: ^5.7.0
- **Dart**: ^3.11.5

## Залежності Flutter

- `http: ^1.1.0` - HTTP запити
- `shared_preferences: ^2.2.2` - Локальне зберігання
- `provider: ^6.0.0` - State management
- `carousel_slider: ^4.2.1` - Гортання картинок
- `url_launcher: ^6.1.0` - Відкриття посилань

## Залежності Node.js

- `express: ^4.18.2` - Web framework
- `mysql2: ^3.6.0` - MySQL драйвер
- `dotenv: ^16.3.1` - Змінні окружаючого середовища
- `bcryptjs: ^2.4.3` - Хешування паролей
- `jsonwebtoken: ^9.1.0` - JWT токени
- `cors: ^2.8.5` - CORS
- `express-validator: ^7.0.0` - Валідація
- `multer: ^1.4.5-lts.1` - Завантаження файлів

## Примітки

- Паролі в базі даних повинні бути захешовані за допомогою bcryptjs
- JWT токени дійсні 7 днів
- Один користувач може голосувати тільки один раз за голосування
- Картинки зберігаються на сервері з URL посиланнями

## Виправлення та розвиток

Щоб додати більше функціональності:
1. Розширити контролери для нових функцій
2. Додати нові маршрути в routes/
3. Оновити моделі в lib/models/
4. Додати нові екрани в lib/screens/

Для розробки використовуйте `nodemon` на backend та `flutter run` на frontend.
