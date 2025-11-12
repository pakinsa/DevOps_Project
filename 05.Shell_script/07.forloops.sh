#!/usr/bin/bash

################
#Author: Paul Akinsande
#Date: 12/10/2023
#Purpose: Learning For Loops
################

# Simple For loop 

# Declare an array of names
#names=(Tope Tolu Peter Stella Paul Philip)

# Loop through the array and print each name with a number
#for i in "${!names[@]}"; do
#  # Add one to the index to get the number
#  num=$((i + 1))
#  # Print the number and the name with a space in between
#  echo "$num ${names[i]}"  # or echo "${names[i]} $num"
#done



# FOR loop for renaming files
FILES=$(ls *.txt)
for FILE in $FILES
    do 
       mv $FILE "newtxt_$FILE"
       echo "This $FILE has been renamed as newtxt_$FILE"
done


