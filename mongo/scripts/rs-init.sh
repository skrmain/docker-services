#!/bin/bash

set -e

echo "Waiting for MongoDB..."

until mongosh \
  --host mongo_rs_1:27017 \
#   -u "$MONGO_INITDB_ROOT_USERNAME" \
#   -p "$MONGO_INITDB_ROOT_PASSWORD" \
  --authenticationDatabase admin \
  --eval "db.adminCommand('ping')" >/dev/null 2>&1
do
  sleep 2
done

echo "MongoDB is ready. Initializing replica set..."

mongosh \
  --host mongo_rs_1:27017 \
#   -u "$MONGO_INITDB_ROOT_USERNAME" \
#   -p "$MONGO_INITDB_ROOT_PASSWORD" \
  --authenticationDatabase admin <<'EOF'

try {
  rs.status();
  print("Replica set already initialized");
} catch (e) {
  rs.initiate({
    _id: "dbrs",
    members: [
      {
        _id: 1,
        host: "mongo_rs_1:27017",
        priority: 3
      },
      {
        _id: 2,
        host: "mongo_rs_2:27017",
        priority: 2
      },
      {
        _id: 3,
        host: "mongo_rs_3:27017",
        priority: 1
      }
    ]
  });
}

EOF

echo "Replica set initialization complete."
