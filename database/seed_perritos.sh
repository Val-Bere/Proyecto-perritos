#!/bin/bash
# Carga 15 perritos de prueba llamando a la API (asi las fotos se validan y guardan bien)
API="http://localhost:8000/perritos/"
shopt -s nullglob
FOTOS=(~/fotos_prueba/*.jpg ~/fotos_prueba/*.jpeg ~/fotos_prueba/*.png)

# nombre|latitud|longitud|color_principal_id|colores_adicionales|id_raza
while IFS='|' read -r nombre lat lng color adicionales raza; do
  i=$((i+1))
  foto="${FOTOS[$(( (i-1) % ${#FOTOS[@]} ))]}"
  codigo=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$API" \
    -F "nombre=$nombre" -F "latitud=$lat" -F "longitud=$lng" \
    -F "color_principal_id=$color" -F "colores_adicionales=$adicionales" \
    -F "id_raza=$raza" -F "clave_idempotencia=seed-$(printf '%03d' $i)" \
    -F "foto=@$foto")
  echo "$nombre -> HTTP $codigo"
done <<'EOF'
Firulais|25.4383|-100.9737|1|2|13
Manchas|25.4237|-101.0053|6|2,3|1
Canela|25.4300|-101.0100|3||13
Rex|25.4150|-100.9900|4|5|14
Luna|25.4450|-101.0200|2||15
Toby|25.4100|-101.0000|3|1|13
Nube|25.4350|-100.9800|2|5|19
Max|25.4200|-101.0300|1||16
Bella|25.4500|-100.9950|9|3|13
Coco|25.4050|-101.0150|3|2|21
Pelusa|25.4320|-101.0250|10||13
Thor|25.4180|-100.9850|1|3|17
Kira|25.4420|-101.0080|8|4|18
Bruno|25.4270|-100.9700|3||13
Chispa|25.4090|-100.9950|7|1|20
EOF