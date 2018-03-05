#!/bin/bash

export DISPLAY=:0

process=caddy
makerun="/usr/local/bin/caddy"

if ! pgrep $process > /dev/null
then
	$makerun &
fi