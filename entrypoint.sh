#!/bin/sh -l
set -ex

if [ -f /app/tmp/pids/server.pid ]; then
  rm /app/tmp/pids/server.pid
fi

if [ -n "$SILENT_MIGRATION" ]; then
  bin/rails db:create && bin/rails db:migrate > /dev/null
else
  bin/rails db:create && bin/rails db:migrate
fi

exec "$@"
