#!/bin/bash

declare -a StringArray=("web1" "web2" "lb" )

for val in ${StringArray[@]}; do 
   echo adding $val >> ~/.ssh/known_hosts
done 
