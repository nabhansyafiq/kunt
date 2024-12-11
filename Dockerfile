# Use the official PHP image as the base
FROM php:8.2-fpm

# Install dependencies and PHP 8.2 packages
RUN apt-get update && apt-get install -y \
    lsb-release ca-certificates apt-transport-https \
    && curl -fsSL https://packages.sury.org/php/README.txt | bash - \
    && apt-get update

# Install PHP 8.2 and necessary extensions
RUN apt-get install -y \
    php8.2 php8.2-cli php8.2-mbstring php8.2-bcmath php8.2-curl php8.2-zip php8.2-xml php8.2-tokenizer php8.2-mysql php8.2-gd php8.2-imagick php8.2-opcache php8.2-pgsql \
    php8.2-dev mariadb-client nodejs npm \
    && apt-get clean

# Set PHP 8.2 as default
RUN update-alternatives --set php /usr/bin/php8.2 && \
    update-alternatives --set phpize /usr/bin/phpize8.2 && \
    update-alternatives --set php-config /usr/bin/php-config8.2

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/html

# Copy application files into the container
COPY . .

# Install Composer dependencies
RUN composer install --no-dev --optimize-autoloader

# Generate the application encryption key
RUN php artisan key:generate --force

# Set up the environment for MySQL
RUN php artisan p:environment:setup --email=${USER_EMAIL} --username=${USER_NAME} --password=${USER_PASSWORD} --force

# Run migrations
RUN php artisan migrate --force

# Expose the necessary port
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]
