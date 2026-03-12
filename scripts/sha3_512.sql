-- SHA3-512 hashing using Python's hashlib module (without requiring pgcrypto)
--
-- Usage example: SELECT sha3_512('password');
CREATE OR REPLACE FUNCTION sha3_512(data TEXT)
    RETURNS TEXT
AS $$
    from hashlib import sha3_512


    return sha3_512(data.encode()).hexdigest()
$$ LANGUAGE plpython3u;
