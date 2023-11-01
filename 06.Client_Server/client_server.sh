#! /usr/bin/bash

################
#Author: Paul Akinsande
#Date: 31/10/2023
#Purpose: Client_Server Scripting
# Objective: To Implement Client-Server Architecture with Database Server
# using AWS CLI
################


# Create and connect 2 new servers with Linux Ubuntu Os installed
# namely mysql_server and mysql_client via PowerShell or Terminal

aws ec2 run-instances \
 --image-id ami-0fc5d935ebf8bc3bc \
 --count 2 \
 --instance-type t2.micro \
 --key-name new_keys \
 --security-group-ids sg-0b21426e88f886da9 \
 --subnet-id  subnet-0a0e3a8df801bcd0b \
 --tag-specifications 'ResourceType=instance,Tags=[{Key=Name1,Value=mysql_client},{Key=Name2,Value=mysql_server}]'

  



# Connect to the mysql_client via SSH
aws ec2 get-password-data --instance-id i-0d7bf4111e35ecb2e --priv-launch-key C:/Users/user/Documents/Paul/new_keys.pem
ssh -i C:/Users/user/Documents/Paul/new_keys.pem ec2-user@ec2-3-232-108-41.compute-1.amazonaws.com -L 8080:localhost:80
or
ssh -i C:/Users/user/Documents/Paul/new_keys.pem ec2-user@3.232.108.41

# user needs be changed from ec2-user to ubuntu hence the public key permision denial.

ssh -i C:/Users/user/Documents/Paul/new_keys.pem ubuntu@3.232.108.41
ssh -i C:/Users/user/Documents/Paul/new_keys.pem ubuntu@ec2-3-232-108-41.compute-1.amazonaws.com -L 8080:localhost:80




# Install mysql client software on mysql_client server
sudo apt update
sudo apt install mysql-client

# Connect to the mysql_server via SSH
ssh ubuntu@mysql_server-public-ip

# Install mysql server software on mysql_server server
sudo apt update
sudo apt install mysql-server
sudo mysql_secure_installation


# Open port 3306 on mysqlserver by configuring the new inbound rule
# and connect to mysqlserver from mysql_client server
# Note for extra security, do not  allow all IP address to reach 
# 'mysql_server' -only allow acccess only to specific local IP address of 
# 'mysql_client'


aws ec2 authorize-security-group-ingress --group-id sg-0b21426e88f886da9 --protocol tcp	--port 3306 --cidr 172.31.0.0/20


# Configure mysql_server to allow connections from remote hosts,  
# and connect to mysqlserverDB engine from mysql_client server without SSH 
# but with mysql connect utility




# Confirm successful remote Mysql_server DB, by running some mysql queries



