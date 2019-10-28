#!/usr/bin/env bash

 

# install nosetests and mock for python testing framework to 
sudo apt -y install python-pip
pip install nose requests

git clone https://github.com/testing-cabal/mock.git
pip install -U mock                                                        #https://mock.readthedocs.io/en/latest/

 