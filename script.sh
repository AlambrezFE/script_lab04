
# Clonar los repositorios
echo "Clonando repositorios de GitHub..."
git clone https://github.com/AlambrezFE/python-api.git
git clone https://github.com/AlambrezFE/dotnet-api.git



echo "Creando el archivo docker-compose.yml..."
cat <<EOF >docker-compose.yml
version: '3.8'

services:
  python-api:
    build:
      context: ./python-api
      dockerfile: Dockerfile  
    container_name: python-api
    ports:
      - "5000:5000"
    networks:
      - app-network

  dotnet-api:
    build:
      context: ./dotnet-api
      dockerfile: Dockerfile
    container_name: dotnet-api
    depends_on:
      - python-api
    ports:
      - "5270:8080"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

EOF

echo "Construyendo y ejecutando los contenedores con Docker Compose..."
docker-compose up --build -d

