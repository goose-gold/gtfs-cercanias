#!/bin/bash

echo "Descargando datos..."

wget -q https://ssl.renfe.com/ftransit/Fichero_CER_FOMENTO/fomento_transit.zip -O fomento_transit.zip
if [ $? -ne 0 ]; then
    echo "Error al descargar el archivo."
    exit 1
fi

unzip -q fomento_transit.zip -d .
if [ $? -ne 0 ]; then
    echo "Error al descomprimir el archivo."
    exit 1
fi

mkdir -p tmp

declare -A nucleos
nucleos[10]="Madrid"
nucleos[20]="Asturias"
nucleos[30]="Sevilla"
nucleos[31]="Cadiz"
nucleos[32]="Malaga"
nucleos[40]="Valencia"
nucleos[41]="Murcia-Alicante"
nucleos[45]="Cartagena"
nucleos[46]="Ferrol"
nucleos[47]="Leon"
nucleos[50]="RodaliesCatalunya"
nucleos[60]="Bilbao"
nucleos[61]="SanSebastian"
nucleos[62]="Cantabria"
nucleos[70]="Zaragoza"

archivos=( trips routes stop_times )

filtrar() {
    local nucleo="$1"
    local archivo="$2"
    awk -F, "\$1 ~ /^$nucleo/" "$archivo.txt" > "tmp/$archivo.txt"
}

echo "Generando los archivos..."

for key in "${!nucleos[@]}"; do
    for value in "${archivos[@]}"; do
        filtrar $key $value
    done
    sed -i '1i\route_id,route_short_name,route_long_name,route_type,route_color,route_text_color' tmp/routes.txt
    sed -i '1i\trip_id,arrival_time,departure_time,stop_id,stop_sequence' tmp/stop_times.txt
    sed -i '1i\route_id,service_id,trip_id,trip_headsign' tmp/trips.txt
    zip -ujqq "${nucleos[$key]}.zip" tmp/* agency.txt calendar.txt stops.txt
done

rm -rf tmp
rm fomento_transit.zip agency.txt calendar.txt routes.txt stops.txt stop_times.txt trips.txt

echo "Proceso completado."
