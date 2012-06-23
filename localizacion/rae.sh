#!/bin/sh

# Fuente: 
# http://www.trebol-a.com/2012/06/21/diccionario-rae-y-sinonimos/

if [ -z $1 ];then exit 1; fi
cadena=$(echo $1 | tr [:upper:] [:lower:])
archivoTemp="/tmp/$cadena.rae"
cadena=$(echo "$cadena" | iconv - -f utf-8 -t iso-8859-1)
if [ ! -f "$archivoTemp" ]; then
#urlAntigua="http://buscon.rae.es/draeI/SrvltGUIBusUsual?origen=RAE&LEMA="
url="http://lema.rae.es/drae/srv/search?val="
user_agent="Mozilla/5.0 (Windows; U; MSIE 7.0; Windows NT 6.0; es-ES)"
curl --silent --user-agent "$user_agent" "$url$cadena" | sed 's/<img[^>]*>//gi' | sed -r 's/<\/?(entry|body|html|head)(.*)?>//g' > "$archivoTemp"
fi
if [ -e $(tty) ]; then 
lynx -nolist -dump -force-html -hiddenlinks=ignore -assume-charset=utf-8 "$archivoTemp" 
else
/usr/bin/kdialog --textbox "$archivoTemp" 400 300 --title "RAE: $1"
fi	
