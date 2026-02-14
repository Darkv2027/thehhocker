FROM php:8.2-apache

# Instalar dependências básicas de sistema para o PHP funcionar
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    zip \
    unzip \
    curl

# Instalar extensões do PHP necessárias [cite: 1]
RUN docker-php-ext-configure intl && \
    docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl

# Ativar mod_rewrite do Apache [cite: 1]
RUN a2enmod rewrite

# Configurar o DocumentRoot para a pasta public [cite: 1]
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Copiar TODO o projeto (incluindo vendor e node_modules que você subiu) [cite: 3]
WORKDIR /var/www/html
COPY . .

# Ajustar permissões (crucial para evitar Erro 500) [cite: 5]
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Script de inicialização limpo
RUN echo '#!/bin/sh\n\
php artisan storage:link --force\n\
php artisan view:clear\n\
php artisan config:clear\n\
php artisan route:clear\n\
apache2-foreground' > /usr/local/bin/start-app.sh

RUN chmod +x /usr/local/bin/start-app.sh

EXPOSE 80

CMD ["/usr/local/bin/start-app.sh"]