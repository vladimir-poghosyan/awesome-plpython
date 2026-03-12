-- Usage example: SELECT fernet_decrypt(fernet_encrypt('Hello from PL/Python'));
CREATE OR REPLACE FUNCTION fernet_encrypt(plaintext TEXT, keystore TEXT DEFAULT '/var/tmp/secret.key')
    RETURNS TEXT
AS $$
    from cryptography.fernet import Fernet


    with open(keystore, 'rb') as fd:
        return Fernet(fd.read()).encrypt(plaintext.encode()).decode()
$$ LANGUAGE plpython3u;


CREATE OR REPLACE FUNCTION fernet_decrypt(ciphertext TEXT, keystore TEXT DEFAULT '/var/tmp/secret.key')
    RETURNS TEXT
AS $$
    from cryptography.fernet import Fernet


    with open(keystore, 'rb') as fd:
        return Fernet(fd.read()).decrypt(ciphertext.encode()).decode()
$$ LANGUAGE plpython3u;
