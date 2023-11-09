#!/bin/bash

sudo sudo apt update
sudo apt-get upgrade
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl status nginx
