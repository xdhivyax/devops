# Use the official Ubuntu image as a base
FROM ubuntu:20.04

# Install Apache
RUN apt-get update && apt-get install -y apache2

# Set the ServerName directive globally to suppress the warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copy the application files to the Apache document root
COPY . /var/www/html/

# Expose port 80
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]
