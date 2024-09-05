#!/bin/sh


# Nombres de las imágenes locales
IMAGEN_DOTNET="script_lab04-dotnet-api"
IMAGEN_PYTHON="script_lab04-python-api"

# URL del servicio a monitorear (actualiza según corresponda)
URL="http://107.23.158.93:8000"

# Función para obtener el ID del contenedor a partir de la imagen
get_service_container_by_image() {
  docker ps -f ancestor=$1 --format "{{.ID}}"
}

# Función para monitorear contenedores
func_contenedores() {
  echo "minoterando $IMAGEN_DOTNET y $IMAGEN_PYTHON"
  
  CONTAINERS_DOTNET=$(get_service_container_by_image $IMAGEN_DOTNET)
  CONTAINERS_PYTHON=$(get_service_container_by_image $IMAGEN_PYTHON)

  if [ -z "$CONTAINERS_DOTNET" ]; then
    echo "No se encontraron contenedores (no hay $IMAGEN_DOTNET.)"
  else
    echo "Estado del contenedor basado en la imagen $IMAGEN_DOTNET:"
    docker stats --no-stream $CONTAINERS_DOTNET
  fi

  if [ -z "$CONTAINERS_PYTHON" ]; then
    echo "No se encontraron contenedores (no hay $IMAGEN_PYTHON.)"
  else
    echo "Estado del contenedor basado en la imagen $IMAGEN_PYTHON:"
    docker stats --no-stream $CONTAINERS_PYTHON
  fi
}

# HOST
func_host() {
  echo "Monitoreando el host:"
  cpu_usage=$(mpstat 1 1 | awk '/Average/ {print 100 - $12}')
  echo "Uso de CPU: ${cpu_usage}%"
  echo "Uso de memoria:"
  free -m | awk 'NR==2{printf "Memoria: %.2f%%\n", $3*100/$2 }'
}

# Función para monitorear el estado del servicio
fetch_servicio() {
  echo "Monitoreando servicio EC2 en $URL //"
  response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" --output /dev/null "$URL")
  http_code=$(echo "$response" | sed -e 's/.*HTTPSTATUS://')
  if [ "$http_code" -eq 200 ]; then
    echo "El servicio está en linea, aun...."
  else
    echo "El servicio no está en línea. estado HTTP: $http_code"
  fi
}

# Bucle de monitoreo
while true; do
  echo "////////////-------------Moni-moni------------////////////"
  func_contenedores
  func_host
  func_servicio
  echo "fecha: $(date)"
  echo "////////////-------------Moni-moni------------////////////"
  
  sleep 7
done
