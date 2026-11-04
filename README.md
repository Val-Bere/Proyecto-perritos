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

### P2: el servicio Elixir y el proxy

Para el Proyecto 2 se agregan tres piezas más, sin tocar el frontend ni el backend de arriba:

```
visitante ──► https://….trycloudflare.com
                    │
                    ▼
              túnel (cloudflared)
                    │
                    ▼
              proxy (nginx)
              │ /            │ /f/
              ▼               ▼
      backend (sirve también   servicio Elixir (P2)
      el frontend en "/")      lee los avistamientos
              │                vía HTTP del backend
              ▼                (Opción B, Req)
          base de datos
```

El servicio Elixir (`funcional/`) obtiene los datos **a través del backend del P1** (Opción B): le pide `GET /perritos/` por HTTP con `Req` y convierte la respuesta a sus propios structs. No se conecta directo a la base de datos.

## Docker: levantar todo el sistema (P2)

Con esto nadie necesita instalar Python, Elixir ni MySQL en su máquina: todo corre en contenedores.

1. **Requisitos:** Docker Desktop (Windows/macOS) o Docker Engine + plugin Compose (Linux). Comprobar con `docker --version` y `docker compose version`.
2. **Configurar variables de entorno** (una sola vez):
   ```
   cp .env.example .env
   ```
   Y poner contraseñas propias en `DB_PASSWORD` y `DB_ROOT_PASSWORD` dentro de `.env` (ese archivo no se sube).
3. **Bajar las dependencias de Elixir** (una sola vez, antes del primer build; genera `funcional/mix.lock`, que sí se sube al repo):
   ```
   docker compose run --rm herramientas mix local.hex --force
   docker compose run --rm herramientas mix local.rebar --force
   docker compose run --rm herramientas mix deps.get
   ```
4. **Levantar todo:**
   ```
   docker compose up --build
   ```
   Esto arranca, en este orden de dependencias: la base de datos (con las tablas y el catálogo ya cargados desde `database/schema.sql` y `database/catalogos.sql`), el backend, el servicio Elixir, el proxy nginx y el túnel de Cloudflare.
5. **Probar en local**, en otra terminal:
   ```
   curl http://localhost:8080/f/salud        # debe responder: ok
   curl http://localhost:8080/perritos/      # la API del P1, a través del proxy
   ```
   La app completa (frontend incluido) está en `http://localhost:8080`.
6. **Obtener la URL pública del túnel:**
   ```
   docker compose logs tunel | grep trycloudflare
   ```
   Es un *quick tunnel*: no necesita cuenta de Cloudflare, pero la URL cambia cada vez que el contenedor del túnel se reinicia. El día de la demostración se levanta antes de clase y la URL vigente se comparte con el profesor.

**Datos de muestra.** La primera vez que se crea la base se cargan además 124 avistamientos de prueba (`database/seed_avistamientos.sql`, repartidos por Saltillo en los últimos ~2 meses, con algunos posibles duplicados cercanos). Todos usan la foto de relleno `database/sin-foto.jpg`. Los scripts de `docker-entrypoint-initdb.d` sólo corren con el volumen vacío; para recargar la base desde cero:
```
docker compose down -v
docker compose up --build
```

**Correr las pruebas del núcleo de Elixir** (no necesita que nada esté levantado):
```
docker compose run --rm herramientas mix test
```

**Problemas comunes:**

| Síntoma | Causa | Solución |
|---|---|---|
| `mix test` falla pidiendo variables de entorno | Las pruebas intentaron arrancar la aplicación | El alias `test: "test --no-start"` ya está en `funcional/mix.exs`; no se necesita nada extra |
| El build de `funcional` falla en `COPY mix.lock` | Falta `funcional/mix.lock` | Correr el paso 3 (`mix deps.get`) antes del primer `docker compose up --build` |
| `/f/...` responde 404 desde el navegador pero `/f/salud` con `curl` funciona | Se perdió el prefijo `/f` en la ruta del proxy | En `Perritos.Router` las rutas se escriben completas, con `/f/...`, porque el proxy lo conserva |
| "hoy"/"ayer" salen corridos por unas horas | El contenedor está en UTC | Ya se fija `TZ: America/Monterrey` en `docker-compose.yml` y se instala `tzdata` en el `Dockerfile` de `funcional/` |

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


## Del P1 al P2

**Qué había al terminar el P1:** frontend (`index.html`, con mapa Leaflet), backend FastAPI + SQLAlchemy que también sirve el frontend, y base MySQL/MariaDB con perritos, razas y colores.

**Qué se agregó en el P2:**
- `funcional/`: servicio Elixir (Plug + Bandit + Jason + Req) con la cáscara lista (`router.ex`, `datos.ex`, `avistamiento.ex`) y `/f/salud`. Lee los avistamientos del backend del P1 (Opción B).
- `docker-compose.yml`, `backend/Dockerfile`, `funcional/Dockerfile`: todo el sistema con un solo comando.
- Tres funcionalidades en Elixir, una por integrante: Estadísticas (`/f/estadisticas`), Zonas de concentración (`/f/zonas`) y Perros perdidos de vista (`/f/perdidos`), cada una con su pestaña en el frontend (`index.html`).
- `proxy/nginx.conf`: única puerta de entrada (`/` → backend, `/f/` → servicio Elixir).
- Servicio `tunel` (Cloudflare) para publicar la app.
- `database/seed_avistamientos.sql` y `database/sin-foto.jpg`: datos de muestra.

**Qué se modificó del P1:** el backend no cambió (sólo se empaquetó en Docker; conserva su ruta `/` y las demás sin prefijo). El frontend (`index.html`) ganó tres pestañas nuevas: Estadísticas, Zonas y Perdidos, cada una en commits que mencionan el issue de su autora.

## Funcionalidades del P2 (por integrante)

| Integrante | Funcionalidad | Issue | Rama | Endpoint |
|---|---|---|---|---|
| Valery Alvarado | Zonas de concentración: cuadrícula de la ciudad con el conteo de perros por celda | #13 | `feat/zonas-concentracion` (núcleo y ruta), `revision-2-integracion` (pestaña) | `GET /f/zonas` |
| Marisol Hernández | Estadísticas: los más comunes por color, raza o día | #7 | `estadisticas-7-v2` (núcleo y ruta), `estadisticas-frontend` (pestaña) | `GET /f/estadisticas` |
| Alma Bujanda | Perros perdidos de vista: sin reportarse en N días, agrupados por zona | #14 | `feature/funcionalidad-7-perros-perdidos` (primera versión del filtro), `revision-2-integracion` (integración, endpoint y pestaña) | `GET /f/perdidos` |

### Estadísticas (Marisol Hernández, issue #7)

**Qué hace.** Cuenta cuántos avistamientos hay por color, raza o día de registro y devuelve los más comunes (top N).

**Cómo se usa en la app.** Pestaña **Estadísticas**: se elige "Agrupar por" (color, raza o día) y "Mostrar" (Top 3, 5 o 10), y aparece una gráfica de barras.

**Endpoint.** `GET /f/estadisticas?por=color|raza|dia&n=5`

Ejemplo (`/f/estadisticas?por=dia&n=3`):

```json
[
  {"clave": "2026-10-20", "total": 13},
  {"clave": "2026-10-22", "total": 12},
  {"clave": "2026-10-21", "total": 9}
]
```

Si el backend del P1 no responde, devuelve `503` con `{"error": "backend no disponible"}`.

**Dónde está en el código.**

| Requisito | Archivo y función |
|---|---|
| Núcleo puro | `funcional/lib/perritos/estadisticas.ex` (`Perritos.Estadisticas`) |
| Cáscara (ruta) | `funcional/lib/perritos/router.ex` (`get "/f/estadisticas"`) |
| Orden superior (recibe función) | `contar_por/2` |
| Orden superior (regresa función) | `claves_por/1` |
| Recursión explícita | `primeros/2` |
| Pattern matching y cláusulas múltiples | `claves_por/1`, `nombre_raza/1` |
| Composición con `\|>` | `top/3`, `ordenar/1` |
| Pruebas | `funcional/test/estadisticas_test.exs` (9 pruebas y doctests) |
| Frontend | `index.html` (pestaña `estadisticas`, función `cargarEstadisticas`) |

**Cómo probarla.** `docker compose run --rm herramientas mix test` o, con todo levantado, abrir `http://localhost:8080/f/estadisticas?por=color&n=3`.

### Zonas de concentración (Valery Alvarado, issue #13)

**Qué hace.** Divide la ciudad en una cuadrícula de celdas de N metros y cuenta cuántos perros hay en cada una. Cada zona regresa su conteo, su nivel (`baja`: 1 perro, `media`: 2 a 4, `alta`: 5 o más), su centro y sus límites, para que el frontend sólo tenga que pintarla.

**Cómo se usa en la app.** Pestaña **Zonas**: se elige el tamaño de la celda (250 m, 500 m, 1 km o 2 km) y el mínimo de perros por zona. Las zonas aparecen como rectángulos en el mapa, coloreados por nivel y con el número de perros al centro; al tocar uno se ve el detalle.

**Endpoint.** `GET /f/zonas?metros=1000&minimo=1` (por defecto `metros=500` y `minimo=1`; un valor inválido usa el valor por defecto). Las zonas con más perros van primero.

Ejemplo (recortado a la primera zona de `/f/zonas?metros=1000&minimo=5`):

```json
[
  {
    "celda": {"fila": 2823, "col": -11209},
    "cantidad": 8,
    "nivel": "alta",
    "centro": {"lat": 25.436912, "lon": -100.977376},
    "limites": {"lat_min": 25.432407, "lat_max": 25.441416, "lon_min": -100.981881, "lon_max": -100.972872}
  }
]
```

Si el backend del P1 no responde, devuelve `503`.

**Dónde está en el código.**

| Requisito | Archivo y función |
|---|---|
| Núcleo puro | `funcional/lib/perritos/zonas.ex` (`Perritos.Zonas`) |
| Cáscara (ruta) | `funcional/lib/perritos/router.ex` (`get "/f/zonas"`) |
| Orden superior (regresa función) | `proyeccion_celda/1` |
| Orden superior (recibe función) | `contar_por_celda/2` |
| Recursión explícita | `filtrar_por_minimo/2` |
| Pattern matching y cláusulas múltiples | `extraer_coordenadas/1`, `nivel_concentracion/1`, `metros_a_grados/1` |
| Composición con `\|>` | `concentracion/3` |
| `Stream` | `contar_por_celda/2` (`Stream.map` y `Stream.filter` antes del `Enum.reduce`) |
| Pruebas | `funcional/test/perritos/zonas_test.exs` (6 pruebas y doctests, con casos borde) |
| Frontend | `index.html` (pestaña `zonas`, función `cargarZonas`) |

### Perros perdidos de vista (Alma Bujanda, issue #14)

**Qué hace.** Encuentra los avistamientos que llevan N días o más sin reportarse (días de calendario, visto desde hoy), los ordena del más antiguo al más reciente y los agrupa por zona de la misma cuadrícula de la funcionalidad de zonas.

**Cómo se usa en la app.** Pestaña **Perdidos**: se elige cuántos días sin reportarse (7, 14, 30 o 45) y el tamaño de las zonas. Aparece un mapa con las zonas y los perros, y debajo una tarjeta por zona con la lista de perros (nombre, hace cuántos días se vio por última vez y un botón **Ver detalle**).

**Endpoint.** `GET /f/perdidos?dias=14&metros=1000` (por defecto `dias=14` y `metros=1000`). La fecha de "hoy" la lee el router, no el núcleo. Las zonas con más perros perdidos van primero.

Ejemplo (recortado, `/f/perdidos?dias=45&metros=2000`):

```json
[
  {
    "celda": {"fila": 1410, "col": -5606},
    "cantidad": 3,
    "nivel": "media",
    "centro": {"lat": 25.414389, "lon": -100.999899},
    "limites": {"lat_min": 25.40538, "lat_max": 25.423398, "lon_min": -101.008908, "lon_max": -100.99089},
    "perros": [
      {"id": 106, "nombre": "Kira", "lat": 25.4222794, "lon": -100.9972849,
       "foto": "sin-foto.jpg", "fecha": "2026-08-31T13:34:00", "dias_sin_ver": 64}
    ]
  }
]
```

Si el backend del P1 no responde, devuelve `503`.

**Dónde está en el código.**

| Requisito | Archivo y función |
|---|---|
| Núcleo puro | `funcional/lib/perritos/analisis.ex` (`Perritos.Analisis`) |
| Cáscara (ruta y reloj) | `funcional/lib/perritos/router.ex` (`get "/f/perdidos"`) |
| Orden superior (regresa función) | `perdido_desde/2` |
| Orden superior (recibe función) | `filtrar/2` y `ordenar/2` |
| Recursión explícita | `filtrar/2` |
| Pattern matching y cláusulas múltiples | `dias_sin_ver/2`, `es_perdido/2`, `incluir/3`, `celda_de/2`, `armar_zona/2` |
| Composición con `\|>` | `perdidos/3`, `por_zona/3`, `perdidos_por_zona/4` |
| Pruebas | `funcional/test/perritos/analisis_test.exs` (10 pruebas y doctests, con casos borde) |
| Frontend | `index.html` (pestaña `perdidos`, función `cargarPerdidos`) |

La primera versión del filtro y el ordenamiento es de Alma (rama `feature/funcionalidad-7-perros-perdidos`); se integró al esqueleto, se le agregó la agrupación por zona (reutiliza `Perritos.Zonas`), el endpoint y las pruebas.

## Cómo correr las pruebas

```
docker compose run --rm herramientas mix test
```

Corre las pruebas de las tres funcionalidades (zonas, estadísticas y perros perdidos) y las del router. No necesita base de datos ni servidor levantado.
