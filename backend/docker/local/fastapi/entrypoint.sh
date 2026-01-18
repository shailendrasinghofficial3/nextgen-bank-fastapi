#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

# This Python block handles the entire waiting logic
python << END
import sys
import psycopg
import time
import os

# Configuration
MAX_WAIT_SECONDS = 30
RETRY_INTERVAL = 5
start_time = time.time()

def check_database():
    try:
        # Note: using f-strings or direct injection from shell variables
        psycopg.connect(
            dbname="${POSTGRES_DB}",
            user="${POSTGRES_USER}",
            password="${POSTGRES_PASSWORD}",
            host="${POSTGRES_HOST}",
            port="${POSTGRES_PORT}",
        )
        return True
    except psycopg.OperationalError as error:
        elapsed = int(time.time() - start_time)
        # Fixed the missing closing quote and variable name 'error' below
        sys.stderr.write(f"DB connection attempt failed after {elapsed}s: {error}\n")
        return False

while True:
    if check_database():
        sys.stderr.write("PostgreSQL is up - continuing...\n")
        break

    if time.time() - start_time > MAX_WAIT_SECONDS:
        sys.stderr.write(f"Error: DB connection could not be established after {MAX_WAIT_SECONDS}s\n")
        sys.exit(1)

    sys.stderr.write(f"Waiting {RETRY_INTERVAL}s before retrying...\n")
    time.sleep(RETRY_INTERVAL)
END

>&2 echo "PostgreSQL is up - continuing..."

# Execute the next command (which is /start.sh)
exec "$@"