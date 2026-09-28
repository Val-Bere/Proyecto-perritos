import os  # Para leer variables de entorno (los datos del archivo .env)
from urllib.parse import quote_plus  # Convierte caracteres especiales (como @) a un formato seguro para URLs
from dotenv import load_dotenv  # Carga el contenido del archivo .env a las variables de entorno
from sqlalchemy import create_engine  # Crea la "conexión" principal con la base de datos
from sqlalchemy.orm import sessionmaker, declarative_base  # Herramientas del ORM de SQLAlchemy

# Lee el archivo .env para que os.getenv() pueda encontrar los valores
load_dotenv()

# Datos de conexión: NUNCA van escritos en el código, siempre vienen del .env
DB_USER = os.getenv("DB_USER")
# quote_plus codifica la contraseña: si tiene "@", sin esto Python confundiría
# la arroba de la contraseña con la arroba que separa usuario:contraseña@servidor
DB_PASSWORD = quote_plus(os.getenv("DB_PASSWORD"))
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")

# Cadena de conexión: motor+driver://usuario:contraseña@servidor:puerto/base_de_datos
DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# El "engine" es el objeto que sabe cómo hablar con MySQL
engine = create_engine(DATABASE_URL)

# SessionLocal fabrica sesiones (una sesión = una conversación con la base de datos)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base es la clase padre de todos los modelos (las tablas convertidas en clases)
Base = declarative_base()


def get_db():
    """Abre una sesión por cada petición y garantiza que se cierre al terminar."""
    db = SessionLocal()  # Abre la sesión
    try:
        yield db  # La "presta" al endpoint que la pidió
    finally:
        db.close()  # Se cierra siempre, incluso si hubo un error