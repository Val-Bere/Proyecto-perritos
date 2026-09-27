from fastapi import FastAPI, Depends, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.database import get_db
from app.routers import perritos, catalogos

app = FastAPI(title="Registro de perritos de la calle")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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
    primer_error = exc.errors()[0]
    campo = primer_error["loc"][-1]
    mensaje = MENSAJES_CAMPOS.get(campo, f"El campo '{campo}' no es válido: {primer_error['msg']}")
    return JSONResponse(status_code=422, content={"detail": mensaje})

app.include_router(perritos.router)
app.include_router(catalogos.router)

@app.get("/")
def raiz():
    return {"mensaje": "API de perritos funcionando"}

@app.get("/salud-db")
def salud_db(db: Session = Depends(get_db)):
    db.execute(text("SELECT 1"))
    return {"mensaje": "Conexión a la base de datos exitosa"}