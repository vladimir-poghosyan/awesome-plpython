-- Generate a cryptographically strong, URL-safe random token.
--
-- Uses Python's "secrets" module, designed for secure token generation.
--
-- Parameters:
-- - nbytes → number of random bytes before encoding (default: 16)
--
-- Behavior:
-- - Returns a URL-safe, base64-encoded string.
-- - The resulting string is longer than nbytes due to encoding.
-- - Suitable for use in URLs, API keys, session tokens, etc.
-- - Can also be used inside a BEFORE INSERT trigger to generate
--   unique random identifiers for new rows.
--
-- Notes:
-- - Uses a cryptographically secure random number generator.
-- - Output is non-deterministic (different result on each call).
-- - Returns NULL if input is NULL (PostgreSQL-style null propagation).
--
-- Usage examples:
--   SELECT generate_token_urlsafe();
--   SELECT generate_token_urlsafe(32);
--   -- Example trigger usage:
--   -- CREATE TRIGGER tg_generate_id
--   -- BEFORE INSERT ON my_table
--   -- FOR EACH ROW EXECUTE FUNCTION generate_token_urlsafe_trigger();
CREATE OR REPLACE FUNCTION generate_token_urlsafe(nbytes INTEGER DEFAULT 16)
    RETURNS TEXT
AS $$
    from secrets import token_urlsafe


    # return NULL if input is NULL
    if nbytes is None:
        return None

    return token_urlsafe(nbytes)
$$ LANGUAGE plpython3u;
