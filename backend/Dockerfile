# Se construye con el repo completo como contexto (ver docker-compose.yml:
# build.context: .), porque backend/app/main.py sirve ../../index.html,
# es decir el index.html que vive en la raíz del repo, fuera de backend/.
FROM python:3.12-slim

# Pillow y PyMySQL necesitan estas librerías de sistema para compilar/correr.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /code

# Primero sólo las dependencias, para que Docker las reutilice en rebuilds
COPY backend/requirements.txt backend/requirements.txt
RUN pip install --no-cache-dir -r backend/requirements.txt

# Código del backend y el frontend que éste sirve en "/"
COPY backend backend
COPY index.html index.html

WORKDIR /code/backend
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
