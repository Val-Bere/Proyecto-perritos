CREATE TABLE razas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE colores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE perritos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    foto_archivo VARCHAR(255) NOT NULL,
    id_raza INT NULL,
    latitud DECIMAL(10, 7) NOT NULL,
    longitud DECIMAL(10, 7) NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    clave_idempotencia VARCHAR(100) NOT NULL UNIQUE,
    FOREIGN KEY (id_raza) REFERENCES razas(id)
);

CREATE TABLE perrito_colores (
    id_perrito INT NOT NULL,
    id_color INT NOT NULL,
    es_principal BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (id_perrito, id_color),
    FOREIGN KEY (id_perrito) REFERENCES perritos(id),
    FOREIGN KEY (id_color) REFERENCES colores(id)
);

-- No debe faltar esta fila (regla del proyecto)
INSERT INTO razas (nombre) VALUES ('Sin raza definida / criollo');