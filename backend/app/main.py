from fastapi import FastAPI, Depends, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.database import get_db
from app.routers import perritos, catalogos

app = FastAPI(title="Registro de perritos de la calle")

# CORS: sin esto el navegador bloquea las peticiones del frontend, porque corre
# en un origen distinto (otro puerto o dominio) al del backend.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Cualquier origen (para desarrollo; en producción se restringe)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mensajes legibles para cada campo obligatorio que pueda faltar
MENSAJES_CAMPOS = {
    "nombre": "Falta el nombre del perrito",
    "latitud": "Falta la ubicación (latitud)",
    "longitud": "Falta la ubicación (longitud)",
    "color_principal_id": "Falta el color principal",
    "clave_idempotencia": "Falta información interna del formulario (clave_idempotencia)",
    "foto": "Falta la foto",
}


@app.exception_handler(RequestValidationError)
async def manejador_errores_validacion(request: Request, exc: RequestValidationError):
    """Intercepta los errores técnicos de FastAPI y los convierte en mensajes entendibles."""
    primer_error = exc.errors()[0]  # Solo se muestra el primer error
    campo = primer_error["loc"][-1]  # Nombre del campo que falló
    # Si el campo tiene mensaje propio se usa; si no, un mensaje genérico
    mensaje = MENSAJES_CAMPOS.get(campo, f"El campo '{campo}' no es válido: {primer_error['msg']}")
    return JSONResponse(status_code=422, content={"detail": mensaje})


# Conecta los grupos de endpoints a la aplicación
app.include_router(perritos.router)
app.include_router(catalogos.router)


@app.get("/")
def raiz():
    return {"mensaje": "API de perritos funcionando"}


@app.get("/salud-db")
def salud_db(db: Session = Depends(get_db)):
    db.execute(text("SELECT 1"))  # Consulta mínima: si funciona, la conexión está sana
    return {"mensaje": "Conexión a la base de datos exitosa"}