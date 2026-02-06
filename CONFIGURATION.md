# Конфигурация транспортов в 3X-UI

## Настройка инбаундов

### 1. VLESS-Reality (порт 443)

В 3X-UI WebUI создайте инбаунд:
- Protocol: VLESS
- Port: 443
- Network: TCP
- Security: Reality
- Certificates: укажите пути к сертификатам в `/etc/x-ui/certs/`

### 2. XHTTP (порт 80)

В 3X-UI WebUI создайте инбаунд:
- Protocol: VLESS/VMess
- Port: 80
- Network: XHTTP
- Security: None

### 3. WebUI

WebUI работает на внутреннем порту 2053, доступен через Nginx на порту 8080 с SSL.

## Добавление новых транспортов

### Шаг 1: Создайте инбаунд в 3X-UI

Например, для gRPC на порту 2053:
- Protocol: VLESS
- Port: 2053
- Network: gRPC
- Security: None

### Шаг 2: Добавьте конфиг Nginx

Для HTTP-based транспортов (gRPC, WebSocket) создайте `conf.d/grpc.conf`:
```nginx
upstream xui_grpc {
    server 3x-ui:2053;
}

server {
    listen 2053 http2;
    server_name _;

    location / {
        grpc_pass grpc://xui_grpc;
        grpc_set_header Host $host;
        grpc_set_header X-Real-IP $remote_addr;
    }
}
```

Для TCP/UDP транспортов создайте `conf.d/stream/custom.conf`:
```nginx
upstream xui_custom {
    server 3x-ui:8443;
}

server {
    listen 8443;
    proxy_pass xui_custom;
    proxy_timeout 1d;
}
```

### Шаг 3: Откройте порт в docker-compose.yml

```yaml
nginx:
  ports:
    - "2053:2053"  # для HTTP-based
    # или
    - "8443:8443"  # для TCP
```

### Шаг 4: Перезапустите

```bash
docker compose restart nginx
```

## Рекомендуемые транспорты

| Транспорт | Порт | Тип | Использование |
|-----------|------|-----|---------------|
| Reality   | 443  | TCP | Основной, максимальная безопасность |
| XHTTP     | 80   | HTTP| Обход блокировок |
| gRPC      | 2053 | HTTP2| Маскировка под Google API |
| WebSocket | 2096 | HTTP| Совместимость |

## Безопасность

1. Всегда используйте Reality для TLS
2. Для HTTP транспортов настройте маскировку (fallback)
3. Регулярно обновляйте образы Docker
4. Используйте сложные пароли для WebUI
