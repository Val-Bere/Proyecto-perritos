from pydantic import BaseModel  # Base para definir la forma de los datos
from typing import Optional, List
from datetime import datetime


class ColorOut(BaseModel):
    """Un color dentro de la respuesta de un perrito."""
    id: int
    nombre: str
    es_principal: bool

    class Config:
        from_attributes = True  # Permite construir el schema a partir de objetos del ORM


class PerritoOut(BaseModel):
    """Forma exacta de la respuesta al registrar, listar o ver un perrito."""
    id: int
    nombre: str
    foto_archivo: str
    id_raza: Optional[int]  # Optional = puede ser None (perrito sin raza)
    raza_nombre: Optional[str] = None
    latitud: float
    longitud: float
    fecha_registro: datetime
    colores: List[ColorOut] = []

    class Config:
        from_attributes = True


class RazaOut(BaseModel):
    """Una raza del catálogo."""
    id: int
    nombre: str

    class Config:
        from_attributes = True


class ColorCatalogoOut(BaseModel):
    """Un color del catálogo (sin es_principal, porque aquí no pertenece a ningún perrito)."""
    id: int
    nombre: str

    class Config:
        from_attributes = True


class ConteoColorOut(BaseModel):
    """Resultado de la agregación: cuántos perritos hay de cada color."""
    color: str
    total: int