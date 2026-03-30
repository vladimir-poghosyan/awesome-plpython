-- Store and retrieve small SQLite databases inside PostgreSQL
--
-- This PL/Python snippet demonstrates how to serialize an in-memory SQLite
-- database into a PostgreSQL table (BYTEA column) and then deserialize it
-- back into SQLite.
--
-- Notes:
-- - Uses Python's standard library (sqlite3), not available in plain SQL.
-- - Intended for experimentation, debugging, or fun projects.
-- - Uses an UNLOGGED table for temporary storage (faster, avoids WAL).
-- - Transaction-safe: can be run inside BEGIN/ROLLBACK without side effects.
-- - Not suitable for large databases or production storage.
--
-- Usage examples (from `pgsql` shell):
--   pgawesome=# \i /path/to/sqlite.sql
--
BEGIN;


CREATE UNLOGGED TABLE IF NOT EXISTS sqlites (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sqlite BYTEA
);


DO $$
    import sqlite3

    import plpy


    # create an in-memory SQLite database with schema and data
    conn = sqlite3.connect(':memory:')
    conn.execute("CREATE TABLE IF NOT EXISTS plpy_awesome (id INTEGER PRIMARY KEY, comment TEXT)")
    conn.execute("INSERT INTO plpy_awesome(comment) VALUES ('PL/Python is awesome'), ('As is PostgreSQL')")
    conn.commit()

    # check inserted data
    plpy.info(conn.execute("SELECT * FROM plpy_awesome").fetchall())

    # serialize in-memory SQLite into a PostgreSQL table
    plan = plpy.prepare('INSERT INTO sqlites (sqlite) VALUES ($1)', ['bytea'])
    plpy.execute(plan, ([conn.serialize()]))

    # check serialization result
    plpy.info(plpy.execute('SELECT id, LENGTH(sqlite) FROM sqlites LIMIT 1', 1)[0])

    conn.close()
$$ LANGUAGE 'plpython3u';


DO $$
    import sqlite3

    import plpy


    # create an in-memory SQLite database
    conn = sqlite3.connect(':memory:')

    # deserialize and load SQLite database stored in a PostgreSQL table
    conn.deserialize(plpy.execute('SELECT sqlite FROM sqlites LIMIT 1', 1)[0]['sqlite'])

    # check the result
    plpy.info(conn.execute("SELECT * FROM plpy_awesome").fetchall())

    conn.close()
$$ LANGUAGE 'plpython3u';


ROLLBACK;
