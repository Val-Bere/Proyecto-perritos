from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.database import get_db

app = FastAPI(title="Registro de perritos de la calle")

@app.get("/")
def raiz():
    return {"mensaje": "API de perritos funcionando"}

@app.get("/salud-db")
def salud_db(db: Session = Depends(get_db)):
    db.execute(text("SELECT 1"))
    return {"mensaje": "Conexión a la base de datos exitosa"}