-- SHA3-512 hashing using Python's "hashlib" module (no pgcrypto required).
--
-- Computes a SHA3-512 hash of the input text and returns it as a hex string.
--
-- Notes:
-- - Uses Python's standard library (hashlib), avoiding the need for PostgreSQL extensions.
-- - SHA3-512 is part of the SHA-3 family (Keccak), different from SHA-2 (e.g., SHA-256).
-- - Output is a deterministic, fixed-length hexadecimal string.
-- - Returns NULL if input is NULL (PostgreSQL-style null propagation).
--
-- Use cases:
-- - Data integrity checks
-- - Non-reversible hashing (e.g., identifiers, fingerprints)
--
-- Not intended for:
-- - Password storage without salting/stretching (use dedicated password hashing algorithms instead)
--
-- Usage example:
--   SELECT sha3_512('password');
CREATE OR REPLACE FUNCTION sha3_512(data TEXT)
    RETURNS TEXT
AS $$
    from hashlib import sha3_512


    # return NULL if input is NULL
    if data is None:
        return None

    return sha3_512(data.encode()).hexdigest()
$$ LANGUAGE plpython3u IMMUTABLE;
