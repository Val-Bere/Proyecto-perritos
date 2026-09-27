from pydantic import BaseModel, field_validator
from typing import Optional, List
from datetime import datetime

class PerritoCreate(BaseModel):
    nombre: str
    id_raza: Optional[int] = None
    foto_archivo: str
    latitud: float
    longitud: float
    color_principal_id: int
    colores_adicionales: List[int] = []

    @field_validator("nombre")
    @classmethod
    def nombre_no_vacio(cls, valor):
        if not valor.strip():
            raise ValueError("El nombre no puede estar vacío ni ser solo espacios")
        return valor.strip()

    @field_validator("colores_adicionales")
    @classmethod
    def max_dos_adicionales(cls, valor):
        if len(valor) > 2:
            raise ValueError("Máximo 2 colores adicionales")
        return valor

class ColorOut(BaseModel):
    id: int
    nombre: str
    es_principal: bool

    class Config:
        from_attributes = True

class PerritoOut(BaseModel):
    id: int
    nombre: str
    foto_archivo: str
    id_raza: Optional[int]
    latitud: float
    longitud: float
    fecha_registro: datetime
    colores: List[ColorOut] = []

    class Config:
        from_attributes = True

class RazaOut(BaseModel):
    id: int
    nombre: str

    class Config:
        from_attributes = True

class ColorCatalogoOut(BaseModel):
    id: int
    nombre: str

    class Config:
        from_attributes = True