#!/usr/bin/bash


################
#Author: Paul Akinsande
#Date: 16/10/2023
#Purpose: Learning Scripting with User Input Example
################

# USER INPUT

read -p "Enter your name: " NAME
echo "Hello $NAME, nice to meet you!"

read -p "$NAME: " RESPONSE    # -p flag here means prompt
echo "$RESPONSE">response.txt

echo "How can I assist you ?" # code can be re-written as echo "How can I assist you" RESPONSE

sleep 1

read -p "$NAME: " RESPONSE
echo "$RESPONSE">>response.txt
