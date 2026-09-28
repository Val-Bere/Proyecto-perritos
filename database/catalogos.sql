USE perritos_db;

-- Completa el catalogo de colores (la DBA dejo 6, la rubrica pide 10)
INSERT IGNORE INTO colores (nombre) VALUES
('Atigrado'), ('Beige'), ('Rojizo'), ('Crema');

-- Quita el espacio final de "Sin raza definida / criollo"
UPDATE razas SET nombre = 'Sin raza definida / criollo' WHERE id = 13;

-- Quita 3 perritos de prueba cuyas fotos no existen en el servidor
DELETE FROM perritos WHERE id IN (3, 5, 6);