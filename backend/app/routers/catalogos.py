from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app import models, schemas

router = APIRouter(prefix="/catalogos", tags=["catalogos"])


@router.get("/razas", response_model=list[schemas.RazaOut])
def listar_razas(db: Session = Depends(get_db)):
    # Devuelve todas las razas para que el frontend llene su <select> dinámicamente
    return db.query(models.Raza).all()


@router.get("/colores", response_model=list[schemas.ColorCatalogoOut])
def listar_colores(db: Session = Depends(get_db)):
    return db.query(models.Color).all()