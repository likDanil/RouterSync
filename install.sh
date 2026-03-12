#!/bin/sh
# RouterSync — автоматическая установка
# Одна команда: wget -q -O - https://raw.githubusercontent.com/likDanil/RouterSync/main/install.sh | sh

set -e

echo "=== RouterSync Installer ==="

# Определяем архитектуру
ARCH=$(uname -m)
case "$ARCH" in
    aarch64) ARCH="arm64" ;;
    mips)    ARCH="mips" ;;
    mipsel)  ARCH="mipsel" ;;
    *)
        echo "Неподдерживаемая архитектура: $ARCH"
        exit 1
        ;;
esac

echo "Архитектура: $ARCH"

REPO="https://github.com/likDanil/RouterSync/raw/main"
BASE_URL="$REPO/build/$ARCH"

# Создаём директории
mkdir -p /opt/bin /opt/etc/RouterSync

echo "Загрузка файлов..."

# Скачиваем файлы
wget -q -O /opt/bin/RouterSync "$BASE_URL/RouterSync" || { echo "Ошибка загрузки бинарника"; exit 1; }
wget -q -O /opt/etc/RouterSync/config.json "$BASE_URL/config.json" || { echo "Ошибка загрузки конфига"; exit 1; }
wget -q -O /opt/etc/init.d/S99RouterSync "$BASE_URL/S99RouterSync" || { echo "Ошибка загрузки скрипта"; exit 1; }

# Делаем исполняемыми
chmod +x /opt/bin/RouterSync /opt/etc/init.d/S99RouterSync

echo "Установка завершена!"

# Запускаем сервис
/opt/etc/init.d/S99RouterSync start

# Выводим ссылку
IP=$(nvram get lan_ipaddr 2>/dev/null || hostname -I 2>/dev/null | awk '{print $1}' || echo "192.168.1.1")
echo ""
echo "=== RouterSync готов ==="
echo "Откройте в браузере: http://$IP:3400"
