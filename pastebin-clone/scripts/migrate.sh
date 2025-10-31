#!/usr/bin/env bash
# ...existing code...
set -euo pipefail
IFS=$'\n\t'

# Simple migration runner that:
# - lädt .env im Projekt-Root (falls vorhanden)
# - liest DATABASE_URL und entscheidet Postgres vs MySQL
# - erstellt die DB wenn möglich
# - führt alle .sql Dateien aus migrations/ der Reihe nach aus
# - gibt aussagekräftige Fehlermeldungen

progname=$(basename "$0")
rootdir="$(cd "$(dirname "$0")/.." && pwd)"

echo "[$progname] Starting migrations (project root: $rootdir)..."

# Load .env if present (simple parser: KEY=VALUE lines)
if [ -f "$rootdir/.env" ]; then
  echo "[$progname] Loading $rootdir/.env"
  # shellcheck disable=SC1091
  set -a
  # Use a subshell to avoid exporting every line incorrectly
  # Only export simple KEY=VALUE lines, ignore comments
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ''|\#*) continue ;;
      *=*)
        key=$(printf '%s' "$line" | cut -d= -f1)
        val=$(printf '%s' "$line" | cut -d= -f2-)
        # strip surrounding quotes
        val="${val%\"}"
        val="${val#\"}"
        val="${val%\'}"
        val="${val#\'}"
        export "$key"="$val"
        ;;
    esac
  done < "$rootdir/.env"
  set +a
fi

if [ -z "${DATABASE_URL:-}" ]; then
  echo "[$progname] ERROR: DATABASE_URL is not set in .env"
  exit 1
fi

# Normalize and parse DATABASE_URL
# Supported forms:
#  - postgres://user:pass@host:port/dbname
#  - postgresql://...
#  - mysql://user:pass@host:port/dbname
url="$DATABASE_URL"
scheme=$(echo "$url" | sed -n 's,^\([a-zA-Z0-9+.-]*\)://.*,\1,p' | tr '[:upper:]' '[:lower:]')
rest=$(echo "$url" | sed -n 's,^[a-zA-Z0-9+.-]*://,,p')

# split credentials and host/db
if echo "$rest" | grep -q '@'; then
  creds=$(echo "$rest" | awk -F'@' '{print $1}')
  hostpart=$(echo "$rest" | awk -F'@' '{print $2}')
else
  creds=""
  hostpart="$rest"
fi

# extract user:pass
user=$(echo "$creds" | sed -n 's,^\([^:]*\):.*,\1,p' || true)
pass=$(echo "$creds" | sed -n 's,^.*:\(.*\)$,\1,p' || true)

# hostpart -> host:port/db
hostport=$(echo "$hostpart" | sed -n 's,\(.*\)/.*$,\1,p')
dbname=$(echo "$hostpart" | sed -n 's,.*/\([^/?]*\).*$,\1,p')

# port extraction
if echo "$hostport" | grep -q ':'; then
  host=$(echo "$hostport" | sed -n 's,^\([^:]*\):.*$,\1,p')
  port=$(echo "$hostport" | sed -n 's,^.*:\([0-9]*\)$,\1,p')
else
  host="$hostport"
  port=""
fi

host="${host:-localhost}"

echo "[$progname] Detected scheme: $scheme"
echo "[$progname] Host: $host  Port: ${port:-(default)}  DB: ${dbname:-(none)}  User: ${user:-(none)}"

migrations_dir="$rootdir/migrations"
if [ ! -d "$migrations_dir" ]; then
  echo "[$progname] No migrations directory at $migrations_dir. Nothing to run."
  exit 0
fi

# Helper: run Postgres migrations
run_postgres() {
  if ! command -v psql >/dev/null 2>&1; then
    echo "[$progname] ERROR: psql not installed. Install postgresql-client."
    exit 1
  fi

  if [ -z "$dbname" ]; then
    echo "[$progname] ERROR: no database name parsed from DATABASE_URL"
    exit 1
  fi

  # Use PGPASSWORD env for non-interactive auth if pass present
  export PGPASSWORD="${pass:-}"

  admin_conn="postgres://${user:+$user:${pass:-}@}$host${port:+:$port}/postgres"
  # Check if DB exists
  echo "[$progname] Checking if database '$dbname' exists..."
  if PGPASSWORD="$PGPASSWORD" psql -At -c "SELECT 1 FROM pg_database WHERE datname = '$dbname';" "$admin_conn" 2>/dev/null | grep -q 1; then
    echo "[$progname] Database '$dbname' exists."
  else
    echo "[$progname] Database '$dbname' does not exist. Attempting to create..."
    if PGPASSWORD="$PGPASSWORD" psql "$admin_conn" -c "CREATE DATABASE \"$dbname\" OWNER \"$user\";" 2>/dev/null; then
      echo "[$progname] Database '$dbname' created."
    else
      echo "[$progname] WARNING: Could not create database automatically. You may need to create it manually or check permissions."
      echo "[$progname] Attempting to continue and run migrations directly (may fail)."
    fi
  fi

  # Apply migrations in lexical order
  for f in "$migrations_dir"/*.sql; do
    [ -e "$f" ] || break
    echo "[$progname] Applying: $(basename "$f")"
    if ! PGPASSWORD="$PGPASSWORD" psql "$url" -f "$f"; then
      echo "[$progname] ERROR: Failed to apply $f"
      exit 1
    fi
  done
}

# Helper: run MySQL migrations
run_mysql() {
  if ! command -v mysql >/dev/null 2>&1; then
    echo "[$progname] ERROR: mysql client not installed."
    exit 1
  fi

  if [ -z "$dbname" ]; then
    echo "[$progname] ERROR: no database name parsed from DATABASE_URL"
    exit 1
  fi

  echo "[$progname] Ensuring MySQL database '$dbname' exists..."
  # Build connect flags safely
  connect_flags=()
  if [ -n "$host" ]; then
    connect_flags+=(-h "$host")
  fi
  if [ -n "$port" ]; then
    connect_flags+=(-P "$port")
  fi
  if [ -n "$user" ]; then
    connect_flags+=(-u "$user")
  else
    connect_flags+=(-u root)
  fi
  # pass may be empty -> use -p only if set (no space)
  if [ -n "$pass" ]; then
    connect_flags+=(-p"$pass")
  fi

  # Create DB if not exists
  if ! mysql "${connect_flags[@]}" -e "CREATE DATABASE IF NOT EXISTS \`$dbname\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"; then
    echo "[$progname] ERROR: failed to create/check DB. Check credentials or mysql socket/host."
    exit 1
  fi

  # Apply migrations
  for f in "$migrations_dir"/*.sql; do
    [ -e "$f" ] || break
    echo "[$progname] Applying: $(basename "$f")"
    if ! mysql "${connect_flags[@]}" "$dbname" < "$f"; then
      echo "[$progname] ERROR: Failed to apply $f"
      exit 1
    fi
  done
}

case "$scheme" in
  postgres|postgresql)
    run_postgres
    ;;
  mysql|mariadb)
    run_mysql
    ;;
  *)
    echo "[$progname] ERROR: unsupported scheme '$scheme'. Use postgres:// or mysql://"
    exit 1
    ;;
esac

echo "[$progname] Migrations completed successfully."
# ...existing code...