#!/bin/bash
set -e

rm -f /first-class/tmp/pids/server.pid

exec "$@"