# Use official Nginx Alpine image (lightweight)
FROM nginx:alpine

# Copy our static files to Nginx's default HTML directory
COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Nginx will start automatically
CMD ["nginx", "-g", "daemon off;"]