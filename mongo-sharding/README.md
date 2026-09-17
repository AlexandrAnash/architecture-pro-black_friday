# pymongo-api

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Заполняем mongodb данными

```shell
./scripts/mongo-init.sh
```

Проверить распределение

```shell
./scripts/check-shards.sh
```
![result check-shards.sh](check-shards.png)

## Как проверить в браузере

### Если вы запускаете проект на локальной машине

Откройте в браузере http://localhost:8083

### Доступные endpoint
![http://localhost:8083/helloDoc/count](helloDoc_count.png)
![http://localhost:8083/helloDoc/users](helloDoc_users.png)


### Почистить за собой
```shell
docker compose down -v
```
