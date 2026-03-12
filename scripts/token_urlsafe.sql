-- Generate a cryptographically strong random URL safe token (https://docs.python.org/3/library/secrets.html#secrets.token_urlsafe)
-- Usage example: SELECT generate_token_urlsafe();
CREATE OR REPLACE FUNCTION generate_token_urlsafe(nbytes INTEGER DEFAULT 16)
   RETURNS TEXT
AS $$
   from secrets import token_urlsafe

   return token_urlsafe(nbytes)
$$ LANGUAGE plpython3u;
