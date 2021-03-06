#!/bin/bash

# Autor: Francisco Puga <fran.puga (at) gmail.com>
# Licencia: Dominio Público

# Crea una copia de seguridad en local de los ficheros que
# haya en un servidor remoto y la base de datos indicada

# Debe acompañarse de un fichero con una serie de variables preestablecidas que contienen los dados de conexion
# Uso sh web_backup.sh ruta_al_fichero_de_conexion

if ! [ -r "$1" ] ; then
    echo "Provide a file with the connection params"
    exit
fi

if [ `basename "$1"` = "$1" ] ; then
    conectionFile=`echo './'$1`
else
    conectionFile=`echo "$1"`
fi

. "$conectionFile"

# ruta al archivo de dump de la bd. No es necesario que toques esta
# variable a no ser que por algún motivo no quieras usar la raiz del blog
DUMP_DB="${BLOG_DIR}_BD.SQL"

# echo "ssh ${USER_SSH}@${SERVER} mysqldump --opt --user=$USER_DB -p$CLAVE_BD --host=$SERVER_DB $NAME_DB > $DUMP_DB"
ssh ${USER_SSH}@${SERVER} "mysqldump --opt --user=$USER_DB -p$CLAVE_BD --host=$SERVER_DB $NAME_DB > $DUMP_DB"
echo "Step 1/3 done. db dumped"
rsync -av --delete  ${USER_SSH}@${SERVER}:$BLOG_DIR $BACKUP_DIR
echo "Step 2/3 done. rsync done."
ssh ${USER_SSH}@${SERVER} "rm $DUMP_DB"
echo "Step 3/3 done. db dump deleted from server"