#!/usr/bin/env python3
import os
os.environ['CASS_DRIVER_NO_EXTENSIONS'] = '1'

from cassandra.cluster import Cluster
from cassandra.connection import Connection, register_connection_factory

# Minimal pure-Python connection class
class PurePythonConnection(Connection):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

register_connection_factory('pure', PurePythonConnection)

def run_query(query):
    try:
        cluster = Cluster(['127.0.0.1'], connection_class=PurePythonConnection)
        session = cluster.connect()
        rows = session.execute(query)
        for row in rows:
            print(row)
        cluster.shutdown()
    except Exception as e:
        print(f"[Error] {e}")

if __name__ == "__main__":
    import sys
    q = sys.argv[1] if len(sys.argv) > 1 else "SELECT now() FROM system.local;"
    run_query(q)
