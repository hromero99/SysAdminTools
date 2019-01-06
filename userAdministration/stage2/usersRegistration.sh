#!/bin/bash

filename=$1 

if [ -f usersError.log ];then
	rm usersError.log
fi

if [ $UID -ne 0 ];then
	echo "[!]This script must run as root"
	exit
fi

if [ -z "$filename" ]  || [ ! -f $filename ];then

	echo "[!]Usage: usersRegistration.sh filename"
	exit
fi

cat $filename | while read -r line;do
	user=$(echo $line | awk -F ';' '{ print $1 }')
	pass=$(echo $line | awk -F ';' '{ print $2 }')
	group=$(echo $line | awk -F ';' '{ print $3 }')
	shell=$(echo $line | awk -F ';' '{ print $4 }')
	encryptPassword=$(python -c "import crypt; print crypt.crypt('$pass')") 
	if grep -q "^${user}:" /etc/passwd ;then
		echo $line >> usersError.log
	else
		#useradd -m -G $group -s $shell --password $encryptPassword $user
		echo $user
	fi
done
