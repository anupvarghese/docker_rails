# Steps for setting up Docker (Development environment)

### 1. For development environment, use the below `Dockerfile`

```
# Dockerfile

FROM phusion/passenger-ruby22
MAINTAINER Anoop "anupvarghese@gmail.com"

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Expose Nginx HTTP service
EXPOSE 80

# Start Nginx / Passenger
RUN rm -f /etc/service/nginx/down

# Remove the default site
RUN rm /etc/nginx/sites-enabled/default

# Add the nginx site and config
ADD nginx.conf /etc/nginx/sites-enabled/webapp.conf
ADD rails-env.conf /etc/nginx/main.d/rails-env.conf

# Install bundle of gems
WORKDIR /tmp
ADD Gemfile /tmp/
ADD Gemfile.lock /tmp/
RUN bundle install

# Add the Rails app
ADD . /home/app/webapp
RUN chown -R app:app /home/app/webapp

# Clean up APT and bundler when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
```

### 2. Create `nginx.conf` file as below

```
# webapp.conf

server {
  listen 80;
  server_name localhost;
  root /home/app/webapp/public;
  passenger_enabled on;
  passenger_user app;
  passenger_ruby /usr/bin/ruby2.2;
}
```
### 3. Create `rails-env.conf` as below

```
# rails-env.conf

# Set Nginx config environment based on
# the values set in the .env file

env PASSENGER_APP_ENV;
env RAILS_ENV;
env SECRET_KEY_BASE;
env APP_DB_HOST;
env APP_DB_DATABASE;
env APP_DB_PORT;
env APP_DB_USERNAME;
env APP_DB_PASSWORD;
```
### 4. Copy the above 3 files in rails project

### 5. Make Docker build using below command
`~/demo$ sudo docker build -t DOCKERIMAGE_NAME .`

### 6. Run rake commands as below

#### a. DB Setup

`~/demo$ sudo docker run --rm -e "RAILS_ENV=development" -e "APP_DB_HOST=PUBLIC_IP_OF_DB" -e "APP_DB_DATABASE=DEV_DB" -e "APP_DB_PORT=3306" -e "APP_DB_USERNAME=DB_USERNAME" -e "APP_DB_PASSWORD=DB_PASSWORD" -e "PASSENGER_APP_ENV=development" DOCKERIMAGE_NAME rake db:setup`

#### b. Schema load or migrations

`~/demo$ sudo docker run --rm -e "RAILS_ENV=development" -e "APP_DB_HOST=PUBLIC_IP_OF_DB" -e "APP_DB_DATABASE=DEV_DB" -e "APP_DB_PORT=3306" -e "APP_DB_USERNAME=DB_USERNAME" -e "APP_DB_PASSWORD=DB_PASSWORD" -e "PASSENGER_APP_ENV=development" DOCKERIMAGE_NAME rake db:schema:load`

### 7. Run application

`~/demo$ sudo docker run --rm -e "RAILS_ENV=development" -e "APP_DB_HOST=PUBLIC_IP_OF_DB" -e "APP_DB_DATABASE=DEV_DB" -e "APP_DB_PORT=3306" -e "APP_DB_USERNAME=DB_USERNAME" -e "APP_DB_PASSWORD=DB_PASSWORD" -e "PASSENGER_APP_ENV=development"  -p 80:80 DOCKERIMAGE_NAME`

#### Above steps will show running the app in a docker container. However, keep the MySQL DB outside the container(it is good to keep DB outside because of obvious reasons)

# Steps to install MySQL and its configurations

### 1. Install MySQL

`sudo apt-get install mysql`

### 2. Since MySQL DB is being accessed from a Docker container, it has to be enabled for remote access, but with limited permissions

#### a. Edit bind-address to IP address of the VM

`# vi /etc/my.cnf` and set `bind-address=YOUR-VM-IP`

#### b. Restart MySQL

`$ sudo service mysql restart`

#### c. Create development DB and grant access

`$ mysql -u root -p mysql`
`mysql> CREATE DATABASE DEVELOPMENT_DB;`
`mysql> GRANT ALL ON foo.* TO 'USERNAME' IDENTIFIED BY 'PASSWORD';`

##### Further restriction can be given, but it is up to the user.


# Steps for setting up Docker (Production environment)

### For production environment, use the below `Dockerfile`

```
# Dockerfile

FROM phusion/passenger-ruby22
MAINTAINER Anoop "anupvarghese@gmail.com"

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Expose Nginx HTTP service
EXPOSE 80

# Start Nginx / Passenger
RUN rm -f /etc/service/nginx/down

# Remove the default site
RUN rm /etc/nginx/sites-enabled/default

# Add the nginx site and config
ADD nginx.conf /etc/nginx/sites-enabled/webapp.conf
ADD rails-env.conf /etc/nginx/main.d/rails-env.conf


# Add the Rails app
ADD . /home/app/webapp

WORKDIR /home/app/webapp
RUN chown -R app:app /home/app/webapp
RUN sudo -u app bundle install --deployment
RUN sudo -u app RAILS_ENV=production rake assets:precompile

# Clean up APT and bundler when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

```
### All other steps are same as development but change the environment to production

For e.g. :-

#### DB Setup will be as follows

`~/demo$ sudo docker run --rm -e "RAILS_ENV=production" -e "APP_DB_HOST=PUBLIC_IP_OF_DB" -e "APP_DB_DATABASE=PROD_DB" -e "APP_DB_PORT=3306" -e "APP_DB_USERNAME=DB_USERNAME" -e "APP_DB_PASSWORD=DB_PASSWORD" -e "PASSENGER_APP_ENV=production" DOCKERIMAGE_NAME rake db:setup`
