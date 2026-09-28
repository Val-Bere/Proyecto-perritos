import io  # Para tratar los bytes de la imagen como si fueran un archivo en memoria
import os
import uuid  # Genera identificadores únicos (para nombrar las imágenes)
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, Response, status
from fastapi.responses import FileResponse  # Para devolver un archivo (la imagen)
from sqlalchemy import func  # Funciones de SQL como COUNT
from sqlalchemy.orm import Session
from PIL import Image  # Pillow: sirve para comprobar que un archivo es realmente una imagen
from app.database import get_db
from app import models, schemas

# Agrupa los endpoints bajo /perritos
router = APIRouter(prefix="/perritos", tags=["perritos"])

# Carpeta donde se guardan las fotos: viene del .env y está FUERA del proyecto
RUTA_IMAGENES = os.getenv("RUTA_IMAGENES")
# Formatos que acepta el sistema (nombres como los reporta Pillow)
FORMATOS_PERMITIDOS = {"JPEG", "PNG", "WEBP"}


def guardar_imagen(archivo: UploadFile) -> str:
    """Valida que el archivo sea una imagen real, la guarda y devuelve el nombre generado."""
    contenido = archivo.file.read()  # Lee todos los bytes del archivo subido

    # Se intenta ABRIR como imagen. Si alguien renombró un .exe a .jpg, aquí falla.
    try:
        imagen = Image.open(io.BytesIO(contenido))
        imagen.verify()  # Revisa que el contenido sea una imagen íntegra
        formato = imagen.format  # Formato REAL detectado (JPEG, PNG...), no el de la extensión
    except Exception:
        raise HTTPException(status_code=400, detail="El archivo no es una imagen válida")

    if formato not in FORMATOS_PERMITIDOS:
        raise HTTPException(status_code=400, detail=f"Formato de imagen no permitido: {formato}")

    # El backend inventa el nombre; el nombre original del usuario nunca se usa (seguridad)
    extension = {"JPEG": "jpg", "PNG": "png", "WEBP": "webp"}[formato]
    nombre_generado = f"{uuid.uuid4().hex}.{extension}"

    os.makedirs(RUTA_IMAGENES, exist_ok=True)  # Crea la carpeta si no existe
    with open(os.path.join(RUTA_IMAGENES, nombre_generado), "wb") as f:  # "wb" = escribir bytes
        f.write(contenido)

    return nombre_generado


@router.post("/", response_model=schemas.PerritoOut, status_code=201)
def crear_perrito(
    response: Response,  # Permite cambiar el código HTTP de la respuesta (201 → 200)
    nombre: str = Form(...),  # Form(...) = campo de formulario obligatorio
    id_raza: Optional[int] = Form(None),  # Opcional
    latitud: float = Form(...),
    longitud: float = Form(...),
    color_principal_id: int = Form(...),
    colores_adicionales: Optional[str] = Form(""),  # Ej. "2,3"
    clave_idempotencia: str = Form(...),  # La genera el frontend al abrir el formulario
    foto: UploadFile = File(...),  # El archivo de imagen
    db: Session = Depends(get_db),  # FastAPI inyecta la sesión de base de datos
):
    # --- IDEMPOTENCIA: si esta clave ya se procesó, devolvemos el mismo perrito ---
    perrito_existente = db.query(models.Perrito).filter(
        models.Perrito.clave_idempotencia == clave_idempotencia
    ).first()
    if perrito_existente:
        response.status_code = status.HTTP_200_OK  # 200 = "ya existía", no 201 = "creado"
        return perrito_existente  # Mismo id, sin crear nada ni guardar otra foto

    # --- VALIDACIONES DEL SERVIDOR (nunca se confía en que el frontend las hizo) ---
    nombre_limpio = nombre.strip()  # Quita espacios al inicio y al final
    if not nombre_limpio:  # Un nombre de puros espacios queda vacío
        raise HTTPException(status_code=400, detail="El nombre no puede estar vacío ni ser solo espacios")

    # Convierte "2,3" en [2, 3]. Es la transformación FUNCIONAL: filtra vacíos (if)
    # y convierte a entero (int) en una sola expresión, sin ciclo for ni append.
    lista_adicionales = []
    if colores_adicionales:
        try:
            lista_adicionales = [int(x) for x in colores_adicionales.split(",") if x.strip()]
        except ValueError:
            raise HTTPException(status_code=400, detail="colores_adicionales debe ser una lista de números separados por coma")

    if len(lista_adicionales) > 2:  # Máximo 3 colores en total: 1 principal + 2 adicionales
        raise HTTPException(status_code=400, detail="Máximo 2 colores adicionales")

    todos_los_colores = [color_principal_id] + lista_adicionales
    # Un set elimina repetidos: si su tamaño es menor que la lista, había un color repetido
    if len(todos_los_colores) != len(set(todos_los_colores)):
        raise HTTPException(status_code=400, detail="No se puede repetir un color")

    # Consulta declarativa: MySQL cuenta cuántos de esos colores existen (WHERE id IN (...))
    colores_existentes = db.query(models.Color).filter(
        models.Color.id.in_(todos_los_colores)
    ).count()
    if colores_existentes != len(todos_los_colores):
        raise HTTPException(status_code=400, detail="Uno o más colores no existen en el catálogo")

    # La foto se valida y se guarda hasta el final, cuando todo lo demás ya es correcto
    nombre_archivo = guardar_imagen(foto)

    # --- GUARDADO ---
    nuevo_perrito = models.Perrito(
        nombre=nombre_limpio,
        foto_archivo=nombre_archivo,
        id_raza=id_raza,
        latitud=latitud,
        longitud=longitud,
        clave_idempotencia=clave_idempotencia,
    )
    db.add(nuevo_perrito)  # Lo marca para insertar
    db.flush()  # Lo envía a MySQL para que le asigne un id, sin cerrar la transacción

    # Ya con el id del perrito, se guardan sus colores en la tabla intermedia
    db.add(models.PerritoColor(id_perrito=nuevo_perrito.id, id_color=color_principal_id, es_principal=True))
    for id_color in lista_adicionales:
        db.add(models.PerritoColor(id_perrito=nuevo_perrito.id, id_color=id_color, es_principal=False))

    db.commit()  # Confirma TODO junto: si algo falló antes, no queda nada a medias
    db.refresh(nuevo_perrito)  # Recarga el objeto con los valores que puso MySQL (fecha, etc.)
    return nuevo_perrito


@router.get("/", response_model=list[schemas.PerritoOut])
def listar_perritos(db: Session = Depends(get_db)):
    return db.query(models.Perrito).all()  # SELECT * FROM perritos


# Esta ruta va ANTES de "/{perrito_id}": si no, FastAPI creería que "estadisticas" es un id
@router.get("/estadisticas/por-color", response_model=list[schemas.ConteoColorOut])
def perritos_por_color(db: Session = Depends(get_db)):
    # Agregación declarativa: JOIN + GROUP BY + COUNT, todo lo resuelve MySQL
    resultados = (
        db.query(models.Color.nombre, func.count(models.PerritoColor.id_perrito))
        .join(models.PerritoColor, models.PerritoColor.id_color == models.Color.id)
        .group_by(models.Color.nombre)
        .all()
    )
    return [{"color": nombre, "total": total} for nombre, total in resultados]


@router.get("/{perrito_id}", response_model=schemas.PerritoOut)
def ver_perrito(perrito_id: int, db: Session = Depends(get_db)):
    perrito = db.query(models.Perrito).filter(models.Perrito.id == perrito_id).first()
    if not perrito:
        raise HTTPException(status_code=404, detail="Perrito no encontrado")
    return perrito


@router.get("/imagenes/{nombre_archivo}")
def obtener_imagen(nombre_archivo: str):
    # basename descarta cualquier ruta: "../../secreto" se convierte en "secreto"
    nombre_seguro = os.path.basename(nombre_archivo)
    ruta = os.path.join(RUTA_IMAGENES, nombre_seguro)
    if not os.path.isfile(ruta):
        raise HTTPException(status_code=404, detail="Imagen no encontrada")
    return FileResponse(ruta)  # Devuelve la imagen; el navegador nunca ve la carpeta real