#!/bin/sh

set -e

/usr/local/bin/migrate -path /migrations -database "$DATABASE_URL" up

exec /weatherpro-backend
