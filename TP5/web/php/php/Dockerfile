FROM php:apache-bullseye 

RUN apt-get update && apt-get upgrade -y

RUN docker-php-ext-install mysqli

EXPOSE 80
