#!/bin/bash"
if [ ! -x "$(command -v docker)" ] || [ ! -x "$(command -v git)" ]; then
    echo "[!] docker and git must be installed for this script"
    exit
fi
# Clone sample-django-app repo

git clone https://github.com/hromero99/django-simple-app.git django-sample-app

# Build docker images 

docker build -t django-app --file $(pwd)/django-sample-app/Dockerfile $(pwd)/django-sample-app

#Start containers from port 8000 to 8003 to generate 3 replicas

for counter in 0 1 2 ; do
	echo "[!] Starting container replica in port 800$counter"
	docker run -p "800$counter":8000 --name replica_$counter -d django-app
done
