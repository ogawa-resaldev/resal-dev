#!/bin/bash
set -e

rm -f /mikado-system/tmp/pids/server.pid

exec "$@"