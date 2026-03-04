#! /usr/bin/bash

# Enable Docker

sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo usermod -aG docker $USER
