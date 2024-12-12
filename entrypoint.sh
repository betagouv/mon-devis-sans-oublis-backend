#!/bin/sh -l
set -ex

if [ -f /app/tmp/pids/server.pid ]; then
  rm /app/tmp/pids/server.pid
fi

bundle install --gemfile /app/Gemfile

bin/rails db:create && bin/rails db:migrate

exec "$@"
