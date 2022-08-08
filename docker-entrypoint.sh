#!/bin/sh
set -e

if [ -f tmp/pids/server.pid ]; then
  # remove old pids
  rm tmp/pids/server.pid
fi

exec "$@"
