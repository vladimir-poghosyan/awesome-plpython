-- A simple WSGI HTTP server running inside PostgreSQL (for demonstration only)
--
-- WARNING:
--   Running an HTTP server inside PostgreSQL is strongly discouraged:
--     • It blocks the backend session until terminated.
--     • May cause stability, security, and performance issues.
--     • Only suitable for educational/demo purposes.
--
-- Behavior:
-- - Starts a WSGI HTTP server on the specified port.
-- - Returns a simple plaintext response: "hello from PostgreSQL".
-- - Can be stopped with Ctrl+C in the psql session running the procedure.
--
-- Notes:
-- - Uses Python's standard library (wsgiref.simple_server).
-- - Demonstrates that PL/Python can execute arbitrary Python code,
--   including long-running processes, inside PostgreSQL.
-- - Do NOT use this approach in production.
--
-- Usage example:
--   CALL httpd(8080);
--   Open a browser and visit http://localhost:8080/
--
-- Educational use cases:
-- - Learn how PL/Python interacts with PostgreSQL session lifecycle
-- - Experiment with embedded Python services
-- - Understand process blocking and signal handling inside PL/Python
CREATE OR REPLACE PROCEDURE httpd(port INTEGER)
AS $$
    import signal
    import sys

    from typing import Callable, Iterable
    from wsgiref.simple_server import make_server

    import plpy


    # handle signals to be able to terminate the query running this code
    def handle_signal(signum: int, frame: object) -> None:
        sys.exit(0)


    # the main WSGI application
    def application(environ: dict, start_response: Callable) -> Iterable:
        start_response('200 OK', [('Content-Type', 'text/plain')])
        return [b'hello from PostgreSQL']


    signal.signal(signal.SIGINT, handle_signal)

    with make_server('', port, application) as server:
        plpy.debug(f'Serving HTTP on port {port}...')
        server.serve_forever()
$$ LANGUAGE plpython3u;
