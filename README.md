# 3X-UI + Nginx Docker Compose

## Структура
```
.
├── .env                    # Параметры окружения
├── docker-compose.yml      # Docker Compose конфигурация
├── nginx.conf              # Основной конфиг Nginx
├── conf.d/
│   ├── acme-challenge.conf # ACME challenge для Let's Encrypt
│   ├── 3x-ui.conf         # HTTP reverse proxy для WebUI
│   └── stream/
│       └── 3x-ui-stream.conf  # Stream proxy для TLS/XHTTP
├── scripts/
│   └── init-certbot.sh    # Скрипт для получения сертификата
├── data/
│   └── x-ui.db            # База 3X-UI (создается автоматически)
└── certs/                 # SSL сертификаты Let's Encrypt
```

## Использование

### 1. Настройка параметров
Отредактируйте `.env`:
```bash
CERTBOT_EMAIL=your-email@example.com
CERTBOT_DOMAIN=your-domain.com
```

### 2. Запуск
```bash
docker-compose up -d
```

### 3. Получение SSL сертификата
```bash
./scripts/init-certbot.sh
```

### 4. Обновление конфига nginx
Замените `example.com` в [`conf.d/3x-ui.conf`](conf.d/3x-ui.conf:23) на ваш домен:
```bash
sed -i 's/example.com/your-domain.com/g' conf.d/3x-ui.conf
```

### 5. Перезапуск nginx
```bash
docker-compose restart nginx
```

### Остановка
```bash
docker-compose down
```

### Просмотр логов
```bash
docker-compose logs -f
```

## Автоматическое обновление сертификатов

Certbot автоматически проверяет и обновляет сертификаты каждые 12 часов. После обновления nginx автоматически подхватит новые сертификаты.

## Порты

| Сервис | Порт | Описание |
|--------|------|----------|
| Nginx HTTP | 80 | Входящий HTTP + ACME challenge |
| Nginx HTTPS | 443 | Входящий HTTPS |
| 3X-UI WebUI | 2053 | Веб-интерфейс (host network) |
| 3X-UI TLS | 443 | TLS трафик (host network) |
| 3X-UI XHTTP | 80 | XHTTP трафик (host network) |
