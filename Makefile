default: build deploy

serve:
	bundler exec jekyll serve --drafts
setup:
	./bin/setup.sh
build:
	bundler exec jekyll build
deploy:
	# --compress --one-file-system --recursive --checksum
	rsync --progress -zxrc --delete _site/ ph:/var/www/paulherz/
clean:
	bundler exec jekyll clean
