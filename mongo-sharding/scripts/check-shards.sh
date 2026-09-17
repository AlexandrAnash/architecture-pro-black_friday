#!/bin/bash

echo "=== всего в кластере (через mongos_router) ==="
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<'MONGO'
use somedb
print(db.helloDoc.countDocuments());
MONGO

echo "=== shard1 ==="
docker compose exec -T shard1 mongosh --port 27018 --quiet <<'MONGO'
use somedb
print(db.helloDoc.countDocuments());
MONGO

echo "=== shard2 ==="
docker compose exec -T shard2 mongosh --port 27019 --quiet <<'MONGO'
use somedb
print(db.helloDoc.countDocuments());
MONGO
