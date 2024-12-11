# Base Image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV USER_EMAIL=akuntesimage@gmail.com
ENV USER_NAME=akuntesimage
ENV USER_PASSWORD=666

# Database Connection Strings
ENV MYSQL_URL=mysql://root:EdFepEFOowrxYUCsjoeMaQjjaejwGgWH@junction.proxy.rlwy.net:52860/railway
ENV POSTGRESQL_URL=postgresql://postgres:lxavbaOIDxAAcAxucXiHmzxwXEhlKGoN@autorack.proxy.rlwy.net:11912/railway

# Install dependencies
RUN apt-get update && apt-get install -y \
    apache2 \
    php php-cli php-mbstring php-bcmath php-curl php-zip php-xml php-tokenizer php-mysql php-gd php-imagick php-opcache php-pgsql \
    mariadb-client \
    curl git unzip zip \
    docker.io \
    nodejs npm \
    && apt-get clean

# Enable Apache mod_rewrite
RUN a2enmod rewrite && service apache2 restart

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Pterodactyl Panel
WORKDIR /var/www/html
RUN curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz -o panel.tar.gz \
    && tar -xzvf panel.tar.gz && rm panel.tar.gz

# Set up the environment for MySQL (default database)
COPY .env.example .env
RUN sed -i "s|DB_CONNECTION=.*|DB_CONNECTION=mysql|" .env && \
    sed -i "s|DB_HOST=.*|DB_HOST=junction.proxy.rlwy.net|" .env && \
    sed -i "s|DB_PORT=.*|DB_PORT=52860|" .env && \
    sed -i "s|DB_DATABASE=.*|DB_DATABASE=railway|" .env && \
    sed -i "s|DB_USERNAME=.*|DB_USERNAME=root|" .env && \
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=EdFepEFOowrxYUCsjoeMaQjjaejwGgWH|" .env

# Install Pterodactyl dependencies and set up the panel
RUN composer install --no-dev --optimize-autoloader \
    && php artisan key:generate \
    && php artisan p:environment:setup --email=${USER_EMAIL} --username=${USER_NAME} --password=${USER_PASSWORD} --force \
    && php artisan migrate --force

# Optionally Set Up PostgreSQL (uncomment if needed)
# RUN sed -i "s|DB_CONNECTION=.*|DB_CONNECTION=pgsql|" .env && \
#     sed -i "s|DB_HOST=.*|DB_HOST=autorack.proxy.rlwy.net|" .env && \
#     sed -i "s|DB_PORT=.*|DB_PORT=11912|" .env && \
#     sed -i "s|DB_DATABASE=.*|DB_DATABASE=railway|" .env && \
#     sed -i "s|DB_USERNAME=.*|DB_USERNAME=postgres|" .env && \
#     sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=lxavbaOIDxAAcAxucXiHmzxwXEhlKGoN|" .env && \
#     php artisan migrate --force

# Set Permissions for Apache
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Expose Ports
EXPOSE 80 443

# Start Services
CMD ["sh", "-c", "service apache2 start && tail -f /dev/null"]
