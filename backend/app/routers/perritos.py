import os
import uuid
from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from PIL import Image
from app.database import get_db
from app import models, schemas

router = APIRouter(prefix="/perritos", tags=["perritos"])

RUTA_IMAGENES = os.getenv("RUTA_IMAGENES")
EXTENSIONES_PERMITIDAS = {"JPEG", "PNG", "WEBP"}


def guardar_imagen(archivo: UploadFile) -> str:
    contenido = archivo.file.read()

    # Validar que sea una imagen de verdad, no solo que la extensión lo diga
    try:
        imagen = Image.open(__import__("io").BytesIO(contenido))
        imagen.verify()
        formato = imagen.format
    except Exception:
        raise HTTPException(status_code=400, detail="El archivo no es una imagen válida")

    if formato not in EXTENSIONES_PERMITIDAS:
        raise HTTPException(status_code=400, detail=f"Formato de imagen no permitido: {formato}")

    extension = {"JPEG": "jpg", "PNG": "png", "WEBP": "webp"}[formato]
    nombre_generado = f"{uuid.uuid4().hex}.{extension}"

    os.makedirs(RUTA_IMAGENES, exist_ok=True)
    ruta_completa = os.path.join(RUTA_IMAGENES, nombre_generado)
    with open(ruta_completa, "wb") as f:
        f.write(contenido)

    return nombre_generado


@router.post("/", response_model=schemas.PerritoOut, status_code=201)
def crear_perrito(
    nombre: str = Form(...),
    id_raza: Optional[int] = Form(None),
    latitud: float = Form(...),
    longitud: float = Form(...),
    color_principal_id: int = Form(...),
    colores_adicionales: Optional[str] = Form(""),  # ej. "2,3" o vacío
    foto: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    nombre_limpio = nombre.strip()
    if not nombre_limpio:
        raise HTTPException(status_code=400, detail="El nombre no puede estar vacío ni ser solo espacios")

    lista_adicionales = []
    if colores_adicionales:
        try:
            lista_adicionales = [int(x) for x in colores_adicionales.split(",") if x.strip()]
        except ValueError:
            raise HTTPException(status_code=400, detail="colores_adicionales debe ser una lista de números separados por coma")

    if len(lista_adicionales) > 2:
        raise HTTPException(status_code=400, detail="Máximo 2 colores adicionales")

    todos_los_colores = [color_principal_id] + lista_adicionales
    if len(todos_los_colores) != len(set(todos_los_colores)):
        raise HTTPException(status_code=400, detail="No se puede repetir un color")

    colores_existentes = db.query(models.Color).filter(
        models.Color.id.in_(todos_los_colores)
    ).count()
    if colores_existentes != len(todos_los_colores):
        raise HTTPException(status_code=400, detail="Uno o más colores no existen en el catálogo")

    nombre_archivo = guardar_imagen(foto)

    nuevo_perrito = models.Perrito(
        nombre=nombre_limpio,
        foto_archivo=nombre_archivo,
        id_raza=id_raza,
        latitud=latitud,
        longitud=longitud,
        clave_idempotencia=f"temporal-{uuid.uuid4().hex}",
    )
    db.add(nuevo_perrito)
    db.flush()

    db.add(models.PerritoColor(id_perrito=nuevo_perrito.id, id_color=color_principal_id, es_principal=True))
    for id_color in lista_adicionales:
        db.add(models.PerritoColor(id_perrito=nuevo_perrito.id, id_color=id_color, es_principal=False))

    db.commit()
    db.refresh(nuevo_perrito)
    return nuevo_perrito


@router.get("/", response_model=list[schemas.PerritoOut])
def listar_perritos(db: Session = Depends(get_db)):
    return db.query(models.Perrito).all()


@router.get("/{perrito_id}", response_model=schemas.PerritoOut)
def ver_perrito(perrito_id: int, db: Session = Depends(get_db)):
    perrito = db.query(models.Perrito).filter(models.Perrito.id == perrito_id).first()
    if not perrito:
        raise HTTPException(status_code=404, detail="Perrito no encontrado")
    return perrito


@router.get("/imagenes/{nombre_archivo}")
def obtener_imagen(nombre_archivo: str):
    nombre_seguro = os.path.basename(nombre_archivo)  # evita rutas tipo ../../
    ruta = os.path.join(RUTA_IMAGENES, nombre_seguro)
    if not os.path.isfile(ruta):
        raise HTTPException(status_code=404, detail="Imagen no encontrada")
    return FileResponse(ruta)