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

groupManager (){
	#Check if group exists
	groupForAddUsers=$(echo $1 | tr "," "\n")
	for group in $groupForAddUsers; do
		if grep -q "^${group}:" /etc/group; then
			usersInGroup=$(grep "^${group}:" /etc/group | awk -F ':' '{ print $4 }'| tr "," "\n")
			if echo ${usersInGroup[@]} | grep -q -w "$2";then
				echo "User $2 already in group $group" >> usersError.log
			else
				usermod -aG $group $2
		fi
		else
			groupadd $group
			usermod -aG $group $2
		fi
	done
}

cat $filename | while read -r line;do
	user=$(echo $line | awk -F ';' '{ print $1 }')
	pass=$(echo $line | awk -F ';' '{ print $2 }')
	group=$(echo $line | awk -F ';' '{ print $3 }')
	shell=$(echo $line | awk -F ';' '{ print $4 }')
	encryptPassword=$(python -c "import crypt; print crypt.crypt('$pass')") 
	if grep -q "^${user}:" /etc/passwd ;then
		echo $line >> usersError.log
	else
		useradd -m  -s $shell --password $encryptPassword $user
		echo $user
		groupManager $group $user
	fi
done
