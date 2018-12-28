#!/bin/bash

if [ $UID -ne 0 ];then
	echo "[!]This script must run as root"
	exit
fi

cat users | while read -r line;do
	user=$(echo $line | awk -F ';' '{ print $1 }')
	pass=$(echo $line | awk -F ';' '{ print $2 }')
	group=$(echo $line | awk -F ';' '{ print $3 }')
	shell=$(echo $line | awk -F ';' '{ print $4 }')
	encryptPassword=$(python -c "import crypt; print crypt.crypt('$pass')") 
	useradd -m -G $group -s $shell --password $encryptPassword $user
done
