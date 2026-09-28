import os
from fastapi import FastAPI, Depends, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse, FileResponse
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
    "nombre": "El nombre del perrito es obligatorio.",
    "latitud": "Falta la ubicación (latitud).",
    "longitud": "Falta la ubicación (longitud).",
    "color_principal_id": "Debes seleccionar un color principal.",
    "clave_idempotencia": "Falta información interna del formulario, recarga la página.",
    "foto": "Debes subir una fotografía del perrito.",
}

@app.exception_handler(RequestValidationError)
async def manejador_errores_validacion(request: Request, exc: RequestValidationError):
    primer_error = exc.errors()[0]
    campo = primer_error["loc"][-1]
    mensaje = MENSAJES_CAMPOS.get(campo, f"Hay un problema con el campo '{campo}'.")
    return JSONResponse(status_code=422, content={"detail": mensaje})

app.include_router(perritos.router)
app.include_router(catalogos.router)

@app.get("/salud-db")
def salud_db(db: Session = Depends(get_db)):
    db.execute(text("SELECT 1"))
    return {"mensaje": "Conexión a la base de datos exitosa"}

RUTA_INDEX = os.path.join(os.path.dirname(__file__), "..", "..", "index.html")

@app.get("/")
def frontend():
    return FileResponse(RUTA_INDEX)