# 📋 Адміністративна документація

## Управління користувачами

### Додавання нового користувача

```sql
INSERT INTO users (login, password, full_name, `group`) 
VALUES ('new_login', '{HASHED_PASSWORD}', 'ПІБ', 'Група');
```

### Генерування хешованого пароля

```bash
# Запустіть генератор
node backend/generate-password.js
```

Або використайте bcryptjs:
```javascript
const bcrypt = require('bcryptjs');
const hashedPassword = await bcrypt.hash('password123', 10);
console.log(hashedPassword);
```

### Зміна пароля користувача

```sql
UPDATE users 
SET password = '{HASHED_PASSWORD}' 
WHERE login = 'student1';
```

### Блокування користувача

```sql
-- Додайте колону is_active
ALTER TABLE users ADD COLUMN is_active BOOLEAN DEFAULT true;

-- Блокуйте користувача
UPDATE users SET is_active = false WHERE login = 'student1';
```

### Видалення користувача

```sql
DELETE FROM users WHERE login = 'old_student';
```

---

## Управління новинами

### Додавання нової новини

```sql
INSERT INTO news (title, description, content) 
VALUES (
  'Заголовок новини',
  'Короткий опис',
  'Повна стаття з більш детальною інформацією...'
);
```

### Додавання картинок до новини

```sql
INSERT INTO news_images (news_id, image_url) 
VALUES (1, 'https://example.com/image.jpg');

-- Додати ще одну картинку
INSERT INTO news_images (news_id, image_url) 
VALUES (1, 'https://example.com/image2.jpg');
```

### Додавання посилань до новини

```sql
INSERT INTO news_links (news_id, title, url) 
VALUES (
  1, 
  'Назва посилання', 
  'https://example.com/resource'
);
```

### Отримання всіх новин з деталями

```sql
SELECT 
  n.id, n.title, n.description,
  COUNT(DISTINCT ni.id) as image_count,
  COUNT(DISTINCT nl.id) as link_count
FROM news n
LEFT JOIN news_images ni ON n.id = ni.news_id
LEFT JOIN news_links nl ON n.id = nl.news_id
GROUP BY n.id
ORDER BY n.created_at DESC;
```

### Редагування новини

```sql
UPDATE news 
SET title = 'Новий заголовок', 
    description = 'Новий опис'
WHERE id = 1;
```

### Видалення новини (видаляє також картинки та посилання)

```sql
DELETE FROM news WHERE id = 1;
```

### Відновлення картинок та посилань

```sql
-- Картинки видалено, тільки якщо новина видалена
-- Або видалити окремо
DELETE FROM news_images WHERE id = 1;
DELETE FROM news_links WHERE id = 1;
```

---

## Управління голосуванням

### Додавання нового голосування

```sql
INSERT INTO polls (question, is_active) 
VALUES ('Яка ваша улюблена мова?', true);

-- Отримати ID новоствореного голосування
SELECT LAST_INSERT_ID() as poll_id;
```

### Додавання варіантів відповідей

```sql
-- Для ID голосування = 1
INSERT INTO poll_options (poll_id, text) 
VALUES 
  (1, 'Python'),
  (1, 'JavaScript'),
  (1, 'Java'),
  (1, 'C++');
```

### Завершення голосування

```sql
UPDATE polls 
SET is_active = false 
WHERE id = 1;
```

### Отримання результатів голосування

```sql
SELECT 
  po.text,
  COUNT(pv.id) as votes,
  ROUND(COUNT(pv.id) * 100.0 / (SELECT COUNT(*) FROM poll_votes WHERE poll_id = po.poll_id), 1) as percentage
FROM poll_options po
LEFT JOIN poll_votes pv ON po.id = pv.option_id
WHERE po.poll_id = 1
GROUP BY po.id, po.text
ORDER BY votes DESC;
```

### Перевірка, хто голосував

```sql
SELECT 
  u.full_name,
  u.login,
  po.text as voted_for,
  pv.created_at
FROM poll_votes pv
JOIN users u ON pv.user_id = u.id
JOIN poll_options po ON pv.option_id = po.id
WHERE pv.poll_id = 1
ORDER BY pv.created_at;
```

### Видалення голосу користувача (дозволити перегосування)

```sql
-- Видалити останній голос для студента 1 у голосуванні 1
DELETE FROM poll_votes 
WHERE poll_id = 1 AND user_id = 1
LIMIT 1;
```

### Видалення голосування

```sql
DELETE FROM polls WHERE id = 1;
```

---

## Статистика

### Загальна статистика

```sql
SELECT 
  'Users' as metric, COUNT(*) as value FROM users
UNION ALL
SELECT 'News', COUNT(*) FROM news
UNION ALL
SELECT 'Active Polls', COUNT(*) FROM polls WHERE is_active = true
UNION ALL
SELECT 'Total Votes', COUNT(*) FROM poll_votes;
```

### Активність користувачів

```sql
SELECT 
  u.login,
  u.full_name,
  COUNT(DISTINCT pv.id) as votes_made,
  MAX(pv.created_at) as last_vote
FROM users u
LEFT JOIN poll_votes pv ON u.id = pv.user_id
GROUP BY u.id
ORDER BY votes_made DESC;
```

### Популярність новин

```sql
-- За кількістю картинок та посилань
SELECT 
  n.title,
  COUNT(DISTINCT ni.id) as images,
  COUNT(DISTINCT nl.id) as links,
  n.created_at
FROM news n
LEFT JOIN news_images ni ON n.id = ni.news_id
LEFT JOIN news_links nl ON n.id = nl.news_id
GROUP BY n.id
ORDER BY n.created_at DESC;
```

---

## Резервне копіювання

### Резервна копія всієї БД

```bash
mysqldump -u root -p college_app > backup_college_app.sql
```

### Відновлення з резервної копії

```bash
mysql -u root -p college_app < backup_college_app.sql
```

### Резервна копія конкретної таблиці

```bash
mysqldump -u root -p college_app users > backup_users.sql
```

---

## Технічна підтримка

### Перевірка статусу сервера

```bash
# Перевірка, чи сервер запущений
curl http://localhost:3000

# Перевірка авторизації
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"login":"student1","password":"password"}'

# Перевірка новин
curl -X GET http://localhost:3000/api/news \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Логи БД

```bash
# Перегляд MySQL логів (на Linux/macOS)
tail -f /var/log/mysql/error.log

# Вмикання query логування
mysql -u root -p
SET GLOBAL general_log = 'ON';
SET GLOBAL log_output = 'FILE';
SET GLOBAL general_log_file = '/path/to/logfile.log';
```

### Оптимізація БД

```sql
-- Перевірка таблиць
CHECK TABLE news, polls, users;

-- Оптимізація таблиць
OPTIMIZE TABLE news, polls, users, poll_votes, news_images, news_links;

-- Статистика таблиць
SHOW TABLE STATUS FROM college_app;
```

---

## Безпека

### Зміна JWT Secret

1. Відредагуйте `.env` в `backend/`
2. Змініть `JWT_SECRET` на новий ключ
3. Перезапустіть backend сервер
4. Всі користувачі повинні заново залогінитися

### Блокування підозрілої активності

```sql
-- Знайти користувачів з дивною активністю
SELECT u.id, u.login, COUNT(*) as vote_count
FROM poll_votes pv
JOIN users u ON pv.user_id = u.id
WHERE DATE(pv.created_at) = CURDATE()
GROUP BY u.id
HAVING vote_count > 100;

-- Блокувати користувача
UPDATE users SET is_active = false WHERE id = 123;
```

---

## Регулярне обслуговування

### Щотижневе

- ✅ Перевіряти логи помилок
- ✅ Перевіряти місце на диску
- ✅ Розглядати статистику активності

### Щомісячне

- ✅ Робити резервну копію
- ✅ Оптимізувати БД
- ✅ Оновлювати залежності (якщо потрібно)

### Щороку

- ✅ Повна перевірка безпеки
- ✅ Планування на майбутній рік
- ✅ Оновлення криптографічних ключів

---

## Звітування

### Звіт про активність

```sql
SELECT 
  DATE(created_at) as date,
  COUNT(*) as new_votes
FROM poll_votes
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

### Звіт про популярність голосувань

```sql
SELECT 
  p.question,
  COUNT(DISTINCT pv.id) as total_votes,
  COUNT(DISTINCT pv.user_id) as unique_voters,
  p.is_active,
  p.created_at
FROM polls p
LEFT JOIN poll_votes pv ON p.id = pv.poll_id
GROUP BY p.id
ORDER BY total_votes DESC;
```

---

**Для доступу до БД напряму: mysql -u root -p college_app**
