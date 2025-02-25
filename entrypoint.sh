#!/bin/sh -l
set -ex

if [ -f /app/tmp/pids/server.pid ]; then
  rm /app/tmp/pids/server.pid
fi

bin/rails db:create

if [ -n "$SILENT_MIGRATION" ]; then
  bin/rails db:migrate > /dev/null
else
  bin/rails db:migrate
fi

exec "$@"
