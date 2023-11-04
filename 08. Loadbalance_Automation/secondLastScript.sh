#!/bin/bash

################
#Author: Paul Akinsande
#Date: 03/11/2023
#Purpose: Script to Install and  configure Nginx
################


# Set some Commands
set -x                   # Print each command and its arguments before executing it for debugging purposes
# set -euo pipefail        # Remove this command to avoid unbound variable error. set -u 

# Create a new EC2 instance as a load balancer
aws ec2 run-instances \
    --image-id ami-0fc5d935ebf8bc3bc \
    --count 1 \
    --instance-type t2.micro \
    --key-name latestkeys2  \
    --security-group-ids sg-04d226f65ac34be11 \
    --subnet-id  subnet-01ab2c27034fa72f8 \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=NewNginx}]"

# Edit New Inbound Rule with Port 80
#aws ec2 authorize-security-group-ingress --group-id sg-04d226f65ac34be11 --protocol tcp --port 80 --cidr 0.0.0.0/0 
#not needed has security-group is already configured.

# Get the newNginx Server IP address.
ip=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=NewNginx" "Name=instance-state-name,Values=running" \
        --query "Reservations[*].Instances[*].PublicIpAddress" \
        --output text)

#ip=($(aws ec2 describe-instances --filters "Name=tag:Name,Values=NewNginx" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].PublicIpAddress" --output text))
#ip=($(aws ec2 describe-instances --filters "Name=tag:Name,Values=NewNginx" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].PublicIpAddress" --output text))

ip1=($(aws ec2 describe-instances --filters "Name=tag:Name,Values=WebServer1" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].PublicIpAddress" --output text))
ip2=($(aws ec2 describe-instances --filters "Name=tag:Name,Values=WebServer2" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].PublicIpAddress" --output text))
# Connect to the newNginx Server via SSH

ssh -i C:/Users/user/Documents/Paul/DevOps_Project/latestkeys2.pem -o StrictHostKeyChecking=no ubuntu@$ip << EOF
    
    # Update and Install Nginx
    sudo apt update -y && sudo apt install nginx -y
    sudo systemctl status nginx

    # Backup the original default configuration file
    sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak

    # Create a new default configuration file
    sudo tee /etc/nginx/sites-available/default <<EOF2
    # Default Server configuration 
    upstream myapps { 
    # Load balancing method 
    least_conn; 
    
    # Web servers 
    server $ip1:8000;   # Public IP of WebServer1 with port 
    server $ip2:8000;  # Public IP of WebServer2 with port 
    
    } 
    
    server { 
        # Listen on port 80 
        listen 80 default_server;                 # nginx listens on port 80 
        listen [::]:80 default_server; 
    
        server_name $ip; 
    
        location / { 
          # Pass requests to the upstream group 
          proxy_pass http://myapps;   # http has been declared above to avoid error 
          try_files $uri $uri/ =404; 
        } 
    }
EOF2
    
    # Test the new configuration
    sudo nginx -t 

    # Restart Nginx
    sudo systemctl restart nginx

    # Print a success message
    echo "Operation complete and Nginx restarted"
EOF





























