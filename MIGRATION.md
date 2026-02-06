# Миграция на новую конфигурацию

Если у вас уже запущен старый проект, выполните:

```bash
# 1. Остановите старые контейнеры
docker compose down

# 2. Сделайте бэкап данных (если есть)
cp -r data/ data.backup-$(date +%Y%m%d)

# 3. Обновите .env файл
# Убедитесь что указаны:
# - DOMAIN=ваш-домен.com
# - SSL_CERTS_PATH=/путь/к/сертификатам

# 4. Запустите новую конфигурацию
docker compose up -d

# 5. Проверьте логи
docker compose logs -f
```

## Основные изменения

1. **Убран контейнер acme.sh** - сертификаты должны быть на хосте
2. **Упрощены пути к сертификатам** - используется стандартный Let's Encrypt путь
3. **Добавлена bridge сеть** - контейнеры изолированы
4. **Упрощены конфиги nginx** - убраны лишние параметры
5. **Порт 443 в stream режиме** - raw TCP passthrough для Reality (без SSL терминации в nginx)

## Проверка работы

```bash
# Проверить статус
docker compose ps

# Проверить порты
netstat -tulpn | grep -E ':(80|443|8080)'

# Проверить WebUI
curl -k https://localhost:8080

# Проверить логи nginx
docker compose logs nginx

# Проверить логи 3x-ui
docker compose logs 3x-ui
```
