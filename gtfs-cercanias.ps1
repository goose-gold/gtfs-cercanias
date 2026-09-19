#
# Script generado con Copilot desde el original gtfs-cercanias.sh
#

Write-Output "Descargando datos..."

Invoke-WebRequest -Uri "https://ssl.renfe.com/ftransit/Fichero_CER_FOMENTO/fomento_transit.zip" -OutFile "fomento_transit.zip"
if ($LASTEXITCODE -ne 0) {
    Write-Output "Error al descargar el archivo."
    exit 1
}

Expand-Archive -Path "fomento_transit.zip" -DestinationPath "."
if ($LASTEXITCODE -ne 0) {
    Write-Output "Error al descomprimir el archivo."
    exit 1
}

New-Item -ItemType Directory -Path "tmp" -Force

$nucleos = @{
    10 = "Madrid"
    20 = "Asturias"
    30 = "Sevilla"
    31 = "Cadiz"
    32 = "Malaga"
    40 = "Valencia"
    41 = "Murcia-Alicante"
    45 = "Cartagena"
    46 = "Ferrol"
    47 = "Leon"
    50 = "RodaliesCatalunya"
    60 = "Bilbao"
    61 = "SanSebastian"ip a
    62 = "Cantabria"
    70 = "Zaragoza"
}

$archivos = @("trips", "routes", "stop_times")

function Filtrar {
    param (
        [int]$nucleo,
        [string]$archivo
    )
    Get-Content "$archivo.txt" | Where-Object { $_ -match "^$nucleo" } | Set-Content "tmp/$archivo.txt"
}

Write-Output "Generando los archivos..."

foreach ($key in $nucleos.Keys) {
    foreach ($value in $archivos) {
        Filtrar -nucleo $key -archivo $value
    }
    Add-Content -Path "tmp/routes.txt" -Value "route_id,route_short_name,route_long_name,route_type,route_color,route_text_color" -NoNewline
    Add-Content -Path "tmp/stop_times.txt" -Value "trip_id,arrival_time,departure_time,stop_id,stop_sequence" -NoNewline
    Add-Content -Path "tmp/trips.txt" -Value "route_id,service_id,trip_id,trip_headsign" -NoNewline
    Compress-Archive -Path "tmp/*", "agency.txt", "calendar.txt", "stops.txt" -DestinationPath "$($nucleos[$key]).zip" -Update
}

Remove-Item -Recurse -Force "tmp"
Remove-Item "fomento_transit.zip", "agency.txt", "calendar.txt", "routes.txt", "stops.txt", "stop_times.txt", "trips.txt"

Write-Output "Proceso completado."
