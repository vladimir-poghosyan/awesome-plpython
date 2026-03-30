# awesome-plpython

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18-blue)
![PL/Python](https://img.shields.io/badge/PL%2FPython-enabled-green)
![Docker](https://img.shields.io/badge/docker-compose-blue)
![License](https://img.shields.io/badge/license-MIT-green)

A collection of [PL/Python](https://www.postgresql.org/docs/current/plpython.html) scripts for PostgreSQL ranging from:
- educational examples
- fun experiments
- practical real-world utilities

---

### ⚠️ PL/Python Caveats

- PL/Python requires **superuser/administrative privileges** to install or create functions using `plpython3u`.  
- Running Python code inside PostgreSQL can **block sessions** or impact performance if misused.  
- Scripts using external Python libraries (`cryptography`, `textblob`) require the libraries to be **installed in the database environment**.  
- Not recommended for **high-throughput per-row computations**; best suited for utility functions, small triggers, or demonstrations.  
- Running servers or opening network sockets from PL/Python is **for educational purposes only**.

---

## ⚠️ Disclaimer

The provided Docker setup that boots a PostgreSQL instance with PL/Python enabled is intentionally **simple** and **does NOT follow production best practices**.

---

## Quick Start

1. Clone the repository or download and unpack the zip archive
   
2. Start the PostgreSQL container
```bash
docker compose up -d
```
This will download an Alpine based PostgreSQL image from Docker Hub and enable PL/Python for it.

3. Ensure everything is running correctly
```bash
docker compose ps
```

4. Run a shell inside the container:
```bash
docker exec -it <container_name> sh
```
Or connect to `psql` client directly:
```bash
docker exec -it <container_name> psql -U pgawesome
```

## Running PL/Python Scripts
Scripts are mounted inside the container at `/var/opt/scripts`. From `psql` shell it is possible to edit
```bash
\e /var/opt/scripts/fernet.sql
```
or execute the scripts
```bash
\i /var/opt/scripts/fernet.sql
```
The [official documentation](https://www.postgresql.org/docs/current/app-psql.html) can further guide you through `psql` features.

## Script Reference
### Text Utilities
* [diff.sql](/scripts/diff.sql) - Compare text with optional HTML diff output

### Security / Cryptography
* [fernet.sql](/scripts/fernet.sql) - Symmetric encryption and decryption using [Fernet](https://cryptography.io/en/latest/fernet/)
* [sha3_512.sql](/scripts/sha3_512.sql) - SHA3-512 hash
* [token_urlsafe.sql](/scripts/token_urlsafe.sql) - Secure random [URL-safe token](https://docs.python.org/3/library/secrets.html#secrets.token_urlsafe) generation

### Data Processing
* [sentiment_analysis.sql](scripts/sentiment_analysis.sql) - Simple sentiment analysis function and sample usage

### Demonstrations / Experiments
* [wsgi.sql](/scripts/wsgi.sql) - Minimal WSGI server running inside PostgreSQL (educational/demo only)

## Resources
1. [PL/Python documentation](https://www.postgresql.org/docs/current/plpython.html)
2. [Befriending an Elephant with a Snake: A Practical Guide to PL/Python](https://blog.vxsoft.com/2025/07/befriending-elephant-with-snake.html)
3. [Getting Started with Postgres Functions in PL/Python](https://www.crunchydata.com/blog/getting-started-with-postgres-functions-in-plpython)

## License
This project is licensed under the MIT License. See LICENSE for details.
