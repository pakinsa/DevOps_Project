#!/usr/bin/bash

################
#Author: Paul Akinsande
#Date: 02/11/2023
#Purpose: Script for Nginx Loadbalancer Config

################
# Default Server configuration
upstream myapps {
  # Load balancing method
  least_conn;
  # Web servers
  server 44.204.143.1:8000;   # Public IP of Apache1 server
  server 44.203.12.197:8000;  # Public IP of Apache2 server
}

server {
    # Listen on port 80
    listen 80 default_server;                 # nginx listens on port 80
    listen [::]:80 default_server;
    
    server_name 3.239.244.0;

    location / {
      # Pass requests to the upstream group
      proxy_pass http://myapps;   # http has been declared above to avoid error
      try_files $uri $uri/ =404 
    }
}
