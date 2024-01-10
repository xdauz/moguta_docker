FROM php:7.4-fpm

# Set environment variables for security
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="0" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10"

# Set working directory
WORKDIR /var/www

# Install system dependencies and PHP extensions
# Clean up cache and remove unnecessary packages after installation
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libwebp-dev \
    libz-dev \
    libmemcached-dev \
    memcached \
    libmemcached-tools \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd opcache pdo_mysql mysqli zip exif pcntl \
    && pecl install memcached \
    && docker-php-ext-enable memcached \
    && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# Check system architecture, install IonCube for PHP 7.4, and then clean up
RUN export ARCH=$(uname -m) \
    && if [ "$ARCH" = "x86_64" ]; then \
        export IONCUBE_ARCH="lin_x86-64"; \
       elif [ "$ARCH" = "aarch64" ]; then \
        export IONCUBE_ARCH="lin_aarch64"; \
       else \
        echo "Unsupported architecture"; \
        exit 1; \
       fi \
    && set -ex \
    && curl -o ioncube.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_${IONCUBE_ARCH}.tar.gz \
    && tar -xzvf ioncube.tar.gz \
    && mv ioncube/ioncube_loader_lin_7.4.so $(php-config --extension-dir) \
    && echo "zend_extension=$(php-config --extension-dir)/ioncube_loader_lin_7.4.so" > $PHP_INI_DIR/conf.d/00-ioncube.ini \
    && rm -rf ioncube ioncube.tar.gz

# Disable default server token for PHP
RUN echo "expose_php = off" > $PHP_INI_DIR/conf.d/99-expose_php.ini

# Use an unprivileged user
RUN useradd -m moguta
USER moguta

# Copy local content to the container
COPY --chown=moguta:moguta . .

EXPOSE 9000

CMD ["php-fpm"]