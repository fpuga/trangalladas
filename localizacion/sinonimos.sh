#!/bin/sh

# Fuente: 
# http://www.trebol-a.com/2012/06/21/diccionario-rae-y-sinonimos/

if [ -z $1 ];then exit 1; fi
cadena=$(echo $1 | tr [:upper:] [:lower:])
archivoTemp="/tmp/$cadena.sinonimos"
if [ ! -f "$archivoTemp" ]; then
url="http://www.wordreference.com/sinonimos/"
user_agent="Mozilla/5.0 (Windows; U; MSIE 7.0; Windows NT 6.0; es-ES)"
curl --silent --user-agent "$user_agent" "$url$cadena" | sed -n -e 's/.*\(<h3>[^<]*<\/h3><ul>.*<\/ul>\).*/\1/p' >"$archivoTemp"
fi
if [ -e $(tty) ]; then 
lynx -nolist -dump -force-html -hiddenlinks=ignore -assume-charset=utf-8 "$archivoTemp" 
else
/usr/bin/kdialog --textbox "$archivoTemp" 400 300 --title "RAE: $1"
fi

 
