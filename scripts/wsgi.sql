-- A simple WSGI application running inside PostgreSQL
--
-- WARNING: This is purely for demonstration purposes. Running an HTTP server
-- inside PostgreSQL is NOT recommended and may cause security, stability, and
-- performance issues. The server runs inside the database backend process
-- and will block the session until terminated.
--
-- Stop the server with Ctrl+C in the psql session running the procedure.
--
-- Usage example: CALL httpd(8080);
-- Open http://localhost:8080/ in a web browser
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
