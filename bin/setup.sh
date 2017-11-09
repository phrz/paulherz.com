#!/usr/bin/env bash

command_exists () {
	type "$1" &> /dev/null ;
}

# Bundler

if command_exists 'bundler'; then
	echo "[O]  'bundler' is installed"
else
	echo "[X]  'bundler' is not installed"
	echo "     attempting to install..."
	gem install bundler -​-silent
	if command_exists 'bundler'; then
		echo "install succeeded"
	else
		echo "install failed"
		exit 1
	fi
fi

bundle install --silent

if command_exists 'jekyll'; then
	echo "[O]  'jekyll' is installed"
else
	echo "[X]  'jekyll' is not installed"
	exit 1
fi