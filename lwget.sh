#!/bin/bash

if [ "$1" = "cleanup" ]; then
   echo "Cleanup: se sterg toate datele..."
   rm -rf date
   echo "Cleanup: Stergere completa!"
   exit 0
fi

URL="$1"
[ -z "$URL" ] && 
   {
   echo "Sintaxa invalida!"
   echo "Apeleaza: $0 <URL> | $0 cleanup"; 
   exit 1; 
   }

mkdir -p date/nivel0
cd date/nivel0

if ! wget "$URL"; then
   echo "URL invalid sau inaccesibil"
   exit 1
fi

wget -O index.html "$URL"
