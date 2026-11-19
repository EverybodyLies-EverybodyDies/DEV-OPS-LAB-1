<CodeBlock language="bash" editable>
IMAGE_NAME="task-api"
IMAGE_TAG="1.0"
CONTAINER_NAME="task-api-container"
HOST_PORT=8000
CONTAINER_PORT=8000
if ! command -v docker >/dev/null 2>&1; then
echo "ПОМИЛКА: Docker не встановлений або недоступний."
exit 1
fi
if ! docker info >/dev/null 2>&1; then
echo "ПОМИЛКА: Docker Engine не запущений."
exit 1
fi
cd "$(dirname "$0")" || exit 1

echo "=================================="
echo "      TASK API DOCKER LAUNCH"
echo "=================================="
echo "1. Створення Docker-образу..."

if ! docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .; then
echo "ПОМИЛКА: Не вдалося створити Docker-образ."
exit 1
fi
echo "2. Перевірка старого контейнера..."

if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
fi
echo "3. Запуск Docker-контейнера..."

if ! docker run -d 
--name "$CONTAINER_NAME" 
-p "${HOST_PORT}:${CONTAINER_PORT}" 
"$IMAGE_NAME:$IMAGE_TAG"; then

echo "ПОМИЛКА: Не вдалося запустити контейнер."
exit 1
fi
echo "4. Перевірка стану..."

if docker ps --filter "name=^/${CONTAINER_NAME}$" 
--filter "status=running" 
--format '{{.Names}}' | grep -Fxq "$CONTAINER_NAME"; then

echo "Контейнер успішно запущений!"
echo "API: http://localhost:${HOST_PORT}"
echo "Документація: http://localhost:${HOST_PORT}/docs"

else
echo "ПОМИЛКА: Контейнер не запущений."
echo "Перегляньте логи:"
docker logs "$CONTAINER_NAME"
exit 1
fi

echo "=================================="
echo "       ЗАПУСК ЗАВЕРШЕНО"
echo "=================================="
</CodeBlock>