# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV USER_EMAIL=akuntesimage@gmail.com
ENV USER_NAME=akuntesimage
ENV USER_PASSWORD=666

# Install dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    apache2 \
    curl git unzip zip \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update && apt-get install -y \
    php8.2 php8.2-cli php8.2-mbstring php8.2-bcmath php8.2-curl php8.2-zip php8.2-xml php8.2-tokenizer php8.2-mysql php8.2-gd php8.2-imagick php8.2-opcache php8.2-pgsql \
    mariadb-client \
    nodejs npm \
    && apt-get clean

# Set PHP 8.2 as the default version
RUN update-alternatives --set php /usr/bin/php8.2 && \
    update-alternatives --set phpize /usr/bin/phpize8.2 && \
    update-alternatives --set php-config /usr/bin/php-config8.2

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Pterodactyl Panel
WORKDIR /var/www/html
RUN curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz -o panel.tar.gz \
    && tar -xzvf panel.tar.gz && rm panel.tar.gz

# Copy the .env.example to .env
COPY .env.example .env

# Install Composer dependencies
RUN composer install --no-dev --optimize-autoloader

# Generate the application encryption key
RUN php artisan key:generate --force

# Set up the environment for MySQL (default database)
RUN sed -i "s|DB_CONNECTION=.*|DB_CONNECTION=mysql|" .env && \
    sed -i "s|DB_HOST=.*|DB_HOST=junction.proxy.rlwy.net|" .env && \
    sed -i "s|DB_PORT=.*|DB_PORT=52860|" .env && \
    sed -i "s|DB_DATABASE=.*|DB_DATABASE=railway|" .env && \
    sed -i "s|DB_USERNAME=.*|DB_USERNAME=root|" .env && \
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=EdFepEFOowrxYUCsjoeMaQjjaejwGgWH|" .env

# Install Pterodactyl dependencies and set up the panel
RUN php artisan p:environment:setup --email=${USER_EMAIL} --username=${USER_NAME} --password=${USER_PASSWORD} --force \
    && php artisan migrate --force

# Set Permissions for Apache
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Expose Ports
EXPOSE 80 443

# Start Services
CMD ["sh", "-c", "service apache2 start && tail -f /dev/null"]
