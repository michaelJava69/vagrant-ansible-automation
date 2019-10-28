#!/bin/bash
 
 
# Declare an array of string with type
declare -a StringArray=("web1" "web2" "lb"  )
 
# Iterate the string array using for loop
for val in ${StringArray[@]}; do
   echo addding $val to list of known hosts
   ssh-keyscan $val >> ~/.ssh/known_hosts
done
