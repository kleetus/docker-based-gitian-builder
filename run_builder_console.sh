#!/bin/bash
docker run -u root -d -h builder --name builder builder tail -f /dev/null &&
docker exec -it builder /bin/bash
