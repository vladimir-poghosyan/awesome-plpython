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

## License
This project is licensed under the MIT License. See LICENSE for details.
