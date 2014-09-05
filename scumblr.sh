#!/bin/bash

# For Scumblr 1.0

email=$mail
host_name=$host

if [ "${use_ssl}" == "" ]; then
  echo "Email is not passed. Please set it as dockerrun -e mail=test@example.com"
  use_ssl=True
fi

if [ "${host}" == "" ]; then
  echo "Host or EC2 name is not passed. Please set it as dockerrun -e host=test@ec2-XX-XXX-XXX-XXX.compute-1.amazonaws.com"
  host="ec2-XX-XXX-XXX-XXX.compute-1.amazonaws.com"
fi


openssl genrsa -des3 -passout pass:yourpassword -out server.key 2048
openssl rsa -in server.key -out server.key.insecure -passin pass:yourpassword
mv server.key server.key.secure
mv server.key.insecure server.key

openssl req -new -key server.key -out server.csr -subj "/C=US/ST=CA/L=Los Gatos/O=Global Security/OU=IT OPS/CN=Sketchy.com"
openssl x509 -req -days 365  -in server.csr -signkey server.key -out server.crt

cp server.crt /etc/ssl/certs
cp server.key /etc/ssl/private

mkdir -p /var/log/nginx/log
touch /var/log/nginx/log/access.log
touch /var/log/nginx/log/error.log
ln -s /etc/nginx/sites-available/sketchy.conf /etc/nginx/sites-enabled/sketchy.conf
rm /etc/nginx/sites-enabled/default

echo "Starting nginx"
#service nginx restart
nginx

#echo "Starting Redis"
#redis-server &

#echo "Starting Celery"
#cd /sketchy
#celery -A sketchy.celery worker &

#echo "Run the Flask App"
#python manage.py runserver --host 0.0.0.0 --port 8008

echo "Update the database"
chown -R ubuntu:ubuntu /home/ubuntu/
chmod -R 755 /home/ubuntu/

#cd /sketchy/supervisor

#touch /sketchy/sketchy-deploy.log
#chmod 777 /sketchy/sketchy-deploy.log
#supervisord -c supervisord.ini

echo "Completed ... "
/bin/bash
