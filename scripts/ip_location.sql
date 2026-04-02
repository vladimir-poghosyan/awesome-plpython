-- Enriches an IP address with geolocation information using the free http://ip-api.com service.
--
-- Returns a TABLE (ip, country, city, org) for a single IP input.
--
-- WARNING:
--   Each uncached IP triggers an HTTP request. For large datasets, use
--   `SELECT DISTINCT ip FROM ...` to minimize API calls and avoid hammering.
--
-- Notes:
-- - Uses PL/Python's `urllib` to fetch data from an external API.
-- - Caches successful lookups in SD (session dictionary) to avoid repeated HTTP requests.
-- - Handles invalid IPs and network/API errors gracefully using plpy.warning.
-- - Returns the input IP even when geolocation fails (NULLs for other columns).
--
-- Usage example:
--   -- Basic enrichment
--   SELECT log.id, log.ip, location.country, location.city, location.org
--   FROM access_log AS log
--   LEFT JOIN ip_location(log.ip) AS location ON location.ip = log.ip;
--
--   -- Pre-aggregate distinct IPs for large tables
--   WITH unique_ips AS (SELECT DISTINCT ip FROM access_log)
--   SELECT u.ip, location.country, location.city, location.org
--   FROM unique_ips AS u
--   JOIN ip_location(u.ip) AS location ON location.ip = u.ip;
CREATE OR REPLACE FUNCTION ip_location(ip TEXT)
    RETURNS TABLE (ip TEXT, country TEXT, city TEXT, org TEXT)
AS $$
    from ipaddress import ip_address
    from json import load
    from urllib.request import urlopen

    import plpy


    # initialize record with input IP and NULL values
    record = (ip, None, None, None)

    # validate IP format
    try:
        ip_address(ip)
    except ValueError:
        plpy.warning(f"Invalid IP '{ip}' provided to ip_location")
        yield record
        return

    # fetch cached record or query API
    if not (record := SD.get(ip)):
        try:
            with urlopen(
                f"http://ip-api.com/json/{ip}",
                timeout=2
            ) as response:
                data = load(response)

            if data.get('status') == 'success':
                record = (
                    ip,
                    data.get("country"),
                    data.get("city"),
                    data.get("org")
                )

                SD[ip] = record
        except Exception as ex:
            plpy.warning(f"ip_location failed for {ip}: {ex}")

    yield record
$$ LANGUAGE plpython3u;


-- Create a table and fill it for demonstration
CREATE TABLE IF NOT EXISTS access_log (
    id BIGSERIAL PRIMARY KEY,
    user_id INT,
    ip TEXT,
    path TEXT,
    created_at TIMESTAMP DEFAULT now()
);


INSERT INTO access_log (user_id, ip, path) VALUES
    (1, '8.8.8.8', '/home'),
    (2, '1.1.1.1', '/login'),
    (3, '8.8.8.8', '/dashboard'),
    (4, '208.67.222.222', '/home'),
    (5, '1.1.1.1', '/settings'),
    (6, 'invalid-ip', '/test');


SELECT
    log.id,
    log.ip,
    location.country,
    location.city,
    location.org
FROM
    access_log AS log
    LEFT JOIN ip_location(log.ip) AS location ON location.ip = log.ip;


-- Demo cleanup
-- DROP TABLE IF EXISTS access_log;
