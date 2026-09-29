# 🐾 Registro de Perritos de la Calle

Sistema de registro ciudadano de perros callejeros: los usuarios reportan un perrito con foto, ubicación en mapa, raza y colores.

## Equipo y roles

- **Backend (API):** Valery Alvarado — Python + FastAPI + SQLAlchemy
- **Frontend:** Marisol Hernández — HTML, CSS, JavaScript, Leaflet.js
- **Base de datos (DBA):** Alma Bujanda — MySQL/MariaDB vía phpMyAdmin

## Tecnologías usadas

- **Backend:** [Python 3](https://www.python.org/downloads/) · [FastAPI](https://fastapi.tiangolo.com/) · [Uvicorn](https://www.uvicorn.org/) · [SQLAlchemy](https://www.sqlalchemy.org/) (ORM) · [Pydantic](https://docs.pydantic.dev/) · [Pillow](https://pypi.org/project/pillow/) (validación de imágenes)
- **Base de datos:** [MySQL](https://dev.mysql.com/downloads/mysql/) / [MariaDB](https://mariadb.org/download/)
- **Frontend:** HTML, CSS, JavaScript · [Leaflet.js](https://leafletjs.com/download.html) para mapas
- **Control de versiones:** [Git](https://git-scm.com/downloads) + [GitHub](https://github.com/) (ramas y Pull Requests)
## Arquitectura

El sistema sigue una arquitectura cliente-servidor de 3 capas:

```
┌─────────────────────┐      HTTP/JSON       ┌──────────────────────┐      SQL       ┌─────────────────┐
│  Frontend (cliente)  │  ────────────────►   │   Backend (API REST) │  ─────────►    │  Base de datos   │
│  HTML + JS + Leaflet │  ◄────────────────   │  FastAPI + SQLAlchemy│  ◄─────────    │  MySQL/MariaDB   │
└─────────────────────┘                       └──────────────────────┘                └─────────────────┘
```

- **Capa de presentación (frontend):** `index.html`, corre en el navegador del usuario (o del celular vía túnel HTTPS). Se comunica con el backend por `fetch()` usando JSON y `multipart/form-data`.
- **Capa de aplicación (backend):** API REST construida con FastAPI. Recibe las peticiones HTTP, valida los datos (Pydantic), aplica las reglas de negocio (idempotencia, validación de imágenes) y se comunica con la base de datos a través del ORM SQLAlchemy.
- **Capa de datos:** MySQL/MariaDB, con tablas relacionadas por llaves foráneas (`perritos`, `razas`, `colores`, `perrito_colores`).

El backend expone su documentación interactiva (Swagger UI) en `/docs`, generada automáticamente por FastAPI a partir de los esquemas Pydantic.

## Requisitos del sistema y versiones

| Software | Versión usada / mínima | Notas |
|---|---|---|
| Python | 3.11+ | Se probó con Python 3.11 y 3.12 |
| MySQL / MariaDB | MySQL 8.x o MariaDB 10.4+ | Se probó con MariaDB 10.4.32 (vía phpMyAdmin) |
| pip | incluido con Python | Gestor de paquetes |
| Node.js | No requerido | El frontend es HTML/JS plano, no necesita build |
| Sistema operativo | macOS 13+ o Windows 10/11 | Instrucciones de instalación separadas abajo |

Las dependencias exactas de Python (con sus versiones) están fijadas en `backend/requirements.txt` y se instalan automáticamente en el paso de instalación.

## Alternativa sin Git: descargar el proyecto como ZIP

Si no tienes Git instalado (o no quieres instalarlo), puedes descargar el proyecto directamente sin usar `git clone`:

1. Ve a `https://github.com/Val-Bere/Proyecto-perritos` en tu navegador.
2. Da clic en el botón verde **"Code"** y luego en **"Download ZIP"**.
3. Descomprime el archivo ZIP descargado:
   - **En macOS:** doble clic en el archivo `.zip` descargado (normalmente en tu carpeta `Descargas`).
   - **En Windows:** clic derecho sobre el `.zip` → **"Extraer todo..."** → elige dónde guardarlo.
4. Abre una terminal (macOS) o PowerShell (Windows) y navega a la carpeta que acabas de extraer:
   ```
   cd ruta/a/la/carpeta/Proyecto-perritos-main
   ```
   > Nota: GitHub agrega `-main` al nombre de la carpeta cuando descargas el ZIP en vez de usar `git clone`.

Desde aquí, continúa con el paso **2 en adelante** de la sección "Instalación y ejecución" (crear el entorno virtual, etc.) — todo lo demás es exactamente igual, solo te saltas el paso de `git clone` porque ya tienes el código descargado.

> **Limitación:** con este método no podrás hacer `git pull` para recibir actualizaciones futuras del repositorio, ni contribuir con tus propios cambios — tendrías que volver a descargar el ZIP cada vez que el código cambie. Para el proyecto en equipo, Git sigue siendo la forma recomendada.

## Instalación y ejecución

### En macOS

1. Verifica que tienes Python 3.11+ instalado:
   ```
   python3 --version
   ```
   Si no lo tienes, instálalo desde [python.org](https://www.python.org/downloads/) o con Homebrew:
   ```
   brew install python@3.11
   ```
2. Crea una carpeta donde vas a guardar el proyecto y entra a ella:
```
   mkdir ~/Proyectos
   cd ~/Proyectos
```

3. Clona el repositorio:
   ```
   git clone https://github.com/Val-Bere/Proyecto-perritos.git
   cd Proyecto-perritos
   ```
   (Si no tienes Git, ve a la sección "Alternativa sin Git" más arriba.)

4. Entra al backend, crea y activa el entorno virtual:
   ```
   cd backend
   python3 -m venv venv
   source venv/bin/activate
   ```

5. Instala las dependencias:
   ```
   pip install -r requirements.txt
   ```
      > Este comando descarga automáticamente cada paquete listado en `requirements.txt` desde [PyPI](https://pypi.org/) (el repositorio oficial de paquetes de Python) — no necesitas descargarlos manualmente. Puedes ver la página de cada uno aquí: [fastapi](https://pypi.org/project/fastapi/), [uvicorn](https://pypi.org/project/uvicorn/), [sqlalchemy](https://pypi.org/project/SQLAlchemy/), [pydantic](https://pypi.org/project/pydantic/), [pillow](https://pypi.org/project/pillow/), [pymysql](https://pypi.org/project/PyMySQL/), [python-dotenv](https://pypi.org/project/python-dotenv/), [python-multipart](https://pypi.org/project/python-multipart/).

6. Crea tu `.env` a partir del ejemplo y llena tus datos reales de MySQL:
   ```
   cp .env.example .env
   ```
   ```
   DB_HOST=localhost
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=tu_password
   DB_NAME=perritos_db
   RUTA_IMAGENES=/ruta/fuera/del/proyecto/para/guardar/fotos
   ```
   > `RUTA_IMAGENES` debe estar fuera del proyecto para que las fotos no se suban al repositorio.

7. Importa la base de datos (con MySQL instalado, por ejemplo vía [MySQL Community Server](https://dev.mysql.com/downloads/mysql/) o [MAMP](https://www.mamp.info/)):
   ```
   mysql -u root -p perritos_db < ../database/schema.sql
   mysql -u root -p perritos_db < ../database/catalogos.sql
   ```

8. Levanta el servidor:
   ```
   uvicorn app.main:app --reload
   ```

9. Abre `http://localhost:8000/` en tu navegador — ahí se sirve el frontend directamente desde el backend.

### En Windows

1. Instala Python 3.11+ desde [python.org](https://www.python.org/downloads/windows/) — marca la casilla **"Add python.exe to PATH"** durante la instalación.

2. Crea una carpeta donde vas a guardar el proyecto y entra a ella:
```
   mkdir C:\Proyectos
   cd C:\Proyectos
```

3. Clona el repositorio (con [Git para Windows](https://git-scm.com/download/win) instalado), usando la terminal PowerShell o Git Bash:
   ```
   git clone https://github.com/Val-Bere/Proyecto-perritos.git
   cd Proyecto-perritos
   ```
   (Si no tienes Git, ve a la sección "Alternativa sin Git" más arriba.)

4. Entra al backend, crea y activa el entorno virtual:
   ```
   cd backend
   python -m venv venv
   venv\Scripts\activate
   ```
   > En PowerShell, si aparece un error de permisos al activar, corre primero: `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`

5. Instala las dependencias:
   ```
   pip install -r requirements.txt
   ```
      > Este comando descarga automáticamente cada paquete listado en `requirements.txt` desde [PyPI](https://pypi.org/) (el repositorio oficial de paquetes de Python) — no necesitas descargarlos manualmente. Puedes ver la página de cada uno aquí: [fastapi](https://pypi.org/project/fastapi/), [uvicorn](https://pypi.org/project/uvicorn/), [sqlalchemy](https://pypi.org/project/SQLAlchemy/), [pydantic](https://pypi.org/project/pydantic/), [pillow](https://pypi.org/project/pillow/), [pymysql](https://pypi.org/project/PyMySQL/), [python-dotenv](https://pypi.org/project/python-dotenv/), [python-multipart](https://pypi.org/project/python-multipart/).

6. Crea tu `.env` a partir del ejemplo:
   ```
   copy .env.example .env
   ```
   Y llena tus datos reales de MySQL (mismo formato que en macOS, ver arriba). Instala MySQL con el [MySQL Installer para Windows](https://dev.mysql.com/downloads/installer/) o usando [XAMPP](https://www.apachefriends.org/es/index.html), que incluye phpMyAdmin.

7. Importa la base de datos (desde phpMyAdmin, importando los archivos directamente, o por línea de comandos si tienes `mysql` en el PATH):
   ```
   mysql -u root -p perritos_db < ..\database\schema.sql
   mysql -u root -p perritos_db < ..\database\catalogos.sql
   ```

8. Levanta el servidor:
   ```
   uvicorn app.main:app --reload
   ```

9. Abre `http://localhost:8000/` en tu navegador.

> **Nota:** el comando `cloudflared` para la demo desde celular (ver más abajo) también está disponible para Windows — se descarga desde la [página de releases de cloudflared](https://github.com/cloudflare/cloudflared/releases) en vez de usar `brew`.

## Seguridad y validaciones

- **CORS** habilitado para permitir que el frontend se comunique con la API sin bloqueos del navegador.
- **Validación de imágenes:** cada foto se abre con Pillow para confirmar que es una imagen real (no solo por extensión), se restringe a JPEG/PNG/WEBP, y se guarda con un nombre generado por el servidor (UUID) fuera de la carpeta del proyecto, evitando ataques de path traversal y sobreescrituras.
- **Mensajes de error amigables:** los errores de validación se traducen a español entendible para el usuario final en vez de mostrar errores técnicos de Pydantic.

## Estructura del proyecto

```
├── backend/
│   ├── app/
│   │   ├── main.py          # Configuración de la app, CORS, manejo de errores
│   │   ├── database.py      # Conexión a MySQL con SQLAlchemy
│   │   ├── models.py        # Modelos ORM (Perrito, Raza, Color, PerritoColor)
│   │   ├── schemas.py       # Esquemas Pydantic
│   │   └── routers/
│   │       ├── perritos.py
│   │       └── catalogos.py
│   ├── requirements.txt
│   └── .env.example
├── database/
│   ├── schema.sql
│   └── catalogos.sql
└── index.html
```

---

## Endpoints de la API

Base URL local: `http://localhost:8000`

Documentación interactiva disponible en `/docs` (Swagger UI).

### Perritos

| Método | Ruta | Descripción |
|---|---|---|
| `POST` | `/perritos/` | Registra un nuevo perrito |
| `GET` | `/perritos/` | Lista todos los perritos registrados |
| `GET` | `/perritos/{perrito_id}` | Obtiene el detalle de un perrito por su id |
| `GET` | `/perritos/imagenes/{nombre_archivo}` | Sirve el archivo de imagen de un perrito |

#### `POST /perritos/`

Content-Type: `multipart/form-data` (no JSON, porque incluye un archivo).

**Campos:**

| Campo | Tipo | Obligatorio | Descripción |
|---|---|---|---|
| `nombre` | texto | Sí | No puede estar vacío ni ser solo espacios |
| `id_raza` | número | No | Id de una raza del catálogo (`/catalogos/razas`). Vacío = sin raza |
| `latitud` | decimal | Sí | Coordenada de ubicación |
| `longitud` | decimal | Sí | Coordenada de ubicación |
| `color_principal_id` | número | Sí | Id de un color del catálogo (`/catalogos/colores`) |
| `colores_adicionales` | texto | No | Ids separados por coma, ej. `"2,3"`. Máximo 2, no puede repetir el color principal |
| `clave_idempotencia` | texto | Sí | Generada por el cliente al abrir el formulario (ver sección Idempotencia) |
| `foto` | archivo | Sí | Imagen JPG, PNG o WEBP |

**Respuestas:**
- `201 Created` — perrito creado por primera vez.
- `200 OK` — la `clave_idempotencia` ya existía; se regresa el perrito ya creado, sin duplicar.
- `400 Bad Request` — nombre vacío, color repetido, o color/raza inexistente en el catálogo.
- `422 Unprocessable Entity` — falta un campo obligatorio o tiene un tipo inválido.

**Ejemplo de respuesta exitosa:**
```json
{
  "id": 11,
  "nombre": "Firulais",
  "foto_archivo": "093a4eaa2a9c4dbfa328e3c40e52c752.png",
  "id_raza": 1,
  "latitud": 25.4383,
  "longitud": -100.9737,
  "fecha_registro": "2026-09-27T01:37:15",
  "colores": [
    { "id": 2, "nombre": "Blanco", "es_principal": true }
  ]
}
```

#### `GET /perritos/`
Regresa un arreglo con todos los perritos, en el mismo formato que el ejemplo anterior.

#### `GET /perritos/{perrito_id}`
- `200 OK` — mismo formato que arriba.
- `404 Not Found` — no existe un perrito con ese id.

#### `GET /perritos/imagenes/{nombre_archivo}`
Regresa el archivo de imagen directamente (no JSON). `nombre_archivo` es el valor del campo `foto_archivo` que devuelve el registro del perrito.

### Catálogos

| Método | Ruta | Descripción |
|---|---|---|
| `GET` | `/catalogos/razas` | Lista las razas disponibles |
| `GET` | `/catalogos/colores` | Lista los colores disponibles |

**Ejemplo de respuesta (`/catalogos/colores`):**
```json
[
  { "id": 1, "nombre": "Negro" },
  { "id": 2, "nombre": "Blanco" }
]
```

### Utilitarios

| Método | Ruta | Descripción |
|---|---|---|
| `GET` | `/` | Sirve el frontend (index.html) |
| `GET` | `/salud-db` | Verifica que la conexión a la base de datos funciona |

## Paradigmas

Esta sección explica qué paradigma se usó en cada parte del backend y por qué.

### Declarativo vs. imperativo

El backend usa **SQLAlchemy** como capa de acceso a datos, lo que nos permite escribir consultas declarativas: le decimos a la base de datos *qué* queremos, no *cómo* obtenerlo, y es MySQL quien decide cómo ejecutarlo.

- **Declarativo**: filtrado, `JOIN` y agregación ocurren dentro de la consulta SQL, nunca con ciclos en Python:
  - `app/routers/perritos.py`, función `perritos_por_color`: usa `.join()`, `.group_by()` y `func.count()` para obtener el conteo de perritos por color directamente desde la base de datos.
  - `app/models.py`: las relaciones (`relationship()`) entre `Perrito`, `Color` y `PerritoColor` describen *qué* está relacionado con qué; SQLAlchemy genera el `JOIN` necesario cuando se accede a ellas.
  - Los modelos de `app/models.py` (`class Perrito(Base): ...`) son en sí mismos declarativos: describen la forma de la tabla, no los pasos para crearla.

- **Imperativo**: la lógica de validación y control de flujo en `app/routers/perritos.py` (función `crear_perrito`) sí es imperativa — es una secuencia explícita de pasos: validar nombre, validar colores, guardar imagen, insertar en la base, en ese orden, con `if` y `raise` para controlar el flujo según cada caso.

- La interfaz también declara: los formularios HTML de la aplicación (frontend) describen *qué* campos existen y su forma, no cómo dibujarlos en pantalla; eso lo resuelve el navegador.

### Transformación funcional

En `app/routers/perritos.py`, dentro de `crear_perrito`, la lista de colores adicionales se construye así:

```python
lista_adicionales = [int(x) for x in colores_adicionales.split(",") if x.strip()]
```

Esta línea es una comprehension de lista: combina el efecto de un `filter` (descarta elementos vacíos con `if x.strip()`) y un `map` (convierte cada elemento a entero con `int(x)`), sin usar un ciclo `for` explícito con `.append()` y sin mutar ninguna estructura existente — genera una lista nueva a partir de `colores_adicionales.split(",")`.

### Orientado a objetos

Los modelos de datos (`app/models.py`) están definidos como clases (`Raza`, `Color`, `Perrito`, `PerritoColor`), cada una heredando de `Base` (SQLAlchemy ORM) y encapsulando tanto sus columnas como su comportamiento — por ejemplo, la propiedad calculada `colores` dentro de `Perrito`, que transforma los registros de la tabla intermedia en la forma que la API expone.

### Idempotencia del registro

Se usa una **clave de idempotencia generada por el cliente** (frontend) al momento de abrir el formulario de registro (`crypto.randomUUID()`), enviada como parte del `multipart/form-data` en cada intento de envío, incluyendo reintentos.

Se eligió esta estrategia (en vez de que el servidor "adivine" si dos peticiones son la misma) porque es la única forma confiable de identificar un reintento: el cliente sabe con certeza que dos envíos son "el mismo intento" porque él mismo generó y reutilizó la clave, mientras que el servidor no puede diferenciar un doble clic legítimo de dos perritos distintos con datos parecidos.

Antes de cualquier validación o inserción, `crear_perrito` verifica si ya existe un registro con esa `clave_idempotencia`:

```python
perrito_existente = db.query(models.Perrito).filter(
    models.Perrito.clave_idempotencia == clave_idempotencia
).first()
if perrito_existente:
    response.status_code = status.HTTP_200_OK
    return perrito_existente
```

Si existe, se regresa el mismo perrito con código `200` (sin volver a guardar la imagen ni tocar la base de datos). Si no existe, se crea normalmente y se regresa `201`.

**Prueba del doble envío**: enviar dos veces el mismo `POST /perritos/` con idéntico `clave_idempotencia` — la primera respuesta es `201` con un `id` nuevo; la segunda es `200` con el mismo `id`, y `GET /perritos/` confirma que solo existe un registro.

## Demo desde celular

Para probar cámara y geolocalización desde un teléfono (requieren HTTPS):

1. Levanta el backend: `uvicorn app.main:app --reload`
2. En otra terminal: `cloudflared tunnel --url http://localhost:8000`
3. Abre en el celular la URL `https://....trycloudflare.com` que se genera.

> Nota: la URL cambia cada vez que se vuelve a correr el túnel.
