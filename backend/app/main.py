from fastapi import FastAPI, Depends
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

app.include_router(perritos.router)
app.include_router(catalogos.router)

@app.get("/")
def raiz():
    return {"mensaje": "API de perritos funcionando"}

@app.get("/salud-db")
def salud_db(db: Session = Depends(get_db)):
    db.execute(text("SELECT 1"))
    return {"mensaje": "Conexión a la base de datos exitosa"}