#!/bin/bash

# =================================================================
# Script de Configuración Unificado para Social Service
# =================================================================

# --- Colores ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Iniciando configuración de Social Service...${NC}\n"

# Directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

# --- 1. VERIFICAR MYSQL ---
echo -e "${YELLOW}Paso 1: Verificando MySQL...${NC}"

if ! command -v mysql &> /dev/null; then
    echo -e "${YELLOW}MySQL no encontrado. Instalando MariaDB Server...${NC}"
    
    # Actualizar repositorios
    sudo apt-get update
    
    # Instalar MariaDB
    if sudo apt-get install -y mariadb-server mariadb-client; then
        echo -e "${GREEN}✅ MariaDB instalado correctamente.${NC}"
        
        # Asegurar que el servicio esté corriendo
        sudo systemctl start mariadb
        sudo systemctl enable mariadb
    else
        echo -e "${RED}❌ Error instalando MariaDB.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ MySQL/MariaDB ya está instalado.${NC}"
fi

# --- 2. CONFIGURAR BASE DE DATOS ---
echo -e "${YELLOW}Paso 2: Configurando Base de Datos...${NC}"
echo "Se te pedirá la contraseña de 'root' de MySQL."

if sudo mysql -u root < database-setup.sql; then
    echo -e "${GREEN}✅ Base de datos configurada.${NC}"
else
    echo -e "${RED}❌ Error configurando base de datos.${NC}"
    exit 1
fi

# --- 3. INSTALAR DEPENDENCIAS ---
echo -e "${YELLOW}Paso 3: Instalando dependencias...${NC}"
if npm install; then
    echo -e "${GREEN}✅ Dependencias instaladas.${NC}"
else
    echo -e "${RED}❌ Error instalando dependencias.${NC}"
    exit 1
fi

# --- 4. MIGRACIONES ---
echo -e "${YELLOW}Paso 4: Ejecutando migraciones...${NC}"
if npm run migrate:up; then
    echo -e "${GREEN}✅ Migraciones completadas.${NC}"
else
    echo -e "${RED}❌ Error en migraciones.${NC}"
    exit 1
fi

# --- 5. INICIAR SERVIDOR ---
echo -e "${YELLOW}Paso 5: Iniciando servidor...${NC}"
echo -e "${GREEN}🎉 ¡Listo! Iniciando en modo desarrollo...${NC}"
npm run dev
