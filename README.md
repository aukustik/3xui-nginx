# 3X-UI + Nginx Docker Compose

Простой и гибкий деплой 3X-UI с Nginx reverse proxy для Ubuntu 24.04.

## Архитектура

- **Порт 8080**: WebUI 3X-UI с SSL (внутри контейнера на 2053)
- **Порт 80**: XHTTP транспорт для прокси
- **Порт 443**: TLS транспорт для VLESS-Reality (raw TCP passthrough)

## Быстрый старт

### 1. Подготовка сертификатов

Убедитесь, что SSL сертификаты лежат на хосте:
```bash
/root/3xui-nginx/certs/live/your-domain.com/
├── fullchain.pem
└── privkey.pem
```

### 2. Настройка

Отредактируйте `.env`:
```bash
DOMAIN=your-domain.com
SSL_CERTS_PATH=/root/3xui-nginx/certs/live/your-domain.com
```

### 3. Запуск

```bash
# Создать директорию для данных
mkdir -p data

# Запустить
docker compose up -d

# Проверить логи
docker compose logs -f
```

### 4. Доступ к WebUI

Откройте в браузере: `https://your-domain.com:8080`

Логин по умолчанию: `admin` / `admin`

## Структура проекта

```
.
├── .env                          # Параметры окружения
├── docker-compose.yml            # Docker Compose конфигурация
├── nginx.conf                    # Основной конфиг Nginx
├── conf.d/
│   ├── 00-acme-challenge.conf   # HTTP порт 80 → XHTTP
│   ├── 3x-ui.conf               # HTTPS порт 8080 → WebUI
│   └── stream/
│       ├── 3x-ui-stream.conf    # TCP порт 443 → TLS/Reality
│       └── README.md            # Примеры доп. транспортов
└── data/                         # База данных 3X-UI
```

## Добавление транспортов

### Пример: добавить WebSocket на порту 2096

1. Создайте файл `conf.d/stream/websocket.conf`:
```nginx
upstream xui_ws {
    server 3x-ui:2096;
}

server {
    listen 2096;
    proxy_pass xui_ws;
    proxy_timeout 1d;
}
```

2. Откройте порт в `docker-compose.yml`:
```yaml
nginx:
  ports:
    - "2096:2096"
```

3. Перезапустите:
```bash
docker compose restart nginx
```

Больше примеров в [`conf.d/stream/README.md`](conf.d/stream/README.md)

## Управление

```bash
# Остановить
docker compose down

# Перезапустить
docker compose restart

# Обновить образы
docker compose pull
docker compose up -d

# Просмотр логов
docker compose logs -f nginx
docker compose logs -f 3x-ui
```

## Бэкап

```bash
# Бэкап базы данных
cp -r data/ backup-$(date +%Y%m%d)/

# Восстановление
docker compose down
cp -r backup-YYYYMMDD/ data/
docker compose up -d
```

## Troubleshooting

### Проверка портов
```bash
docker compose ps
netstat -tulpn | grep -E ':(80|443|8080)'
```

### Проверка сертификатов
```bash
ls -la $SSL_CERTS_PATH
```

### Тест конфигурации nginx
```bash
docker compose exec nginx nginx -t
```

### Перезагрузка nginx без даунтайма
```bash
docker compose exec nginx nginx -s reload
```
