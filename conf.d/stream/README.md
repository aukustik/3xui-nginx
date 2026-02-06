# Stream Transport Configurations

Здесь размещаются конфигурации для дополнительных транспортных протоколов 3X-UI.

## Примеры конфигураций

### TCP Transport (любой порт)
```nginx
upstream xui_tcp_custom {\n    server 3x-ui:8443;\n}\n\nserver {\n    listen 8443;\n    proxy_pass xui_tcp_custom;\n    proxy_timeout 1d;\n    proxy_connect_timeout 10s;\n}
```

### UDP Transport (например, для QUIC)
```nginx
upstream xui_udp {\n    server 3x-ui:8443;\n}\n\nserver {\n    listen 8443 udp;\n    proxy_pass xui_udp;\n    proxy_timeout 1d;\n    proxy_connect_timeout 10s;\n}
```

### WebSocket через отдельный порт
```nginx
upstream xui_ws {\n    server 3x-ui:2096;\n}\n\nserver {\n    listen 2096;\n    proxy_pass xui_ws;\n    proxy_timeout 1d;\n    proxy_connect_timeout 10s;\n}
```

## Важно

1. После добавления нового конфига нужно:
   - Открыть порт в docker-compose.yml (секция nginx.ports)
   - Перезапустить nginx: `docker compose restart nginx`

2. Для UDP портов добавьте в docker-compose.yml:
   ```yaml
   - "8443:8443/udp"
   ```
