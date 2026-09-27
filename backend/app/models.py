from sqlalchemy import Column, Integer, String, DECIMAL, DateTime, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base

class Raza(Base):
    __tablename__ = "razas"
    id = Column(Integer, primary_key=True)
    nombre = Column(String(100), unique=True, nullable=False)

class Color(Base):
    __tablename__ = "colores"
    id = Column(Integer, primary_key=True)
    nombre = Column(String(50), unique=True, nullable=False)

class Perrito(Base):
    __tablename__ = "perritos"
    id = Column(Integer, primary_key=True)
    nombre = Column(String(100), nullable=False)
    foto_archivo = Column(String(255), nullable=False)
    id_raza = Column(Integer, ForeignKey("razas.id"), nullable=True)
    latitud = Column(DECIMAL(10, 7), nullable=False)
    longitud = Column(DECIMAL(10, 7), nullable=False)
    fecha_registro = Column(DateTime(timezone=True), server_default=func.now())
    clave_idempotencia = Column(String(100), unique=True, nullable=False)

    raza = relationship("Raza")
    perrito_colores = relationship("PerritoColor", back_populates="perrito")

    @property
    def colores(self):
        return [
            {"id": pc.color.id, "nombre": pc.color.nombre, "es_principal": pc.es_principal}
            for pc in self.perrito_colores
        ]
    @property
    def raza_nombre(self):
        return self.raza.nombre if self.raza else None

class PerritoColor(Base):
    __tablename__ = "perrito_colores"
    id_perrito = Column(Integer, ForeignKey("perritos.id"), primary_key=True)
    id_color = Column(Integer, ForeignKey("colores.id"), primary_key=True)
    es_principal = Column(Boolean, default=False, nullable=False)

    perrito = relationship("Perrito", back_populates="perrito_colores")
    color = relationship("Color")