#!/bin/bash

declare -a StringArray=("web1" "web2" "lb" )

for val in ${StringArray[@]}; do 
   echo adding $val to list of known_hosts
   ssh-keyscan $val >> ~/.ssh/known_hosts
done 
