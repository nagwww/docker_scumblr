# Docker for Scumblr
# Author : Nag
FROM ubuntu:14.04
MAINTAINER Nag <nagwww@gmail.com>


#For postgres installations
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 &&\
    echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list &&\
    apt-get update -y &&\
    apt-get -y -q install python-software-properties software-properties-common wget &&\
    apt-get install -y python-pip python-dev python-psycopg2 libpq-dev nginx supervisor git curl &&\
    apt-get -y install git libxslt-dev libxml2-dev build-essential bison openssl zlib1g libxslt1.1 libssl-dev libxslt1-dev libxml2 libffi-dev libxslt-dev autoconf libc6-dev libreadline6-dev zlib1g-dev libtool libsqlite3-dev libcurl3 libmagickcore-dev ruby-build libmagickwand-dev imagemagick bundler redis-server


ADD scumblr.sh /home/ubuntu/
# Expose the PostgreSQL port
EXPOSE 443


#Install Ruby
RUN git clone git://github.com/sstephenson/rbenv.git .rbenv &&\
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc &&\
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc &&\
    exec $SHELL &&\
    git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build &&\
    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc &&\
    exec $SHELL &&\
    rbenv install 2.0.0-p481 &&\
    rbenv global 2.0.0-p481 &&\
    ruby -v



USER root
RUN useradd -d /home/ubuntu -m -s /bin/bash ubuntu &&\
    gem install bundler --no-ri --no-rdoc &&\
    rbenv rehash &&\
    gem install rails -v 4.0.9 &&\
    gem install sidekiq &&\
    rbenv rehash 


RUN git clone https://github.com/Netflix/scumblr.git /home/ubuntu/scumblr &&\
    chown -R ubuntu:ubuntu -R /home/ubuntu/scumblr &&\
    cd /home/ubuntu/scumblr && bundle install &&\
    rake db:create &&\
    rake db:schema:load
##    su ubuntu -c "python /home/ubuntu/sketchy/manage.py create_db" &&\
#    chmod 755 /home/ubuntu/sketchy.sh &&\
#    service redis-server stop

RUN chmod 755 /home/ubuntu/scumblr.sh
#USER ubuntu
#    python /home/ubuntu/sketchy/manage.py create_db

#USER root
#ADD supervisord.ini /sketchy/supervisor/

#ADD sketchy.conf /etc/nginx/sites-available/
CMD /home/ubuntu/scumblr.sh

