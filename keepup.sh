#!/bin/bash

export DISPLAY=:0

process=caddy
makerun="/usr/local/bin/caddy -agree"

if ! pgrep $process > /dev/null
then
	$makerun &
fi
