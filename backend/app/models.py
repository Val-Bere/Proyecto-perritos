from sqlalchemy import Column, Integer, String, DECIMAL, DateTime, Boolean, ForeignKey
from sqlalchemy.orm import relationship  # Para declarar relaciones entre tablas
from sqlalchemy.sql import func  # Para usar funciones de SQL (como now())
from app.database import Base  # La clase padre de todos los modelos


# Cada clase es una tabla. Cada atributo Column es una columna.
class Raza(Base):
    __tablename__ = "razas"  # Nombre real de la tabla en MySQL
    id = Column(Integer, primary_key=True)  # Llave primaria
    nombre = Column(String(100), unique=True, nullable=False)  # No se repite y no puede ser nulo


class Color(Base):
    __tablename__ = "colores"
    id = Column(Integer, primary_key=True)
    nombre = Column(String(50), unique=True, nullable=False)


class Perrito(Base):
    __tablename__ = "perritos"
    id = Column(Integer, primary_key=True)
    nombre = Column(String(100), nullable=False)
    foto_archivo = Column(String(255), nullable=False)  # Solo guardamos el NOMBRE del archivo, no la imagen
    id_raza = Column(Integer, ForeignKey("razas.id"), nullable=True)  # Llave foránea; opcional
    latitud = Column(DECIMAL(10, 7), nullable=False)  # 10 dígitos en total, 7 decimales
    longitud = Column(DECIMAL(10, 7), nullable=False)
    fecha_registro = Column(DateTime(timezone=True), server_default=func.now())  # La pone MySQL, no el usuario
    # Clave para la idempotencia: UNIQUE impide que existan dos registros con la misma clave
    clave_idempotencia = Column(String(100), unique=True, nullable=False)

    # Relaciones: permiten acceder a los datos relacionados como atributos de Python
    raza = relationship("Raza")
    perrito_colores = relationship("PerritoColor", back_populates="perrito")

    @property
    def colores(self):
        """Propiedad calculada: convierte los registros de la tabla intermedia
        en una lista con la forma que la API devuelve (id, nombre, es_principal)."""
        return [
            {"id": pc.color.id, "nombre": pc.color.nombre, "es_principal": pc.es_principal}
            for pc in self.perrito_colores
        ]

    @property
    def raza_nombre(self):
        """Devuelve el nombre de la raza, o None si el perrito no tiene raza."""
        return self.raza.nombre if self.raza else None


# Tabla intermedia: resuelve la relación muchos-a-muchos entre perritos y colores
class PerritoColor(Base):
    __tablename__ = "perrito_colores"
    # Llave primaria compuesta: la pareja (perrito, color) no se puede repetir
    id_perrito = Column(Integer, ForeignKey("perritos.id"), primary_key=True)
    id_color = Column(Integer, ForeignKey("colores.id"), primary_key=True)
    es_principal = Column(Boolean, default=False, nullable=False)  # True = color principal

    perrito = relationship("Perrito", back_populates="perrito_colores")
    color = relationship("Color")