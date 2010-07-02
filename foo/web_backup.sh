#!/bin/sh

# Autor: Francisco Puga <fran.puga (at) gmail.com>
# Licencia: Dominio Público

# Crea una copia de seguridad en local de los ficheros que
# haya en un servidor remoto y la base de datos indicada


############################
# PARÁMETROS CONFIGURABLES #
############################

# Dirección del servidor de bases de datos
SERVER_DB="SERVIDOR_DB"

# Nombre de la base de datos
NAME_DB="NOMBRE_DB"

# Usuario de la base de datos
USER_DB="USUARIO_DB"

# Clave de la base de datos
# + Déjala en blanco si quieres que te la pregunte
CLAVE_BD=""

# Dirección del servidor de hosting
SERVER="SERVIDOR"

# Nombre de usuario en el servidor de hosting
USER="USUARIO"

# ruta relativa desde el $HOME remoto al directorio que contiene la web
# + usualmente es igual al nombre del blog. Debes terminar el nombre en /
BLOG_DIR="DIRECTORIO/"

# Ruta local al directorio donde se guardará la copia de seguridad
# + este directorio debe existir
BACKUP_DIR="${HOME}/DIRECTORIO_DE_BACKUP"

##########
# SCRIPT #
##########

# ruta al archivo de dump de la bd. No es necesario que toques esta
# variable a no ser que por algún motivo no quieras usar la raiz del blog
DUMP_DB="${BLOG_DIR}BD.SQL"



ssh $USER@$SERVER "mysqldump --opt --user=$USER_DB -p $CLAVE_BD --host=$SERVER_DB $NAME_DB > $DUMP_DB"
rsync -av $USER@$SERVER:$BLOG_DIR $BACKUP_DIR
ssh $USER@$SERVER "rm $DUMP_DB"
