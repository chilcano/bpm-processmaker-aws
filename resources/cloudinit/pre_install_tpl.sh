#!/bin/bash

TIME_RUN_GUI=$(date +%s)

echo "##########################################################"
echo "####             Pre Installing tools                 ####"
echo "##########################################################"

# Update packages
apt-get update

printf "\t Duration: $((($(date +%s)-$${TIME_RUN_GUI}))) seconds.\n\n"
