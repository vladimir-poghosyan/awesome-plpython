-- Simple symmetric encryption/decryption functions using Fernet (from Python's "cryptography" library).
--
-- Provides:
--   • fernet_encrypt → encrypts plaintext into a URL-safe token
--   • fernet_decrypt → decrypts the token back to plaintext
--
-- Notes:
-- - Uses Fernet (AES-based, authenticated encryption).
-- - Requires a valid key stored in a file (keystore path).
-- - The same key must be used for both encryption and decryption.
-- - Returns NULL if any input is NULL (PostgreSQL-style null propagation).
-- - Intended for application-level usage or small-scale data handling,
--   not high-throughput encryption inside queries.
--
-- Requirements:
-- - Python "cryptography" package must be installed in the PostgreSQL environment.
-- - Keystore file must be accessible by the PostgreSQL server process.
--
-- Usage examples:
--   SELECT fernet_encrypt('Hello from PL/Python');
--   SELECT fernet_decrypt(fernet_encrypt('Hello from PL/Python'));
--   SELECT fernet_encrypt('secret', '/custom/path/keyfile');
--
-- Key generation example (run in Python shell):
--   from cryptography.fernet import Fernet
--   open('/var/tmp/secret.key', 'wb').write(Fernet.generate_key());
CREATE OR REPLACE FUNCTION fernet_encrypt(plaintext TEXT, keystore TEXT DEFAULT '/var/tmp/secret.key')
    RETURNS TEXT
AS $$
    from cryptography.fernet import Fernet


    # return NULL if any input is NULL
    if plaintext is None or keystore is None:
        return None

    with open(keystore, 'rb') as fd:
        return Fernet(fd.read()).encrypt(plaintext.encode()).decode()
$$ LANGUAGE plpython3u;


CREATE OR REPLACE FUNCTION fernet_decrypt(ciphertext TEXT, keystore TEXT DEFAULT '/var/tmp/secret.key')
    RETURNS TEXT
AS $$
    from cryptography.fernet import Fernet


    # return NULL if any input is NULL
    if ciphertext is None or keystore is None:
        return None

    with open(keystore, 'rb') as fd:
        return Fernet(fd.read()).decrypt(ciphertext.encode()).decode()
$$ LANGUAGE plpython3u;
