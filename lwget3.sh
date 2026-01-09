	#!/bin/bash

	if [ "$1" = "cleanup" ]; then
	   echo "CLEANUP: se sterg toate datele..."
	   rm -rf date
	   echo "CLEANUP: Stergere completa!"
	   exit 0
	fi

	URL="$1"

	[ -z "$URL" ] && 
	   {
	   echo "Sintaxa invalida!"
	   echo "Apeleaza: $0 <URL> | $0 cleanup"; 
	   exit 1; 
	   }
	  
	case "$URL" in 
	   http://*|https://*) : ;;
	   *) URL="https://$URL" ;;
	esac 

	mkdir -p date/nivel0
	cd date
	
	LINKS="links1.txt"
	START="start_url.txt"
	NIVEL="NIVEL.txt"
	DOMENIU="$URL"
	DIR="$URL/"
	START_URL=""
	
	if [ ! -f "$NIVEL" ]; then
	   echo 0 > "$NIVEL"
	fi	
	
	
	[ -z "$x" ] && x="$(cat "$NIVEL")"
	
	if [ ! -f fisier.html ]; then
		if ! wget -q -O nivel0/fisier.html "$URL"; then
		   echo "URL invalid sau inaccesibil"
		   exit 1
		else
		   echo "NIVEL$x($URL): Au fost instalate fisierele!"
		   touch "links0.txt"
		   echo "$URL" > links0.txt
		fi
	fi
	

	if [ ! -f "$START" ]; then
	   echo "$URL" > "$START"
	fi

	[ -f "$START" ] && START_URL="$(cat "$START")"

	if [ "$URL" != "$START_URL" ] && [ -n "$START_URL" ] ; then
	   echo "Error: Proiectul este pentru $START_URL."
	   echo "Tu ai apelat pentru $URL."
	   echo "Apeleaza $0 cleanup pentru a incepe alt site."
	   exit 1
	else
	
	LINKS="links$x.txt"
	if [ "$x" -ne 0 ]; then
	   mkdir "nivel$x"
	fi
	((x++))    
	echo "$x" > "$NIVEL"
	LINKS2="links$x.txt"	
	if [ "$x" -ne 1 ]; then
	i=0
	while IFS= read -r link; do
	DOMENIU=$(echo "$link" | cut -d'/' -f1-3)
	if [[ "$link" == */*/* ]]; then
  	DIR="${link%/*}/"
	else
  	DIR="$DOMENIU/"
	fi
	echo "$DOMENIU $DIR"
	  ((i++))
	  out="nivel$((x-1))/fisier$i.html"
	  wget -q -O "$out" "$link"
	[[ -z "$link" ]] && continue
	done < "$LINKS"   
	fi
	for file in nivel$((x-1))/*; do
		grep 'href="' $file | cut -d'"' -f2 \
		| grep -v '^#' \
		| grep -v '^javascript:' \
		| grep -v '^mailto:' \
		| grep -v '^tel:' \
		| grep -v '\.css$' \
		| grep -v '\.js$' \
		| grep -E '/|^https?://' \
		| sort -u \
		>> "$LINKS2"
	done
	TEMP=$(mktemp)

	while IFS= read -r link; do
	   link="${link%%#*}"
	   [[ -z "$link" ]] && continue
	   if [[ "$link" == http://* || "$link" == https://* ]]; then
	      echo "$link" 
	   elif [[ "$link" == /* ]]; then
	      echo "$DOMENIU$link"
	   else
	      echo "$DIR$link"
	   fi  
	done < "$LINKS2" | sort -u > "$TEMP"
	mv "$TEMP" "$LINKS2"
	fi

	
