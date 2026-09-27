<?php
$host = "localhost";
$dbname = "perritos_calle";
$username = "root";
$password = ""; // Por defecto en XAMPP la contraseña está vacía

try {
    // Creamos la conexión usando PDO
    $conexion = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    
    // Configuramos el manejo de errores para que lance excepciones si algo falla
    $conexion->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

} catch (PDOException $e) {
    // Si hay un error en la conexión, se detiene el script y muestra el mensaje
    die("El error de conexión es: " . $e->getMessage());
}
?>