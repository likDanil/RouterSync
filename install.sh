#!/bin/sh
# RouterSync — автоматическая установка
# Одна команда: wget -q -O - https://raw.githubusercontent.com/likDanil/RouterSync/refs/heads/main/install.sh | sh

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

REPO="https://raw.githubusercontent.com/likDanil/RouterSync/refs/heads/main"

# Создаём директории
mkdir -p /opt/bin /opt/etc/RouterSync

echo "Загрузка файлов..."

# Скачиваем файлы (бинарник из папки архитектуры, остальное из корня)
wget -q -O /opt/bin/RouterSync "$REPO/$ARCH/RouterSync" || { echo "Ошибка загрузки бинарника"; exit 1; }

# Конфиг загружаем только если его нет (чтобы не перезаписывать пользовательский)
if [ ! -f /opt/etc/RouterSync/config.json ]; then
    echo "Конфиг не найден, загружаем новый..."
    wget -q -O /opt/etc/RouterSync/config.json "$REPO/config.json" || { echo "Ошибка загрузки конфига"; exit 1; }
else
    echo "Конфиг уже существует, пропускаем..."
fi

wget -q -O /opt/etc/init.d/S99RouterSync "$REPO/S99RouterSync" || { echo "Ошибка загрузки скрипта"; exit 1; }

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
