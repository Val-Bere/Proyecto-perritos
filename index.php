<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🐾 Registro de Perritos de la Calle</title>
    <!-- Google Fonts: Plus Jakarta Sans -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <!-- Leaflet CSS para el Mapa -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    
    <style>
        :root {
            --primary: #7c3aed; /* Morado vibrante hermoso */
            --primary-hover: #6d28d9;
            --primary-light: #f5f3ff;
            --accent: #a78bfa; /* Lila suave */
            --bg-color: #faf5ff; /* Fondo general con toque lila muy sutil */
            --card-bg: #ffffff;
            --text-main: #1f2937;
            --text-muted: #6b7280;
            --border-color: #e9d5ff;
            --radius: 16px;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: var(--bg-color);
            color: var(--text-main);
            min-height: 100vh;
            padding: 30px 15px;
        }

        .container {
            max-width: 850px;
            margin: 0 auto;
        }

        header {
            text-align: center;
            margin-bottom: 35px;
        }

        header h1 {
            color: var(--primary);
            font-size: 2.2rem;
            font-weight: 700;
            margin-bottom: 8px;
        }

        header p {
            color: var(--text-muted);
            font-size: 1rem;
        }

        .card-form {
            background: var(--card-bg);
            padding: 40px;
            border-radius: var(--radius);
            box-shadow: 0 10px 25px -5px rgba(124, 58, 237, 0.08), 0 8px 10px -6px rgba(124, 58, 237, 0.08);
            border: 1px solid var(--border-color);
            margin-bottom: 40px;
        }

        .form-section-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--primary);
            margin-bottom: 20px;
            padding-bottom: 8px;
            border-bottom: 2px solid var(--primary-light);
        }

        .form-group {
            margin-bottom: 22px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            font-size: 0.95rem;
        }

        input[type="text"],
        select {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid var(--border-color);
            border-radius: 10px;
            font-size: 1rem;
            font-family: inherit;
            background-color: #fff;
            transition: all 0.3s ease;
        }

        input[type="text"]:focus,
        select:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 4px var(--primary-light);
        }

        .file-upload-box {
            border: 2px dashed var(--accent);
            padding: 20px;
            text-align: center;
            border-radius: 10px;
            background-color: var(--primary-light);
            cursor: pointer;
            transition: background 0.3s;
        }

        .file-upload-box:hover {
            background-color: #ede9fe;
        }

        input[type="file"] {
            margin-top: 10px;
        }

        /* Contenedor del Mapa */
        #map {
            width: 100%;
            height: 320px;
            border-radius: 12px;
            margin-top: 10px;
            border: 2px solid var(--border-color);
        }

        .map-actions {
            margin-top: 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 0.85rem;
            color: var(--text-muted);
        }

        .btn-ubicacion {
            background: #ede9fe;
            color: var(--primary);
            border: none;
            padding: 8px 14px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s;
        }

        .btn-ubicacion:hover {
            background: #ddd6fe;
        }

        button[type="submit"] {
            background-color: var(--primary);
            color: white;
            border: none;
            padding: 14px 20px;
            font-size: 1.05rem;
            font-weight: 600;
            border-radius: 10px;
            cursor: pointer;
            width: 100%;
            transition: background 0.3s, transform 0.1s;
            box-shadow: 0 4px 12px rgba(124, 58, 237, 0.2);
        }

        button[type="submit"]:hover {
            background-color: var(--primary-hover);
        }

        button[type="submit"]:active {
            transform: scale(0.99);
        }

        /* Galería de perritos registrados */
        .grid-perritos {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 20px;
        }

        .card-perrito {
            background: white;
            border-radius: var(--radius);
            padding: 20px;
            text-align: center;
            box-shadow: 0 4px 15px rgba(0,0,0,0.04);
            border: 1px solid var(--border-color);
            transition: transform 0.3s;
        }

        .card-perrito:hover {
            transform: translateY(-4px);
        }

        .card-perrito img {
            width: 110px;
            height: 110px;
            object-fit: cover;
            border-radius: 50%;
            margin-bottom: 12px;
            border: 4px solid var(--primary-light);
        }

        .card-perrito h3 {
            color: var(--primary);
            margin-bottom: 6px;
            font-size: 1.2rem;
        }

        .card-perrito p {
            font-size: 0.9rem;
            color: var(--text-muted);
            margin-bottom: 4px;
        }

        .badge-color {
            display: inline-block;
            background: var(--primary-light);
            color: var(--primary);
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            margin-top: 6px;
        }
    </style>
</head>
<body>

    <header>
        <h1>🐾 Adopta y Rescata: Perritos de la Calle</h1>
        <p>Sistema oficial de registro y control ciudadano</p>
    </header>

    <div class="container">
        <!-- Formulario Principal -->
        <div class="card-form">
            <form id="formPerrito" action="guardar.php" method="POST" enctype="multipart/form-data">
                <div class="form-section-title">1. Identificación y Fotografía</div>
                
                <div class="form-group">
                    <label for="nombre">Nombre o seña particular:</label>
                    <input type="text" id="nombre" name="nombre" required placeholder="Ej. Lomito café / Manchas">
                </div>

                <div class="form-group">
                    <label for="foto">Fotografía (Cámara o archivo - JPG, PNG, WEBP):</label>
                    <div class="file-upload-box">
                        <input type="file" id="foto" name="foto" accept="image/png, image/jpeg, image/webp" capture="environment" required>
                    </div>
                </div>

                <div class="form-section-title">2. Características Físicas</div>

                <div class="form-group">
                    <label for="raza">Raza:</label>
                    <select id="raza" name="raza" required>
                        <option value="" disabled selected>Selecciona una raza</option>
                        <?php
                        require_once "conexion.php";
                        try {
                            $stmt =$conexion->query("SELECT id, nombre FROM razas ORDER BY nombre ASC");
                            while ($row =$stmt->fetch(PDO::FETCH_ASSOC)) {
                                echo "<option value='" . $row['id'] . "'>" . htmlspecialchars($row['nombre']) . "</option>";
                            }
                        } catch (PDOException $e) {
                            echo "<option value=''>Error al cargar razas</option>";
                        }
                        ?>
                    </select>
                </div>

                <div class="form-group">
                    <label for="colorPrincipal">Color Principal:</label>
                    <select id="colorPrincipal" name="colorPrincipal" required>
                        <option value="" disabled selected>Selecciona un color</option>
                        <option value="Negro">Negro</option>
                        <option value="Blanco">Blanco</option>
                        <option value="Café">Café</option>
                        <option value="Gris">Gris</option>
                        <option value="Canela">Canela / Castaño</option>
                        <option value="Manchado">Manchado / Arlequín</option>
                    </select>
                </div>

                <div class="form-section-title">3. Ubicación del Avistamiento</div>
                <div class="form-group">
                    <label>Mueve el pin en el mapa donde viste al perrito:</label>
                    <div id="map"></div>
                    <div class="map-actions">
                        <span id="coordInfo">Lat: 25.4237, Lng: -101.0053</span>
                        <button type="button" class="btn-ubicacion" id="btnMiUbicacion">📍 Usar mi ubicación actual</button>
                    </div>
                    <!-- Inputs ocultos para enviar la latitud y longitud -->
                    <input type="hidden" id="lat" name="lat" value="25.4237">
                    <input type="hidden" id="lng" name="lng" value="-101.0053">
                </div>

                <button type="submit">Registrar Perrito en el Sistema</button>
            </form>
        </div>

        <!-- Sección de Listado / Tarjetas -->
        <h2 style="color: var(--primary); margin-bottom: 20px; font-size: 1.4rem;">Perritos Registrados Recientemente</h2>
        <div class="grid-perritos" id="gridPerritos">
            <!-- Aquí se cargarán las tarjetas dinámicamente -->
        </div>
    </div>

    <!-- Leaflet JS para inicializar el mapa -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        // Inicializar mapa centrado en Saltillo por defecto
        const map = L.map('map').setView([25.4237, -101.0053], 13);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            attribution: '© OpenStreetMap'
        }).addTo(map);

        let marker = L.marker([25.4237, -101.0053], {draggable: true}).addTo(map);

        function actualizarCoordenadas(lat, lng) {
            document.getElementById('coordInfo').innerText = `Lat: ${lat.toFixed(4)}, Lng: ${lng.toFixed(4)}`;
            document.getElementById('lat').value = lat;
            document.getElementById('lng').value = lng;
        }

        marker.on('dragend', function(event) {
            const position = marker.getLatLng();
            actualizarCoordenadas(position.lat, position.lng);
        });

        document.getElementById('btnMiUbicacion').addEventListener('click', () => {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(position => {
                    const lat = position.coords.latitude;
                    const lng = position.coords.longitude;
                    map.setView([lat, lng], 16);
                    marker.setLatLng([lat, lng]);
                    actualizarCoordenadas(lat, lng);
                }, () => {
                    alert('No se pudo obtener tu ubicación.');
                });
            }
        });
    </script>
</body>
</html>