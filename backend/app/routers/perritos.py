from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app import models, schemas

router = APIRouter(prefix="/perritos", tags=["perritos"])

@router.post("/", response_model=schemas.PerritoOut, status_code=201)
def crear_perrito(datos: schemas.PerritoCreate, db: Session = Depends(get_db)):
    # Validar que el color principal no se repita en los adicionales
    todos_los_colores = [datos.color_principal_id] + datos.colores_adicionales
    if len(todos_los_colores) != len(set(todos_los_colores)):
        raise HTTPException(status_code=400, detail="No se puede repetir un color")

    # Validar que los colores existan en el catálogo
    colores_existentes = db.query(models.Color).filter(
        models.Color.id.in_(todos_los_colores)
    ).count()
    if colores_existentes != len(todos_los_colores):
        raise HTTPException(status_code=400, detail="Uno o más colores no existen en el catálogo")

    nuevo_perrito = models.Perrito(
        nombre=datos.nombre,
        foto_archivo=datos.foto_archivo,
        id_raza=datos.id_raza,
        latitud=datos.latitud,
        longitud=datos.longitud,
        clave_idempotencia=f"temporal-{datos.nombre}-{datos.latitud}-{datos.longitud}",
    )
    db.add(nuevo_perrito)
    db.flush()  # asigna el id sin cerrar la transacción todavía

    db.add(models.PerritoColor(
        id_perrito=nuevo_perrito.id,
        id_color=datos.color_principal_id,
        es_principal=True,
    ))
    for id_color in datos.colores_adicionales:
        db.add(models.PerritoColor(
            id_perrito=nuevo_perrito.id,
            id_color=id_color,
            es_principal=False,
        ))

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