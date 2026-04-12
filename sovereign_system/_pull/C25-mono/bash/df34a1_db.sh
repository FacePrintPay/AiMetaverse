#!/data/data/com.termux/files/usr/bin/bash
source "$HOME/SOVEREIGN_GTP/core/protocol.sh"

_pg() { PGPASSWORD="$DB_PASS" psql "host=$DB_HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER" -At -c "$1"; }
_my() { mysql -h "$DB_HOST" -P "${DB_PORT:-3306}" -u"$DB_USER" "-p$DB_PASS" "$DB_NAME" -N -e "$1"; }
_cql() { python3 "$HOME/SOVEREIGN_GTP/core/cql_exec.py" "$1"; }

db_query() {
  local q="$1"
  case "$DB_BACKEND" in
    cassandra) _cql "$q" ;;
    postgres)  _pg "$q" ;;
    mysql|vitess) _my "$q" ;;
    dynamodb) echo "Dynamo handled elsewhere"; return 1 ;;
    sqlserver) echo "Use app driver for SQL Server"; return 1 ;;
    *) echo "Unknown DB_BACKEND: $DB_BACKEND"; return 1 ;;
  esac
}

db_init() {
  case "$DB_BACKEND" in
    cassandra)
      _cql "CREATE KEYSPACE IF NOT EXISTS sovereign WITH replication = {'class':'SimpleStrategy','replication_factor':1};"
      _cql "CREATE TABLE IF NOT EXISTS sovereign.memories (id timeuuid PRIMARY KEY, agent text, msg text, ts timestamp);"
      ;;
    postgres)
      _pg "CREATE TABLE IF NOT EXISTS memories (id BIGSERIAL PRIMARY KEY, agent text, msg text, ts timestamptz default now());"
      ;;
    mysql|vitess)
      _my "CREATE TABLE IF NOT EXISTS memories (id BIGINT PRIMARY KEY AUTO_INCREMENT, agent VARCHAR(64), msg TEXT, ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"
      ;;
  esac
}

db_insert_memory() {
  local agent="$1"; shift
  local msg="$*"
  case "$DB_BACKEND" in
    cassandra)
      _cql "INSERT INTO sovereign.memories (id, agent, msg, ts) VALUES (now(), '$agent', '$(printf %s "$msg" | sed "s/'/''/g")', toTimestamp(now()));"
      ;;
    postgres)
      _pg "INSERT INTO memories(agent,msg) VALUES ('$agent', $$${msg//\'/\'\'}$$);"
      ;;
    mysql|vitess)
      _my "INSERT INTO memories(agent,msg) VALUES ('$agent','$(printf %s "$msg" | sed "s/'/''/g")');"
      ;;
  esac
}

export -f db_query db_init db_insert_memory
