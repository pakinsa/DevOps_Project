#!/bin/bash

################
#Author: Paul Akinsande
#Date: 03/11/2023
#Purpose: Script to Install and  configure 2 Webservers
################


# Set some Commands
set -x                   # Print each command and its arguments before executing it for debugging purposes
set -euo pipefail        # A shorthand for three commands that make scripts robust set -o nounset, set -o errexit, and set -o pipefail 





# Create 2 new EC2 instances as webservers 1 & 2
aws ec2 run-instances \
    --image-id ami-0fc5d935ebf8bc3bc \
    --count 2 \
    --instance-type t2.micro \
    --key-name latestkeys2  \
    --security-group-ids sg-00a460fc43734343e \
    --subnet-id  subnet-065f8a695884c8a8a \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name1,Value=WebServer1},{Key=Name2,Value=WebServer2}]"




# Edit New Inbound Rule with Port 8000
aws ec2 authorize-security-group-ingress --group-id sg-00a460fc43734343e --protocol tcp --port 8000 --cidr 0.0.0.0/0


ips=($(aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'Reservations[*].Instances[*].PublicIpAddress' --output text))


# Connect via SSH
#for ip in $ip1 $ip2; do
for ip in "${ips[@]}"; do
    ssh -i C:/Users/user/Documents/Paul/DevOps_Project/latestkeys2.pem -o StrictHostKeyChecking=no ubuntu@$ip << EOF
    
    # Update and Install Apache
    sudo apt update -y && sudo apt install apache2 -y
    sudo systemctl status apache2

    
    sudo chmod 777 /var/www/html/
    echo "mode changed successfully"

    
    # Edit configuration files in the 2 servers
    # echo "Listen 8000" >> /etc/apache2/ports.conf
    sudo sed -i "2s/$/\\nListen 8000/" /etc/apache2/ports.conf
    sudo sed -i "s/<VirtualHost \*:80>/<VirtualHost *:8000>/" /etc/apache2/sites-available/000-default.conf
    sed -i.bak "c\<!DOCTYPE html> \
                    <html> \
                    <head> \
                        <title>My EC2 Instance</title> \
                    </head> \
                    <body> \
                        <h1>Welcome to my EC2 instance</h1> \
                        <p>Public IP: $ip</p> \
                    </body> \
                    </html>" /var/www/html/index.html
    sudo systemctl restart apache2
    echo "operation complete and apache2 restarted"
EOF
done
