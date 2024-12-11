# Base Image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV USER_EMAIL=akuntesimage@gmail.com
ENV USER_NAME=akuntesimage
ENV USER_PASSWORD=666

# Install Dependencies
RUN apt-get update && apt-get install -y \
    apache2 \
    php php-cli php-mbstring php-bcmath php-curl php-zip php-xml php-tokenizer php-mysql php-gd php-imagick php-opcache \
    mariadb-client \
    curl git unzip zip \
    docker.io \
    nodejs npm \
    && apt-get clean

# Set up Apache for Pterodactyl Panel
RUN a2enmod rewrite
RUN service apache2 restart

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Pterodactyl Panel
WORKDIR /var/www/html
RUN curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz -o panel.tar.gz \
    && tar -xzvf panel.tar.gz && rm panel.tar.gz

# Configure Pterodactyl Panel
RUN composer install --no-dev --optimize-autoloader \
    && php artisan key:generate \
    && php artisan p:environment:setup --email=${USER_EMAIL} --username=${USER_NAME} --password=${USER_PASSWORD} --force \
    && php artisan migrate --force

# Set Permissions for Apache
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Install Wings
RUN mkdir -p /wings
WORKDIR /wings
RUN curl -L https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64 -o wings \
    && chmod +x wings

# Expose Ports
EXPOSE 80 443 8080 2022

# Start Services
CMD service apache2 start && ./wings --config /etc/pterodactyl/config.yml
