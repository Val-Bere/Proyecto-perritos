<?php
require_once "conexion.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $nombre = $_POST['nombre'] ?? '';
    $id_raza = $_POST['raza'] ?? null; // Recibe el ID de la raza seleccionada del catálogo
    $color = $_POST['colorPrincipal'] ?? '';
    $lat = $_POST['lat'] ?? '';
    $lng = $_POST['lng'] ?? '';

    // Generamos una clave de idempotencia única para evitar conflictos de duplicados
    $clave_idempotencia = uniqid("perrito_", true);

    // Manejo de la fotografía
    $nombre_foto = "";
    if (isset($_FILES['foto']) && $_FILES['foto']['error'] === UPLOAD_ERR_OK) {
        $nombre_foto = time() . "_" . $_FILES['foto']['name'];
        if (!is_dir('img')) {
            mkdir('img', 0777, true);
        }
        move_uploaded_file($_FILES['foto']['tmp_name'], "img/" . $nombre_foto);
    }

    try {
        // Insertamos el registro en la tabla 'perritos'
        $sql = "INSERT INTO perritos (nombre, foto_archivo, id_raza, latitud, longitud, clave_idempotencia) 
                VALUES (:nombre, :foto, :id_raza, :lat, :lng, :clave)";
        
        $stmt = $conexion->prepare($sql);
        $stmt->execute([
            ':nombre' => $nombre,
            ':foto' => $nombre_foto,
            ':id_raza' => $id_raza,
            ':lat' => $lat,
            ':lng' => $lng,
            ':clave' => $clave_idempotencia
        ]);

        echo "<h2 style='font-family:sans-serif; text-align:center; margin-top:50px; color:#7c3aed;'>¡Perrito registrado con éxito en la base de datos!</h2>";
        echo "<br><div style='text-align:center;'><a href='index.php' style='background:#7c3aed; color:white; padding:10px 20px; text-decoration:none; border-radius:8px;'>Regresar al formulario</a></div>";

    } catch (PDOException $e) {
        echo "Error al guardar: " . $e->getMessage();
    }
}
?>