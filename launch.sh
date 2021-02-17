#!/usr/bin/env bash
if [ ! -f conf/configuration.lua ]
then
    echo "Please insert the required variables into configuration.example.lua. Then, you need to rename configuration.example.lua to configuration.lua!"
else
    while true; do
	source conf/.env && export $(cut -d= -f1 conf/.env)
        lua -e "require('oneteam').run({}, require('configuration'))"
        echo "OneTeamBot has stopped!"
        sleep 3s
    done
fi
