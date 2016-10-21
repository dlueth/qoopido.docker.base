#!/bin/bash

up() {
    local UP="/app/config/up.sh"

    if [ -f $UP ]
    then
        echo "    Running startup script /app/config/up.sh"
        chmod +x $UP && chmod 755 $UP && eval $UP;
    fi

    trap down SIGTERM

    while true; do
		: # Do nothing
	done
}

down()
{
	local DOWN="/app/config/down.sh"

	if [ -f $DOWN ]
    then
    	echo "    Running shutdown script /app/config/down.sh"
		chmod +x $DOWN && chmod 755 $DOWN && eval $DOWN;
    fi

    exit
}

up &