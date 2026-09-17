#!/bin/bash

echo "=== всего в кластере (через mongos_router) ==="
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<'MONGO'
use somedb
print(db.helloDoc.countDocuments());
MONGO

echo "=== shard1-1 ==="
docker compose exec -T shard1-1 mongosh --port 27018 --quiet <<'MONGO'
use somedb
print(db.helloDoc.countDocuments());


const s = rs.status()
print("replica set " + s.set + " — узлов: " + s.members.length)
s.members.forEach(m => print("\n   " + m.name + "  " + m.stateStr))
MONGO


echo "=== shard2 ==="
docker compose exec -T shard2-1 mongosh --port 27019 --quiet <<'MONGO'
use somedb
print(db.helloDoc.countDocuments());

const s = rs.status()
print("replica set " + s.set + " — узлов: " + s.members.length)
s.members.forEach(m => print("\n   " + m.name + "  " + m.stateStr))
MONGO
