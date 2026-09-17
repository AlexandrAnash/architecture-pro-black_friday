#!/bin/bash

echo "== 1/5 инициализация config server"
docker compose exec -T configSrv mongosh --port 27017 --quiet <<'MONGO'
try {
  rs.initiate({
    _id: "config_server",
    configsvr: true,
    members: [{ _id: 0, host: "configSrv:27017" }]
  });
} catch (e) {
  print("config_server уже инициализирован: " + e.codeName);
}
MONGO

sleep 2

echo "== 2/5 инициализация shard1"
docker compose exec -T shard1 mongosh --port 27018 --quiet <<'MONGO'
try {
  rs.initiate({ _id: "shard1", members: [{ _id: 0, host: "shard1:27018" }] });
} catch (e) {
  print("shard1 уже инициализирован: " + e.codeName);
}
MONGO

sleep 2

echo "== 3/5 инициализация shard2"
docker compose exec -T shard2 mongosh --port 27019 --quiet <<'MONGO'
try {
  rs.initiate({ _id: "shard2", members: [{ _id: 0, host: "shard2:27019" }] });
} catch (e) {
  print("shard2 уже инициализирован: " + e.codeName);
}
MONGO

sleep 2

echo "== 4/5 регистрация шардов и шардирование коллекции"
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<'MONGO'
sh.addShard("shard1/shard1:27018");
sh.addShard("shard2/shard2:27019");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { name: "hashed" });

printjson(sh.status());
MONGO

sleep 2

echo "== 5/5 наполнение коллекции somedb"
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<'MONGO'
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
MONGO

echo
echo "Готово. Проверить распределение: ./scripts/check-shards.sh"
