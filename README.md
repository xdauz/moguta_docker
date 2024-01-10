Пример запуска MogutaCMS в докере.

## Инструкция

1. Копируем файлы в корень `moguta-cms`

2. Создаем докер сеть `docker create network moguta_network`

3. Запускаем `docker compose up -d` и ждем пока контейнеры создадутся. 

4. Открываем http://0.0.0.0:8081  

## TODO:

* Использование .env.docker
* Добавить Prod/Dev варианты
